import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/constants/utils.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/command.dart';
import 'package:mobilino_app/models/product.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/providers/clients_map_provider.dart';
import 'package:mobilino_app/screens/home_page/deliver_page.dart';
import 'package:mobilino_app/screens/home_page/init_store_page.dart';
import 'package:mobilino_app/screens/home_page/notes_page/note_liste_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:provider/provider.dart';

import 'activities_pages/activity_list_page.dart';
import 'command_delivred_page.dart';
import 'command_page.dart';
import 'devis_page.dart';
import 'opportunity_page.dart';

class PiplineFragment extends StatefulWidget {
  const PiplineFragment({super.key});

  @override
  State<PiplineFragment> createState() => _PiplineFragmentState();
}

class _PiplineFragmentState extends State<PiplineFragment> {
  int selectedItemIndex = 0; // Index of the selected item
  // List<String> items = [
  //   'A visité',
  //   'Visité',
  //   'Livré',
  //   'Encaissé',
  //   'Livré & encaissé',
  //   'Annulée'
  // ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    print(
        'hkjjj: ${AppUrl.user.userId} ${AppUrl.filtredOpporunity.pipeline!.steps.length}');
    print('first stat: ${AppUrl.filtredOpporunity.pipeline!.steps.first.name}');
    print(
        'date: ${DateFormat('yyyy-MM-ddT00:00:00').format(AppUrl.selectedDate)}}');
    return Column(
      children: [
        // Visibility(
        //   visible: false,
        //   child: ListTile(
        //     title: Text(
        //       'Filtre des équipes',
        //       style: Theme.of(context).textTheme.headline6,
        //     ),
        //     subtitle: DropdownButtonFormField<Team>(
        //       decoration: InputDecoration(
        //           fillColor: Colors.white,
        //           filled: true,
        //           focusedBorder: OutlineInputBorder(
        //             borderRadius: BorderRadius.circular(12),
        //             borderSide: BorderSide(width: 2, color: primaryColor),
        //           ),
        //           enabledBorder: OutlineInputBorder(
        //             borderRadius: BorderRadius.circular(12),
        //             borderSide: BorderSide(width: 2, color: primaryColor),
        //           )),
        //       hint: Text(
        //         'Selectioner l\'équipe',
        //         style: Theme.of(context)
        //             .textTheme
        //             .headline4!
        //             .copyWith(color: Colors.grey),
        //       ),
        //       value: AppUrl.selectedTeam,
        //       onChanged: (newValue) {
        //         setState(() {
        //           AppUrl.selectedTeam = newValue!;
        //         });
        //       },
        //       items:
        //       AppUrl.user.teams.map<DropdownMenuItem<Team>>((Team value) {
        //         return DropdownMenuItem<Team>(
        //           value: value,
        //           child: Text(
        //             value.lib!,
        //             style: Theme.of(context).textTheme.headline4,
        //           ),
        //         );
        //       }).toList(),
        //     ),
        //   ),
        // ),
        Container(
          height: 50.0, // Adjust the height of the container
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppUrl.filtredOpporunity.pipeline!.steps.length,
            // Number of items
            itemBuilder: (context, index) {
              return Consumer<ClientsMapProvider>(
                  builder: (context, clients, snapshot) {
                List<Client> clientList = [];
                if (clients.mapClientsWithCommands.length > 0) {
                  print(
                      'zzzzzzz: ${clients.mapClientsWithCommands.first.stat} index: ${index + 1}');
                }
                clientList = provider.getOppoByStat(
                    index + AppUrl.filtredOpporunity.pipeline!.steps.first.id);
                // switch (index) {
                //   case 0:
                //     clientList = provider.toVisitedClients.toList();
                //     break;
                //   case 1:
                //     clientList = provider.visitedClients.toList();
                //     break;
                //   case 2:
                //     clientList = provider.delivredClients.toList();
                //     break;
                //   case 3:
                //     clientList = provider.paymentedClients.toList();
                //     break;
                //   case 4:
                //     clientList = provider.delivredAndPaymentedClients.toList();
                //     break;
                //   case 5:
                //     clientList = provider.canceledClients.toList();
                //     break;
                //   default:
                //     clientList = [];
                // }
                return GestureDetector(
                  onTap: () {
                    // Handle item tap
                    setState(() {
                      selectedItemIndex = index;
                    });
                  },
                  child: Container(
                    width: 120.0,
                    // Adjust the width of each item
                    margin: EdgeInsets.all(8.0),
                    decoration: selectedItemIndex == index
                        ? BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                            width: 2.5,
                            color: Theme.of(context).primaryColor,
                          )))
                        : BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                            width: 2.5,
                            color: Colors.transparent,
                          ))),
                    // color: selectedItemIndex == index
                    //     ? Colors.blue // Color when item is selected
                    //     : Colors.grey,
                    // Default color
                    child: Center(
                      child: Text(
                        '${AppUrl.filtredOpporunity.pipeline!.steps[index].name} (${clientList.length})',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
        SizedBox(height: 20.0),
        selectedItemIndex != -1
            ? Consumer<ClientsMapProvider>(
                builder: (context, clients, snapshot) {
                List<Client> clientList;
                switch (selectedItemIndex) {
                  case 0:
                    clientList = provider.toVisitedClients.toList();
                    break;
                  case 1:
                    clientList = provider.visitedClients.toList();
                    break;
                  case 2:
                    clientList = provider.delivredClients.toList();
                    break;
                  case 3:
                    clientList = provider.paymentedClients.toList();
                    break;
                  case 4:
                    clientList = provider.delivredAndPaymentedClients.toList();
                    break;
                  case 5:
                    clientList = provider.canceledClients.toList();
                    break;
                  default:
                    clientList = [];
                }
                clientList = provider.getOppoByStat(selectedItemIndex +
                    AppUrl.filtredOpporunity.pipeline!.steps.first.id);
                print('hhhhh: ${clientList.length}');
                return Expanded(
                    child: (clientList.isEmpty)
                        ? Center(
                            child: Text(
                            'Aucune opportunité !',
                            style: Theme.of(context).textTheme.headline3,
                          ))
                        : ListView.builder(
                            padding: EdgeInsets.all(12),
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) => InkWell(
                                onTap: () {
                                  // Navigator.pushNamed(
                                  //     context, ClientPage.routeName);
                                },
                                child: ClientItem(client: clientList[index])),
                            // separatorBuilder: (BuildContext context, int index) {
                            //   return Divider(
                            //     color: Colors.grey,
                            //   );
                            // },
                            itemCount: clientList.length));
              })
            // Container(
            //         height: 100.0, // Adjust the height of the container
            //         width: 100.0, // Adjust the width of the container
            //         color: Colors.purple, // Color of the container
            //         child: Center(
            //           child: Text(
            //             'Selected: $selectedItemIndex',
            //             style: TextStyle(color: Colors.white),
            //           ),
            //         ),
            //       )
            : Container(),
      ],
    );
    // return Consumer<ClientsMapProvider>(builder: (context, clients, child) {
    //   return ListView.builder(
    //       padding: EdgeInsets.all(12),
    //       physics: BouncingScrollPhysics(),
    //       itemBuilder: (context, index) => InkWell(
    //           onTap: () {
    //             // Navigator.pushNamed(
    //             //     context, ClientPage.routeName);
    //           },
    //           child: ClientItem(
    //               client: clients.mapClientsWithCommands.toList()[index])),
    //       // separatorBuilder: (BuildContext context, int index) {
    //       //   return Divider(
    //       //     color: Colors.grey,
    //       //   );
    //       // },
    //       itemCount: clients.mapClientsWithCommands.length);
    // });
  }
}

class ClientItem extends StatefulWidget {
  final Client client;

  const ClientItem({super.key, required this.client});

  @override
  State<ClientItem> createState() => _ClientItemState();
}

class _ClientItemState extends State<ClientItem> {
  Widget icon = Icon(Icons.shopping_cart_outlined);
  int respone = 200;
  double total = 0;

  // Function to fetch JSON data from an API
  Future<void> fetchData(Client client) async {
    print('stat: ${client.stat}');
    String url = AppUrl.commandsOfOpportunite +
        AppUrl.user.etblssmnt!.code! +
        '/' +
        widget.client.idOpp!;
    if (client.stat == 3 || client.stat == 5)
      url = AppUrl.deliveryOfOpportunite +
          AppUrl.user.etblssmnt!.code! +
          '/' +
          widget.client.idOpp!;
    print('url of CmdOfOpp $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res cmdOpp code : ${req.statusCode}");
    print("res cmdOpp body: ${req.body}");
    if (req.statusCode == 200) {
      respone = 200;
      icon = Image.asset('assets/caddie_rempli.png');
      var res = json.decode(req.body);
      widget.client.res = res;
      total = res['brut'];
      List<dynamic> data = res['lignes'];
      print('sizeof: ${data.length}');
      try {
        List<Product> products = [];
        await Future.forEach(data.toList(), (element) async {
          double remise = 0;
          double tva = 0;
          if (element['natTvatx'] != null) tva = element['natTvatx'];
          if (element['remise'] != null) remise = element['remise'];
          print('quantité: ${element['qte'].toString()}');
          double d = element['qte'];
          int quantity = d.toInt();
          // double dStock = element['stockDep'];
          // int quantityStock = dStock.toInt();
          var artCode = element['artCode'];
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
            var path = null;
            if (data.length > 0) {
              var item = data.first;
              print('item: ${item['path']}');
              path = AppUrl.baseUrl + item['path'];
              print('price: ${element['pPrv']} ${element['pBrut']} ');
              double total = 0;
              if (element['total'] != null)
                total = element['total'];
              else if (element['cout'] != null) total = element['cout'];
            }
            products.add(Product(
                quantity: quantity,
                price: element['pBrut'],
                total: total,
                remise: remise,
                tva: tva,
                id: element['artCode'],
                image: path,
                name: element['lib']));
          }
        }).then((value) {
          client.command = Command(
              res: res,
              id: res['numero'],
              date: DateTime.parse(res['date']),
              total: 0,
              paid: 0,
              products: products,
              nbProduct: products.length);
          print('size of products: ${products.length}');
        });

        // get image
      } catch (e, stackTrace) {
        print('Exception: $e');
        print('Stack trace: $stackTrace');
      }
    } else {
      url = AppUrl.devisOfOpportunite +
          AppUrl.user.etblssmnt!.code! +
          '/' +
          widget.client.idOpp!;
      print('url of devisOfOpp $url');
      req = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
      });
      print("res devisOpp code : ${req.statusCode}");
      print("res devisOpp body: ${req.body}");
      if (req.statusCode == 200) {
        respone = 200;
        icon = Icon(
          Icons.shopping_cart_checkout_sharp,
          color: Colors.orange,
        );
        print('rfrrfrfr: orange!');
        var res = json.decode(req.body);
        widget.client.res = res;
        total = res['brut'];
        List<dynamic> data = res['lignes'];
        print('sizeof: ${data.length}');
        try {
          List<Product> products = [];
          await Future.forEach(data.toList(), (element) async {
            double remise = 0;
            double tva = 0;
            if (element['natTvatx'] != null) tva = element['natTvatx'];
            if (element['remise'] != null) remise = element['remise'];
            print('quantité: ${element['qte'].toString()}');
            double d = element['qte'];
            int quantity = d.toInt();
            // double dStock = element['stockDep'];
            // int quantityStock = dStock.toInt();
            var artCode = element['artCode'];
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
              var path = null;
              if (data.length > 0) {
                var item = data.first;
                print('item: ${item['path']}');
                path = AppUrl.baseUrl + item['path'];
                print('price: ${element['pPrv']} ${element['pBrut']} ');
                double total = 0;
                if (element['total'] != null)
                  total = element['total'];
                else if (element['cout'] != null) total = element['cout'];
              }
              products.add(Product(
                  quantity: quantity,
                  price: element['pBrut'],
                  total: total,
                  remise: remise,
                  tva: tva,
                  id: element['artCode'],
                  image: path,
                  name: element['lib']));
            }
          }).then((value) {
            client.command = Command(
                res: res,
                id: res['numero'],
                date: DateTime.parse(res['date']),
                total: 0,
                paid: 0,
                products: products,
                nbProduct: products.length);
            print('size of products: ${products.length}');
            widget.client.command!.type = 'Devis';
          });

          // get image
        } catch (e, stackTrace) {
          print('Exception: $e');
          print('Stack trace: $stackTrace');
        }
      } else {
        respone = 404;
        client.command = null;
      }
    }
    print('command of ${client.name} ${client.id} is: ${client.command}');
    client.total = total.toString();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   showLoaderDialog(context);
    //   fetchData().then((value) {
    //     Navigator.pop(context);
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    double priorityrating = 0;
    double emergencyrating = 0;
    if (widget.client.priority != null)
      priorityrating = widget.client.priority!.toDouble();
    if (widget.client.emergency != null)
      emergencyrating = widget.client.emergency!.toDouble();
    print('lib: ${widget.client.priority}');
    // print('sss: ${widget.client.total}');
    // if (widget.client.total != null){
    //   if (double.parse(widget.client.total.toString()) > 0) {
    //   color = primaryColor;
    // } else if (double.parse(widget.client.total.toString()) < 0) {
    //   color = Colors.red;
    // }}
    return FutureBuilder(
        future: fetchData(widget.client),
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
                      margin: EdgeInsets.only(left: 15, top: 35, bottom: 35),
                      child: Text("Loading...")),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // There was an error in the future, handle it.
            print('Error: ${snapshot.hasError} ');
            return Text('Error: ${snapshot.error}');
          } else {
            print(
                'states is:: ${widget.client.stat} ${AppUrl.filtredOpporunity.pipeline!.steps.length}');
            print(
                'condition: ${(AppUrl.filtredOpporunity.pipeline!.steps.where((element) => element.id == widget.client.stat!).length == 0)}');
            if (AppUrl.filtredOpporunity.pipeline!.steps
                    .where((element) => element.id == widget.client.stat!)
                    .length ==
                0) return Container();
            return InkWell(
              onTap: () {
                PageNavigator(ctx: context).nextPage(
                    page: OpportunityPage(
                  client: widget.client,
                ));
              },
              child: Column(
                children: [
                  Container(
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.person_pin_rounded,
                          color: primaryColor,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (widget.client.lib != null)
                                ? Text(
                                    widget.client.lib!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .copyWith(color: primaryColor),
                                  )
                                : Text('Nom de l\'Affaire',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .copyWith(color: Colors.black)),
                            Text('Client: ${widget.client.name!}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(color: Colors.grey)),
                            Text('Ville : ${widget.client.city}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(color: Colors.grey)),
                            Row(
                              children: [
                                Icon(Icons.calendar_month_outlined, color: primaryColor, size: 20),
                                SizedBox(width: 7,),
                                Text('${DateFormat('dd-MM-yyyy')
                                    .format(widget.client.dateStart!)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith()),
                                SizedBox(width: 20,),
                                Icon(Icons.access_time, color: primaryColor, size: 20),
                                SizedBox(width: 7,),
                                Text('${DateFormat('HH:mm')
                                    .format(widget.client.dateStart!)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith()),
                              ],
                            ),
                            (widget.client.command != null)
                                ? Text(
                                  textAlign: TextAlign.end,
                                  '${AppUrl.formatter.format(widget.client.command!.total)} DZD',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .copyWith(
                                          color: color,
                                          fontWeight:
                                              FontWeight.normal),
                                )
                                : Text(
                                  '${AppUrl.formatter.format(0)} DZD',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .copyWith(
                                          color: color,
                                          fontWeight:
                                              FontWeight.normal),
                                  textAlign: TextAlign.end,
                                ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Priorité: ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                RatingBar.builder(
                                  ignoreGestures: true,
                                  initialRating: priorityrating,
                                  minRating: 1.0,
                                  maxRating: 5.0,
                                  itemCount: 5,
                                  itemSize: 25,
                                  // Number of stars
                                  itemBuilder: (context, index) => Icon(
                                    index >= priorityrating
                                        ? Icons.star_border_outlined
                                        : Icons.star,
                                    color: Colors.yellow,
                                  ),
                                  onRatingUpdate: (rating) {},
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Urgence: ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                RatingBar.builder(
                                  ignoreGestures: true,
                                  initialRating: emergencyrating,
                                  minRating: 1.0,
                                  maxRating: 5.0,
                                  itemCount: 5,
                                  itemSize: 25,
                                  // Number of stars
                                  itemBuilder: (context, index) => Icon(
                                    index >= emergencyrating
                                        ? Icons.star_border_outlined
                                        : Icons.star,
                                    color: Colors.yellow,
                                  ),
                                  onRatingUpdate: (rating) {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        Visibility(
                          visible: true,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    if (widget.client.phone != null)
                                      PhoneUtils()
                                          .makePhoneCall(widget.client.phone!);
                                    else
                                      _showAlertDialog(context,
                                          'Aucun numéro de téléphone pour ce client');
                                  },
                                  icon: Icon(
                                    Icons.call,
                                    color: primaryColor,
                                  )),
                              IconButton(
                                onPressed: () {
                                  print('client; ${widget.client.command}');
                                  if (respone == 200) {
                                    if (widget.client.command!.type ==
                                        'Devis') {
                                      PageNavigator(ctx: context).nextPage(
                                          page: DevisPage(
                                        client: widget.client,
                                      ));
                                    } else if (widget.client.stat == 3 ||
                                        widget.client.stat == 5)
                                      PageNavigator(ctx: context).nextPage(
                                          page: CommandDelivredPage(
                                        client: widget.client,
                                      ));
                                    else
                                      PageNavigator(ctx: context).nextPage(
                                          page: CommandPage(
                                        client: widget.client,
                                      ));
                                  } else
                                    PageNavigator(ctx: context).nextPage(
                                        page: StorePage(
                                      client: widget.client,
                                    ));
                                  //Navigator.pushNamed(context, '/home/command', arguments: client);
                                },
                                icon: (respone == 200)
                                    ? icon //Image.asset('assets/caddie_rempli.png')
                                    : icon,
                                //Icon(Icons.shopping_cart_outlined),
                                color: primaryColor,
                              ),
                              IconButton(
                                  onPressed: () {
                                    PageNavigator(ctx: context).nextPage(
                                        page: ActivityListPage(
                                      client: widget.client,
                                    ));
                                  },
                                  icon: Icon(
                                    Icons.local_activity_outlined,
                                    color: primaryColor,
                                  ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                  )
                ],
              ),
            );
          }
        });
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
          style: Theme.of(context).textTheme.headline6!,
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
                style: Theme.of(context)
                    .textTheme
                    .headline3!
                    .copyWith(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
