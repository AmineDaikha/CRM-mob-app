import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/command.dart';
import 'package:mobilino_app/models/product.dart';
import 'package:mobilino_app/providers/depot_provider.dart';
import 'package:mobilino_app/providers/product_provider.dart';
import 'package:mobilino_app/screens/home_page/store_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/widgets/add_payment_dialog.dart';
import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:provider/provider.dart';

class NewCommandPage extends StatefulWidget {
  final Client client;
  final VoidCallback callback;

  const NewCommandPage({
    super.key,
    required this.client,
    required this.callback,
  });

  //static const String routeName = '/home/command';

  // static Route route() {
  //   return MaterialPageRoute(
  //     settings: RouteSettings(name: routeName),
  //     builder: (_) {
  //       return CommandPage();
  //     },
  //   );
  // }

  @override
  State<NewCommandPage> createState() => _NewCommandPageState();
}

class _NewCommandPageState extends State<NewCommandPage> {
  double total = 0;
  late DateTime selectedDate = DateTime.now();

  //late IconButton validateIcon;
  //late Command oldCommand;

  @override
  void initState() {
    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    //   // Access BuildContext or dependent widgets here

    // });
    super.initState();
    total = widget.client.command!.total;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reload();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor, // Day color
            buttonTheme: ButtonThemeData(colorScheme: ColorScheme.light(
              primary: primaryColor, // Change the color here
            ),), colorScheme: ColorScheme.light(primary:primaryColor).copyWith(secondary: primaryColor),
            // Button text color
          ),
          child: child!,);
      },
    );
    if (picked != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: primaryColor,
                // change the text color
                onSurface: grey,
              ),
              indicatorColor: primaryColor,
              primaryColor: primaryColor,
              backgroundColor: primaryColor,
              buttonTheme: ButtonTheme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  background: primaryColor,
                  secondary: primaryColor,
                ),
              ),
            ),
            child: child!,
          );
        },
      );
      if (selectedTime != null) {
        setState(() {
          selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  void reload() {
    setState(() {
      total = widget.client.command!.total;
      widget.callback();
      print('total is: ${total}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(builder: (context, products, snapshot) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white, // Set icon color to white
          ),
          backgroundColor: Theme.of(context).primaryColor,
          title: ListTile(
            title: Text(
              "Commande",
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(color: Colors.white),
            ),
            subtitle: Text(
              '${widget.client.name}',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.white),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async{
                ConfirmationDialog confirmationDialog = ConfirmationDialog();
                bool confirmed = await confirmationDialog
                    .showConfirmationDialog(context, 'confirmCommand');
                if(confirmed){
                  // confirm
                }
              },
              icon: Icon(
                Icons.check_box_outlined,
                color: Colors.white,
              ),
            ),
            // IconButton(
            //     onPressed: () {},
            //     icon: Icon(
            //       Icons.check_box_outlined,
            //       color: Colors.white,
            //     )),,
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
                        color: Colors.grey.withOpacity(0.1), // Shadow color
                        offset: Offset(0, 5), // Offset from the object
                      ),
                    ],
                  ),
                  margin: EdgeInsets.all(8),
                  height: 50,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: (){
                              _selectDate(context);
                          },
                          icon: Icon(Icons.calendar_month_outlined,
                          color: primaryColor,)
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                          style: Theme.of(context).textTheme.headline3,
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
                        //print('nullable ??? ${widget.client.command!.products}');
                        final provider = Provider.of<ProductProvider>(context,
                            listen: false);
                        provider.products = widget.client.command!.products;
                        return CommandItem(
                          //product: widget.client.command!.products![index],
                          product: provider.products![index],
                          command: widget.client.command!,
                          callback: reload,
                        );
                      },
                      itemCount: widget.client.command?.products!.length),
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
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Article',
                          style:
                              Theme.of(context).textTheme.headline4!.copyWith(
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date : ${DateFormat('dd-MM-yyyy HH:mm:ss').format(selectedDate)}',
                          style: Theme.of(context)
                              .textTheme
                              .headline5!
                              .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal),
                        ),
                        Text(
                          'Total : ${total} DZD',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Payée : ${widget.client.command!.paid} DZD',
                          style:
                              Theme.of(context).textTheme.headline5!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                  ),
                        )
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AddPaymentDialog(client: widget.client,);
                            });
                      },
                      icon: Ink(
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.add_shopping_cart_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class CommandItem extends StatefulWidget {
  final Product product;
  final Command command;
  final VoidCallback callback;

  const CommandItem(
      {super.key,
      required this.product,
      required this.command,
      required this.callback});

  @override
  State<CommandItem> createState() => _CommandItemState();
}

class _CommandItemState extends State<CommandItem> {
  @override
  Widget build(BuildContext context) {
    ConfirmationDialog confirmationDialog = ConfirmationDialog();
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Slidable(
            startActionPane: ActionPane(motion: ScrollMotion(), children: [
              SlidableAction(
                flex: 5,
                onPressed: (_) async {
                  bool confirmed = await confirmationDialog
                      .showConfirmationDialog(context, 'deleteProduct');
                  if (confirmed) {
                    setState(() {
                      final provider =
                      Provider.of<ProductProvider>(context, listen: false);
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      height: 60,
                      width: 70,
                      child: (widget.product.image == null)
                          ? Icon(Icons.image_not_supported_outlined,)
                          : Image.network(
                        '${widget.product.image}', // Replace with your image URL
                        fit: BoxFit
                            .cover, // Adjust the fit as needed (cover, contain, etc.)
                      )),
                  Text('(${widget.product.quantity})',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: primaryColor)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.product.name} ',
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(color: primaryColor),
                      ),
                      Text('${widget.product.category} ',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: Colors.grey)),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.product.total} DZD ',
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${widget.product.quantity} x ${widget.product.price} DZD ',
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
                        // to increment
                        onPressed: () {
                          setState(() {
                            final provider = Provider.of<ProductProvider>(context,
                                listen: false);
                            provider.incrementQuantity(
                                widget.product, widget.command);
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
                        // to decrement
                        onPressed: () {
                          setState(() async {
                            final provider = Provider.of<ProductProvider>(context,
                                listen: false);
                            bool confirmed;
                            if (widget.product.quantity == 1) {
                              if (widget.command.nbProduct == 1) {
                                // remove command
                                confirmed = await confirmationDialog
                                    .showConfirmationDialog(
                                    context, 'deleteCommand');
                              } else {
                                // remove product
                                confirmed = await confirmationDialog
                                    .showConfirmationDialog(
                                    context, 'deleteProduct');
                                if(confirmed){
                                  provider.removeProduct(widget.product, widget.command);
                                  widget.callback();
                                }
                              }
                            } else {
                              provider.decrementQuantity(
                                  widget.product, widget.command);
                              widget.callback();
                            }
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
        ),
        Divider(
          color: Colors.grey,
        )
      ],
    );
  }
}
