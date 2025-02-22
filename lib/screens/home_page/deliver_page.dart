import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/http_request.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/command.dart';
import 'package:mobilino_app/models/product.dart';
import 'package:mobilino_app/providers/depot_provider.dart';
import 'package:mobilino_app/providers/product_provider.dart';
import 'package:mobilino_app/screens/home_page/store_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/add_payment_dialog.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/command_dialog.dart';
import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:provider/provider.dart';

class DeliverdPage extends StatefulWidget {
  final Client client;
  final String type;

  const DeliverdPage({
    super.key,
    required this.client,
    required this.type,
  });

  @override
  State<DeliverdPage> createState() => _DeliverdPageState();
}

class _DeliverdPageState extends State<DeliverdPage> {
  double total = 0;
  late IconButton validateIcon;

  @override
  void initState() {
    super.initState();
    total = widget.client.command!.total;
    reload();
  }

  void reload() {
    setState(() {
      widget.client.command!.calculateTotal();
      total = widget.client.command!.total;
      print('total is: ${total}');
    });
  }

  Future<void> fetchPaidData() async {
    String url = AppUrl.echeances +
        AppUrl.user.etblssmnt!.code! +
        '/' +
        widget.client.id!;
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res pay code : ${req.statusCode}");
    print("res pay body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.toList().forEach((element) {
        print('cmpar : ${widget.client.command!
            .id}  ${element['docNumero']}  ${widget.client.command!.date}');
        try {
          if (widget.client.command!.id == element['docNumero']) {
            print('elementIS: $element');
            print('reçu: ${element['echRecu']}');
            if (element['echRecu'] != null)
              widget.client.command!.paid =
                  widget.client.command!.paid + element['echRecu'];
          }
          // provider.paymentList.add(Payment(
          //     currentPaid: 0,
          //     code: element['echNumero'],
          //     total: element['echArecev'],
          //     paid: element['echRecu']));
        } catch (e, stackTrace) {
          print('Exception: $e');
          print('Stack trace: $stackTrace');
        }
      });
    }
  }

  Future<bool?> fetchData() async {
    if (widget.type == 'Livraison')
      await fetchPaidData();
    String url = AppUrl.getOneDoc +
        widget.client.command!.id! +
        '/' +
        AppUrl.user.etblssmnt!.code!;
    print('url of getOneDoc ${url}');

    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res cmdOpp code : ${req.statusCode}");
    print("res cmdOpp body: ${req.body}");
    if (req.statusCode == 200) {
      var res = json.decode(req.body);
      List<dynamic> data = res['lignes'];
      print('sizeof: ${data.length}');
      print('prod 0 : ${data.first}');
      try {
        List<Product> products = [];
        await Future.forEach(data.toList(), (element) async {
          print('quantité: ${element['qte'].toString()}');
          double d = 0;
          if (element['qte'] != null) d = element['qte'];
          int quantity = d.toInt();
          double dStock;
          if (element['stockDep'] != null) dStock = element['stockDep'];
          int quantityStock = d.toInt();
          var artCode = element['artCode'];
          double total = 0;
          double remise = 0;
          double tva = 0;
          if (element['natTvatx'] != null) tva = element['natTvatx'];
          if (element['remise'] != null) remise = element['remise'];
          if (element['total'] != null) total = element['total'];
          print('imghhh $artCode');
          print('url: ${AppUrl.getUrlImage + '$artCode'}');
          http.Response req = await http
              .get(Uri.parse(AppUrl.getUrlImage + '$artCode'), headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
            "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/",
          });
          print("res imgArticle code : ${req.statusCode}");
          print("res imgArticle body: ${req.body}");
          if (req.statusCode == 200) {
            List<dynamic> data = json.decode(req.body);
            if (data.length > 0) {
              var item = data.first;
              print('item: ${item['path']}');
              products.add(Product(
                  quantity: quantity,
                  quantityStock: quantityStock,
                  price: element['pBrut'],
                  total: total,
                  remise: remise,
                  tva: tva,
                  id: element['artCode'],
                  image: AppUrl.baseUrl + item['path'],
                  name: element['lib']));
            }
          }
        }).then((value) {
          print('nbProd: ${products.length}');
          widget.client.command!.products = products;
          widget.client.command!.nbProduct = products.length;
          widget.client.command!.calculateTotal();
          total = widget.client.command!.total;
          // = Command(
          //     id: res['numero'],
          //     date: DateTime.parse(res['date']),
          //     total: 0,
          //     paid: 0,
          //     products: products,
          //     nbProduct: products.length);
        });

        return true;
        // get image
      } catch (e, stackTrace) {
        print('Exception: $e');
        print('Stack trace: $stackTrace');
      }
    } else {}

    return false;
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Future is still running, return a loading indicator or some placeholder.
            return AlertDialog(
              content: Container(
                  width: 200,
                  height: 100,
                  child: Image.asset('assets/CRM-Loader.gif')),
            );
          } else if (snapshot.hasError) {
            // There was an error in the future, handle it.
            print('Error: ${snapshot.hasError} ${snapshot.error} ');
            return AlertDialog(
              content: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  // Text('Error: ${snapshot.error}')
                  Text(
                      'Nous sommes désolé, la qualité de votre connexion ne vous permet pas de vous connecter à votre serveur.'
                          ' Veuillez réessayer ultérieurement. Merci'),
                ],
              ),
            );
          } else
            return Consumer<ProductProvider>(
                builder: (context, products, snapshot) {
                  return Scaffold(
                    appBar: AppBar(
                      iconTheme: IconThemeData(
                        color: Colors.white, // Set icon color to white
                      ),
                      backgroundColor: Theme
                          .of(context)
                          .primaryColor,
                      title: ListTile(
                        title: Text(
                          '${widget.type}',
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline2!
                              .copyWith(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${widget.client.name}',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                      actions: [
                        IconButton(onPressed: () async {
                          if (widget.client.email != null) {
                            HttpRequestApp httpRequestApp = HttpRequestApp();
                            await httpRequestApp.sendEmail(
                                widget.client.command!.id!,
                                widget.type, '${widget.client.email}').then((
                                value) {
                              if (value) {
                                showMessage(
                                    message: 'Email a été envoyé avec succès',
                                    context: context,
                                    color: primaryColor);
                              } else {
                                showMessage(
                                    message: 'Échec de l\'envoie d\'email',
                                    context: context,
                                    color: Colors.red);
                              }
                            });
                          } else {
                            showAlertDialog(
                                context, 'Pas email pour ce client');
                          }
                        },
                          icon: Icon(
                            Icons.send_outlined, color: Colors.white,),)
                      ],
                    ),
                    body: Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    // Shadow color
                                    offset: Offset(
                                        0, 5), // Offset from the object
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.all(8),
                              height: 50,
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Icon(
                                      Icons.calendar_month_outlined,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .format(
                                          widget.client.command!.date)}',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .headline3,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 550,
                              child: ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    print(
                                        'eee: ${widget.client.command!.products
                                            .length}');
                                    //print('nullable ??? ${widget.client.command!.products}');
                                    return CommandItem(
                                      //product: widget.client.command!.products![index],
                                      product:
                                      widget.client.command!.products[index],
                                      command: widget.client.command!,
                                      callback: reload,
                                    );
                                  },
                                  itemCount:
                                  widget.client.command!.products.length),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            height: 100,
                            color: primaryColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${widget.client.command!.nbProduct!}',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Articles',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  width: 2,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date : ${DateFormat(
                                          'yyyy-MM-dd HH:mm:ss').format(
                                          widget.client.command!.date!)}',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    Text(
                                      'Total : ${AppUrl.formatter.format(
                                          widget.client.command!
                                              .totalWitoutTaxes)} DZD',
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    Text(
                                      'TVA : ${AppUrl.formatter.format(
                                          widget.client.command!
                                              .totalTVA)} DZD',
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    Text(
                                      'TTC : ${AppUrl.formatter.format(
                                          total)} DZD',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    (widget.type == 'Livraison') ? Text(
                                      'Payée : ${AppUrl.formatter.format(
                                          widget.client.command!.paid)} DZD',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white),
                                    ) : Container(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
        });
  }
}

// class CommandItem extends StatefulWidget {
//   final Product product;
//   final Command command;
//   final VoidCallback callback;
//
//   const CommandItem(
//       {super.key,
//       required this.product,
//       required this.command,
//       required this.callback});
//
//   @override
//   State<CommandItem> createState() => _CommandItemState();
// }
//
// class _CommandItemState extends State<CommandItem> {
//   @override
//   Widget build(BuildContext context) {
//     ConfirmationDialog confirmationDialog = ConfirmationDialog();
//     return Builder(builder: (context) {
//       return Column(
//         children: [
//           Slidable(
//             child: Container(
//               width: double.infinity,
//               height: 110,
//               child: Expanded(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                         height: 60,
//                         width: 70,
//                         child: (widget.product.image == null)
//                             ? Icon(
//                                 Icons.image_not_supported_outlined,
//                               )
//                             : Image.network(
//                                 '${widget.product.image}',
//                                 // Replace with your image URL
//                                 fit: BoxFit
//                                     .cover, // Adjust the fit as needed (cover, contain, etc.)
//                               )),
//                     Text('(${widget.product.quantity})',
//                         style: Theme.of(context)
//                             .textTheme
//                             .headline4!
//                             .copyWith(color: primaryColor)),
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           width: 100,
//                           child: Text(
//                             '${widget.product.name} ',
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 1, // Limit to one line
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .headline6!
//                                 .copyWith(color: primaryColor),
//                           ),
//                         ),
//                         Text('${widget.product.category} ',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyText2!
//                                 .copyWith(color: Colors.grey)),
//                       ],
//                     ),
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           '${widget.product.total} DZD ',
//                           style:
//                               Theme.of(context).textTheme.headline5!.copyWith(
//                                     color: primaryColor,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                         ),
//                         Text(
//                           '${widget.product.quantity} x ${widget.product.price} DZD ',
//                           style:
//                               Theme.of(context).textTheme.bodyText1!.copyWith(
//                                     color: primaryColor,
//                                   ),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Text(
//                           '${widget.product.quantity}',
//                           style:
//                               Theme.of(context).textTheme.bodyText1!.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Divider(
//             color: Colors.grey,
//           )
//         ],
//       );
//     });
//   }
//
//   Future<String?> getUrlImage(String artCode) async {
//     print('imghhh $artCode');
//     var body = jsonEncode({
//       'artCode': artCode,
//     });
//     print('url: ${AppUrl.getUrlImage + '$artCode'}');
//     http.Response req =
//         await http.get(Uri.parse(AppUrl.getUrlImage + '$artCode'), headers: {
//       "Accept": "application/json",
//       "content-type": "application/json; charset=UTF-8",
//       "Referer": "http://"+AppUrl.user.company!+".localhost:4200/",
//     });
//     print("res imgArticle code : ${req.statusCode}");
//     print("res imgArticle body: ${req.body}");
//     if (req.statusCode == 200) {
//       List<dynamic> data = json.decode(req.body);
//       if (data.length > 0) {
//         var item = data.first;
//         print('item: ${item['path']}');
//         return AppUrl.baseUrl + item['path'];
//       }
//     }
//     return null;
//   }
// }

class CommandItem extends StatefulWidget {
  final Product product;
  final Command command;
  final VoidCallback callback;

  const CommandItem({super.key,
    required this.product,
    required this.command,
    required this.callback});

  @override
  State<CommandItem> createState() => _CommandItemState();
}

class _CommandItemState extends State<CommandItem> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    ConfirmationDialog confirmationDialog = ConfirmationDialog();
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () {
          setState(() {
            isVisible = !isVisible;
          });
        },
        child: Column(
          children: [
            Slidable(
              startActionPane: ActionPane(motion: ScrollMotion(), children: [
                SlidableAction(
                  flex: 5,
                  onPressed: (_) async {
                    bool confirmed = await confirmationDialog
                        .showConfirmationDialog(context, 'deleteProduct');
                    if (confirmed) {
                      setState(() {
                        final provider = Provider.of<ProductProvider>(context,
                            listen: false);
                        provider.removeProduct(widget.product, widget.command);
                        widget.callback();
                      });
                    }
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                  label: 'Supprimer',
                ),
              ]),
              child: Container(
                width: double.infinity,
                height: 115,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(left: 15),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          height: 60,
                          width: 70,
                          child: (widget.product.image == null)
                              ? Icon(
                            Icons.image_not_supported_outlined,
                          )
                              : Image.network(
                            '${widget.product.image}',
                            // Replace with your image URL
                            fit: BoxFit
                                .cover, // Adjust the fit as needed (cover, contain, etc.)
                          )),
                      SizedBox(
                        width: 5,
                      ),
                      // Text('(${widget.product.quantity})',
                      //     style: Theme.of(context)
                      //         .textTheme
                      //         .headline4!
                      //         .copyWith(color: primaryColor)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            child: Text(
                              '${widget.product.name} ',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1, // Limit to one line
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(color: primaryColor),
                            ),
                          ),
                          Text('${widget.product.category} ',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(color: Colors.grey)),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Prix unitaire :',
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(),
                          ),
                          Text(
                            '${AppUrl.formatter.format(
                                widget.product.price)} DZD',
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(color: primaryColor),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total ${AppUrl.formatter.format(
                                widget.product.totalWitoutTaxes)} DZD ',
                            style:
                            Theme
                                .of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            'TVA ${AppUrl.formatter.format(
                                widget.product.priceTVA)} DZD ',
                            style:
                            Theme
                                .of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            'TTC ${AppUrl.formatter.format(
                                widget.product.total)} DZD',
                            style:
                            Theme
                                .of(context)
                                .textTheme
                                .headline5!
                                .copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CommandDialog(widget.product);
                                },
                              ).then((value) {
                                setState(() {
                                  widget.product.calculateTotal();
                                  widget.callback();
                                });
                              });
                            },
                            child: Text(
                              '(${widget.product.quantity})',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: isVisible,
              child: Container(
                margin: EdgeInsets.all(8),
                width: double.infinity,
                height: 180,
                color: backgroundColor,
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.all(8),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.4,
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
                        '${widget.product.image}',
                        // Replace with your image URL
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
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            child: Text(
                              '${widget.product.name}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor),
                            ),
                          ),
                          Text('${widget.product.category} ',
                              style: Theme
                                  .of(context)
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Quantité ',
                                    style:
                                    Theme
                                        .of(context)
                                        .textTheme
                                        .bodyText1),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CommandDialog(widget.product);
                                      },
                                    ).then((value) {
                                      setState(() {
                                        widget.product.calculateTotal();
                                        widget.callback();
                                      });
                                    });
                                  },
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 4),
                                      child: Center(
                                          child: Text(
                                            '${widget.product.quantity}',
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
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CommandDialog(widget.product);
                                },
                              ).then((value) {
                                setState(() {
                                  widget.product.calculateTotal();
                                  widget.callback();
                                });
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(bottom: 2),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: primaryColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Remise',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1),
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 4),
                                      child: Center(
                                          child: Text(
                                            '${widget.product.remise}',
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
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CommandDialog(widget.product);
                                },
                              ).then((value) {
                                setState(() {
                                  widget.product.calculateTotal();
                                  widget.callback();
                                });
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(bottom: 2),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: primaryColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('TVA',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1),
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 4),
                                      child: Center(
                                          child: Text(
                                            '${widget.product.tva}',
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
            )
          ],
        ),
      );
    });
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
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/",
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
}

void _showAlertDialog(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.yellow,
              size: 50.0,
            ),
          ],
        ),
        content: Text(
          '$text',
          style: Theme
              .of(context)
              .textTheme
              .headline6!,
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(primaryColor)),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Ok',
                style: Theme
                    .of(context)
                    .textTheme
                    .headline3!
                    .copyWith(color: Colors.white)),
          ),
        ],
      );
    },
  );
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
