import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/command.dart';
import 'package:mobilino_app/models/product.dart';
import 'package:mobilino_app/providers/product_provider.dart';
import 'package:mobilino_app/screens/home_page/new_command_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/command_dialog.dart';
import 'package:provider/provider.dart';

class StorePage extends StatefulWidget {
  final Client client;

  const StorePage({super.key, required this.client});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  String result = '';
  double total = 0;
  int nbProduct = 0;
  int PageNumber = 1;
  int PageSize = 10;
  String filter = '';
  String _barcodeResult = 'No Barcode Yet';

  @override
  void initState() {
    super.initState();
    widget.client.command = Command(
        date: DateTime.now(), total: 0, paid: 0, products: [], nbProduct: 0);
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.allProducts = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoaderDialog(context);
      fetchData().then((value) {
        Navigator.pop(context);
        reload();
      });
      //reload();
    });
  }

  // Function to fetch JSON data from an API
  Future<void> fetchData() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.allProducts = [];
    String url = AppUrl.articles +
        '?PageNumber=1&Filter=$filter&PageSize=20';
    print('url articles catalog: $url');
    http.Response req = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
        });
    print("res article code : ${req.statusCode}");
    print("res article body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.toList().forEach((element) async {
        print('code article:  ${element['code']}');
        // double dStock = element['stockDep'];
        // int quantityStock = dStock.toInt();
        getUrlImage(element['code']).then((value) {
          getQuantityMax(element['code']).then((stk){
            provider.allProducts.add(Product(
                name: element['lib'],
                image: value,
                category: element['categ'],
                codeBar: element['cbar'],
                isChosen: false,
                quantity: 0,
                remise: 0,
                tva: 0,
                quantityStock: stk,
                price: element['pVte'],
                total: 0,
                id: element['code']));
            provider.notifyListeners();
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set icon color to white
        ),
        backgroundColor: primaryColor,
        title: ListTile(
          title: Text(
            'Commande de : ',
            style: Theme.of(context)
                .textTheme
                .headline3!
                .copyWith(color: Colors.white),
          ),
          subtitle: Text(
            '${widget.client.name}',
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              final provider =
                  Provider.of<ProductProvider>(context, listen: false);
              provider.filtredProducts = [];
              showSearch(
                  context: context,
                  delegate:
                      StoreSearchDelegate(widget.client.command!, reload, ''),
                  query: '');
            },
          ),
          IconButton(
              onPressed: () {
                _scanBarcode();
              },
              icon: Icon(Icons.document_scanner_outlined))
        ],
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: () {
            if (widget.client.command!.nbProduct > 0) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Center(child: Text('Veuillez choisir une option')),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: primaryColor, // Change the button color here
                            onPrimary: Colors.white, // Change the text color here
                          ),
                          onPressed: () {
                            Navigator.of(context).pop('Devis');
                          },
                          child: Text('Devis',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(color: Colors.white)),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue, // Change the button color here
                            onPrimary: Colors.white, // Change the text color here
                          ),
                          onPressed: () {
                            Navigator.of(context).pop('Commande');
                          },
                          child: Text('Commande',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ).then((value) {
                if (value != null) {
                  // Handle the selected option here
                  print('Selected Option: $value');
                  widget.client.command!.type = value;
                  PageNavigator(ctx: context).nextPage(
                      page: NewCommandPage(
                        client: widget.client,
                        callback: reload,
                      ));
                }
              });
              // PageNavigator(ctx: context).nextPage(
              //     page: NewCommandPage(
              //   client: widget.client,
              //   callback: reload,
              //   //callback: reload,
              // ));
            }
          },
          backgroundColor: Colors.white,
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.shopping_cart_checkout_outlined,
                  color: primaryColor,
                ),
              ),
              Positioned(
                top: -4,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red),
                    child: Text(
                      '${nbProduct}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Visibility(
                visible: false,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1), // Shadow color
                        offset: Offset(0, 5), // Offset from the object
                      ),
                    ],
                  ),
                  margin: EdgeInsets.all(8),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            color: primaryColor,
                          ),
                          Text(
                            'Sélctionner une date de livraison',
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(color: primaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Consumer<ProductProvider>(builder: (context, products, snapshot) {
                return Container(
                  height: 550,
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) => CommandItem(
                            product: products.allProducts.toList()[index],
                            command: widget.client.command!,
                            callback: reload,
                          ),
                      itemCount: products.allProducts.toList().length),
                );
              }),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 80,
              color: primaryColor,
              child: Center(
                child: Container(
                  child: Center(
                      child: Text(
                    '${AppUrl.formatter.format(widget.client.command!.totalWitoutTaxes)} DZD',
                    style: Theme.of(context)
                        .textTheme
                        .headline3!
                        .copyWith(color: Colors.white),
                  )),
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 60,
                  decoration: BoxDecoration(
                    color: secondryColor,
                    borderRadius:
                        BorderRadius.circular(25), // Set the border radius here
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void reload() {
    setState(() {
      widget.client.command!.calculateTotal();
      total = widget.client.command!.total;
      nbProduct = widget.client.command!.nbProduct;
      //widget.callback();
    });
  }

  Future<void> _scanBarcode() async {
    String barcodeResult = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', // Color for the background of the scan view
      'Cancel', // Cancel button text
      true, // Show flash icon
      ScanMode.DEFAULT, // Scan mode: QR code, barcode, or both
    );
    setState(() {
      print('scan = ${barcodeResult}');
      _barcodeResult = barcodeResult;
      if (barcodeResult != '-1') {
        showSearch(
            context: context,
            delegate:
                StoreSearchDelegate(widget.client.command!, reload, 'barCode'),
            query: barcodeResult);
      }
    });
  }
}

class CommandItem extends StatefulWidget {
  Product product;
  final Command command;
  final VoidCallback callback;

  CommandItem(
      {super.key,
      required this.product,
      required this.command,
      required this.callback});

  @override
  State<CommandItem> createState() => _CommandItemState();
}

class _CommandItemState extends State<CommandItem> {
  bool isVisible = false;
  late Icon icon;
  var provider = null;

  @override
  Widget build(BuildContext context) {
    widget.command.products.any((product) {
      if (product.id == widget.product.id) {
        widget.product = product;
        return true;
      }
      return false;
    });
    provider = Provider.of<ProductProvider>(context, listen: false);
    //print('choose: ${widget.product.isChosen}');
    if (widget.product.isChosen == false)
      icon = Icon(
        Icons.add_shopping_cart_outlined,
        color: primaryColor,
      );
    else
      icon = Icon(
        Icons.remove_shopping_cart_outlined,
        color: Colors.red,
      );
    return InkWell(
      onTap: () {
        setState(() {
          isVisible = !isVisible;
        });
      },
      child: Column(
        children: [
          Container(
            //width: double.infinity,
            height: 120,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    height: 60,
                    width: 60,
                    child: (widget.product.image == null)
                        ? Icon(Icons.image_not_supported_outlined)
                        : Image.network(
                            '${widget.product.image}', // Replace with your image URL
                            fit: BoxFit
                                .cover, // Adjust the fit as needed (cover, contain, etc.)
                          ),
                    // Image.asset(
                    //   'assets/product.png',
                    //   fit: BoxFit.cover,
                    // )
                  ),
                  // Text('(3)',
                  //     style: Theme
                  //         .of(context)
                  //         .textTheme
                  //         .headline4!
                  //         .copyWith(color: primaryColor)),
                  IconButton(
                      onPressed: () {
                        _chooseProduct();
                      },
                      icon: icon),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        child: Text(
                          '${widget.product.name}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3, // Limit to one line
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: primaryColor),
                        ),
                      ),
                      Text('${widget.product.category}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: Colors.grey)),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (widget.product.remise != 0 && widget.product.quantity > 0) ?Text(
                        '${AppUrl.formatter.format(widget.product.price * widget.product.quantity)} DZD ',
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red,
                        ),
                      ) : Container(),
                      Text(
                        '${AppUrl.formatter.format(widget.product.totalWitoutTaxes)} DZD ',
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${widget.product.quantity} x ${AppUrl.formatter.format(widget.product.price)} DZD ',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: primaryColor,
                            ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            final provider = Provider.of<ProductProvider>(context,
                                listen: false);
                            print(
                                'quantity: ${widget.product.quantity} choose: ${widget.product.isChosen}');
                            if (widget.product.quantity == 0)
                              icon = Icon(
                                Icons.remove_shopping_cart_outlined,
                                color: Colors.red,
                              );
                            // if(widget.product.quantity >= widget.product.quantityStock!){
                            //   showMessage(
                            //       message: 'Quantité supérieure à la quantité en stock',
                            //       context: context,
                            //       color: Colors.red);
                            //   return;
                            // }
                            provider.incrementQuantity(
                              widget.product,
                              widget.command,
                            );
                            widget.callback();
                          });
                        },
                        icon: Container(
                          height: 23,
                          width: 23,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      Text(
                        '${widget.product.quantity}',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            final provider = Provider.of<ProductProvider>(context,
                                listen: false);
                            provider.decrementQuantity(
                              widget.product,
                              widget.command,
                            );
                            widget.callback();
                          });
                        },
                        icon: Container(
                          height: 23,
                          width: 23,
                          decoration: BoxDecoration(
                            border: Border.all(color: grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(
                            Icons.remove_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isVisible,
            child: Container(
              margin: EdgeInsets.all(8),
              width: double.infinity,
              height: 160,
              color: backgroundColor,
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    child: (widget.product.image == null)
                        ? Icon(Icons.image_not_supported_outlined)
                        : Image.network(
                            '${widget.product.image}', // Replace with your image URL
                            fit: BoxFit
                                .cover, // Adjust the fit as needed (cover, contain, etc.)
                          ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    padding:
                        EdgeInsets.only(left: 8, right: 0, top: 8, bottom: 8),
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            '${widget.product.name}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(color: primaryColor),
                          ),
                        ),
                        Text('${widget.product.category}',
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.grey)),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: primaryColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: (){
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CommandDialog(widget.product);
                                },
                              ).then((value){
                                setState(() {
                                  widget.product.calculateTotal();
                                  widget.callback();
                                });
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Quantité sotck ',
                                    style: Theme.of(context).textTheme.bodyText1),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 4),
                                    child: Center(
                                        child: Text(
                                      '${widget.product.quantityStock}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor),
                                    )),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: primaryColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: (){
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CommandDialog(widget.product);
                                },
                              ).then((value){
                                setState(() {
                                  widget.product.calculateTotal();
                                  widget.callback();
                                });
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Remise ',
                                    style: Theme.of(context).textTheme.bodyText1),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 4),
                                    child: Center(
                                        child: Text(
                                      '${widget.product.remise} %',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor),
                                    )),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: primaryColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: (){
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CommandDialog(widget.product);
                                },
                              ).then((value){
                                setState(() {
                                  widget.product.calculateTotal();
                                  widget.callback();
                                });
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('TVA',
                                    style: Theme.of(context).textTheme.bodyText1),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 4),
                                    child: Center(
                                        child: Text(
                                      '${widget.product.tva} %',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor),
                                    )),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  void _chooseProduct() {
    setState(() {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      if (widget.product.isChosen == false) {
        widget.product.isChosen = true;
        icon = Icon(
          Icons.add_shopping_cart_outlined,
          color: primaryColor,
        );
        provider.addProduct(widget.product, widget.command);
      } else {
        widget.product.isChosen = false;
        icon = Icon(
          Icons.remove_shopping_cart_outlined,
          color: Colors.red,
        );
        provider.removeProduct(widget.product, widget.command);
      }
      widget.callback();
    });
  }
}

class StoreSearchDelegate extends SearchDelegate {
  final Command command;
  final VoidCallback callback;
  late String barCode;

  StoreSearchDelegate(this.command, this.callback, this.barCode);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
            onPressed: () {
              if (query.isNotEmpty)
                query = '';
              else
                close(context, null);
            },
            icon: Icon(Icons.clear))
      ];

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    return FutureBuilder(
        future:
            (barCode == '') ? fetchData(context) : fetchDataBarCode(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Future is still running, return a loading indicator or some placeholder.
            return Center(
              child: Row(
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 15),
                      child: Text("Loading...")),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // There was an error in the future, handle it.
            print('Error: ${snapshot.hasError}');
            return Text('Error: ${snapshot.error}');
          } else {
            final list = provider.filtredProducts
                .toList()
                .where((product) =>
                    product.name!.toLowerCase().contains(query.toLowerCase()) ||
                    product.codeBar!
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    product.price
                        .toString()!
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    product.category!
                        .toLowerCase()
                        .contains(query.toLowerCase()))
                .toList();
            return resultFilter(list, context);
          }
        });
  }

  Widget resultFilter(List<Product> list, BuildContext context) {
    if (list.isEmpty)
      return Center(
        child: Text(
          'Aucune résultat !',
          style: Theme.of(context).textTheme.headline2,
        ),
      );
    else
      return Consumer<ProductProvider>(builder: (context, products, snapshot) {
        products.notifyListeners();
        return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) => CommandItem(
                  product: list[index],
                  command: command,
                  callback: callback,
                ),
            itemCount: list.length);
      });
  }

// Function to fetch JSON data from an API
  Future<void> fetchData(BuildContext context) async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.filtredProducts = [];
    http.Response req = await http.get(
        Uri.parse(AppUrl.articlesFromDepotPage +
            '${AppUrl.user.etblssmnt!.code}/${AppUrl.user.localDepot!.id}' +
            '?PageNumber=1&Filter=$query&PageSize=20'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
        });
    print("res article code : ${req.statusCode}");
    print("res article body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.toList().forEach((element) async {
        print('code article:  ${element['code']}');
        String? img;
        int? stock;
        getUrlImage(element['code']).then((value) {
          getQuantityMax(element['code']).then((stk){
            stock = stk;
          });
          img = value;
          provider.notifyListeners();
        });
        provider.filtredProducts.add(Product(
            name: element['lib'],
            image: img,
            category: element['categ'],
            codeBar: element['cbar'],
            isChosen: false,
            quantity: 0,
            remise: 0,
            tva: 0,
            quantityStock: stock,
            price: element['pVte'],
            total: 0,
            id: element['code']));
        provider.notifyListeners();
      });
    }
    print('size is : ${provider.filtredProducts.length}');
    provider.notifyListeners();
  }

  Future<void> fetchDataBarCode(BuildContext context) async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.filtredProducts = [];

    print('hhh $query id=${AppUrl.user.userId}');
    print('url is : ' +
        AppUrl.articlesFromDepot +
        '/cbar/${AppUrl.user.userId}?cBar=$query');
    http.Response req = await http.get(
        Uri.parse(AppUrl.articlesFromDepot +
            '/cbar/${AppUrl.user.userId}?cBar=$query'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
        });
    print("res bqrcode code : ${req.statusCode}");
    print("res bqrcode body: ${req.body}");
    if (req.statusCode == 200) {
      final data = json.decode(req.body);
      print('code article:  ${data['code']}');
      int? stock;
      getUrlImage(data['code']).then((value) {
        getQuantityMax(data['code']).then((stk){
          stock = stk;
        });
        provider.filtredProducts.add(Product(
            name: data['lib'],
            image: value,
            category: data['categ'],
            codeBar: data['cbar'],
            remise: 0,
            tva: 0,
            isChosen: false,
            quantity: 0,
            quantityStock: stock,
            price: data['pVte'],
            total: 0,
            id: data['code']));
        provider.notifyListeners();
      });
    }
    print('size is : ${provider.filtredProducts.length}');
    provider.notifyListeners();
  }
}

showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Container(
                  width: 200,
                  height: 100,
                  child: Image.asset('assets/CRM-Loader.gif')),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future<String?> getUrlImage(String artCode) async {
  print('imghhh $artCode');
  var body = jsonEncode({
    'artCode': artCode,
  });
  print('url: ${AppUrl.getUrlImage + '$artCode'}');
  http.Response req =
      await http.get(Uri.parse(AppUrl.getUrlImage + '$artCode'), headers: {
    "Accept": "application/json",
    "content-type": "application/json; charset=UTF-8",
    "Referer": "http://"+AppUrl.user.company!+".localhost:4200/",
  });
  print("res imgArticle code : ${req.statusCode}");
  print("res imgArticle body: ${req.body}");
  if (req.statusCode == 200) {
    List<dynamic> data = json.decode(req.body);
    if (data.length > 0) {
      var item = data.first;
      print('item: ${item['path']}');
      return AppUrl.baseUrl + item['path'];
    }
  }
  return null;
}

Future<int?> getQuantityMax(String artCode) async {
  String url = AppUrl.getQuantityMax + '${AppUrl.user.etblssmnt!.code}/$artCode';
  print(
      'url: $url');
  http.Response req =
  await http.get(Uri.parse(url), headers: {
    "Accept": "application/json",
    "content-type": "application/json; charset=UTF-8",
    "Referer": "http://"+AppUrl.user.company!+".localhost:4200/",
  });
  print("res maxQuantity code : ${req.statusCode}");
  print("res maxQuantity body: ${req.body}");
  if (req.statusCode == 200) {
    List<dynamic> data = json.decode(req.body);
    int somme = 0;
    data.toList().forEach((element) {
      double qt = element['stkReel'];
      int max = qt.toInt();
      somme = somme + max;
    });
    return somme;
  }
  return null;
}