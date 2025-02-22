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
import 'package:mobilino_app/providers/clients_map_provider.dart';
import 'package:mobilino_app/screens/home_page/init_store_page.dart';
import 'package:mobilino_app/screens/home_page/notes_page/note_liste_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:provider/provider.dart';

import 'activities_pages/activity_list_page.dart';
import 'command_delivred_page.dart';
import 'command_page.dart';
import 'deliver_page.dart';
import 'devis_page.dart';
import 'opportunity_page.dart';

class ClientListFragment extends StatelessWidget {
  const ClientListFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientsMapProvider>(builder: (context, clients, child) {
      print('size:: ${clients.mapClientsWithCommands.length}');
      if (clients.mapClientsWithCommands.length == 0)
        return Center(
          child: Text(
            'Aucune opportunité !',
            style: Theme.of(context).textTheme.headline3,
          ),
        );
      else
        return ListView.builder(
            padding: EdgeInsets.all(12),
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) => InkWell(
                onTap: () {
                  // Navigator.pushNamed(
                  //     context, ClientPage.routeName);
                },
                child: ClientItem(
                    client: clients.mapClientsWithCommands.toList()[index])),
            // separatorBuilder: (BuildContext context, int index) {
            //   return Divider(
            //     color: Colors.grey,
            //   );
            // },
            itemCount: clients.mapClientsWithCommands.length);
    });
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
    }
    else {
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
      if(req.statusCode == 200){
        respone = 200;
        icon = Icon(Icons.shopping_cart_checkout_sharp, color: Colors.orange,);
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
      }
      else{
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
          } else{
            print('states is:: ${widget.client.stat} ${AppUrl.filtredOpporunity.pipeline!.steps.length}');
            print('condition: ${(AppUrl.filtredOpporunity.pipeline!.steps
                .where((element) => element.id == widget.client.stat!)
                .length ==
                0)}');
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
                              '${AppUrl.formatter.format(widget.client.command!.total)} DZD',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(
                                  color: color,
                                  fontWeight: FontWeight.normal),
                            )
                                : Text(
                              '${AppUrl.formatter.format(0)} DZD',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(
                                  color: color,
                                  fontWeight: FontWeight.normal),
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
                                    if(widget.client.command!.type == 'Devis'){
                                      PageNavigator(ctx: context).nextPage(
                                          page: DevisPage(
                                            client: widget.client,
                                          ));
                                    }else
                                    if (widget.client.stat == 3 ||
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
                                    : icon, //Icon(Icons.shopping_cart_outlined),
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
            );}
        });
  }
}
// class ClientItem extends StatefulWidget {
//   final Client client;
//
//   const ClientItem({super.key, required this.client});
//
//   @override
//   State<ClientItem> createState() => _ClientItemState();
// }
//
// class _ClientItemState extends State<ClientItem> {
//   Widget icon = Icon(Icons.shopping_cart_outlined);
//   int respone = 200;
//
//   // Function to fetch JSON data from an API
//   Future<void> fetchData(Client client) async {
//     print(
//         'url of CmdOfOpp ${AppUrl.commandsOfOpportunite + AppUrl.user.etblssmnt!.code! + '/' + widget.client.idOpp!}');
//     http.Response req = await http.get(
//         Uri.parse(AppUrl.commandsOfOpportunite +
//             AppUrl.user.etblssmnt!.code! +
//             '/' +
//             widget.client.idOpp!),
//         headers: {
//           "Accept": "application/json",
//           "content-type": "application/json; charset=UTF-8",
//           "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
//         });
//     print("res cmdOpp code : ${req.statusCode}");
//     print("res cmdOpp body: ${req.body}");
//     if (req.statusCode == 200) {
//       respone = 200;
//
//       icon = Image.asset('assets/caddie_rempli.png');
//
//       var res = json.decode(req.body);
//       List<dynamic> data = res['lignes'];
//       print('sizeof: ${data.length}');
//       try {
//         List<Product> products = [];
//         Future.forEach(data.toList(), (element) async {
//           print('quantité: ${element['qte'].toString()}');
//           double d = element['qte'];
//           int quantity = d.toInt();
//           // double dStock = element['stockDep'];
//           // int quantityStock = dStock.toInt();
//           var artCode = element['artCode'];
//           print('imghhh $artCode');
//           print('url: ${AppUrl.getUrlImage + '$artCode'}');
//           http.Response req = await http
//               .get(Uri.parse(AppUrl.getUrlImage + '$artCode'), headers: {
//             "Accept": "application/json",
//             "content-type": "application/json; charset=UTF-8",
//             "Referer": "http://"+AppUrl.user.company!+".localhost:4200/",
//           });
//           print("res imgArticle code : ${req.statusCode}");
//           print("res imgArticle body: ${req.body}");
//           if (req.statusCode == 200) {
//             List<dynamic> data = json.decode(req.body);
//             if (data.length > 0) {
//               var item = data.first;
//               print('item: ${item['path']}');
//               print('price: ${element['pPrv']} ${element['pBrut']} ');
//               double total = 0;
//               if (element['total'] != null)
//                 total = element['total'];
//               else if(element['cout'] != null)
//                 total = element['cout'];
//               products.add(Product(
//                   quantity: quantity,
//                   price: element['pBrut'],
//                   total: total,
//                   id: element['artCode'],
//                   image: AppUrl.baseUrl + item['path'],
//                   name: element['lib']));
//             }
//           }
//         }).then((value){
//           client.command = Command(
//               id: res['numero'],
//               date: DateTime.parse(res['date']),
//               total: 0,
//               paid: 0,
//               products: products,
//               nbProduct: products.length);
//         });
//
//         // get image
//       } catch (e, stackTrace) {
//         print('Exception: $e');
//         print('Stack trace: $stackTrace');
//       }
//     } else {
//       respone = 404;
//       client.command = null;
//     }
//     print('command of ${client.name } ${client.id} is: ${client.command}');
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   showLoaderDialog(context);
//     //   fetchData().then((value) {
//     //     Navigator.pop(context);
//     //   });
//     // });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Color color = Colors.grey;
//     if (double.parse(widget.client.total.toString()) > 0) {
//       color = primaryColor;
//     } else if (double.parse(widget.client.total.toString()) < 0) {
//       color = Colors.red;
//     }
//     return FutureBuilder(
//         future: fetchData(widget.client),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // Future is still running, return a loading indicator or some placeholder.
//             return Center(
//               child: Row(
//                 children: [
//                   CircularProgressIndicator(
//                     color: primaryColor,
//                   ),
//                   Container(
//                       margin: EdgeInsets.only(left: 15, top: 35, bottom: 35),
//                       child: Text("Loading...")),
//                 ],
//               ),
//             );
//           } else if (snapshot.hasError) {
//             // There was an error in the future, handle it.
//             print('Error: ${snapshot.hasError}');
//             return Text('Error: ${snapshot.error}');
//           } else
//             return Column(
//               children: [
//                 Container(
//                   height: 98,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Icon(
//                         Icons.person_pin_rounded,
//                         color: primaryColor,
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.client.name!,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .headline5!
//                                 .copyWith(color: primaryColor),
//                           ),
//                           Text(widget.client.city!,
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodyText1!
//                                   .copyWith(color: Colors.grey)),
//                         ],
//                       ),
//                       Text(
//                         widget.client.total! + ' DZD',
//                         style: Theme.of(context).textTheme.headline4!.copyWith(
//                             color: color, fontWeight: FontWeight.normal),
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           IconButton(
//                             onPressed: () {
//                               print('client; ${widget.client.command}');
//                               if (respone == 200){
//                                 PageNavigator(ctx: context).nextPage(
//                                     page: CommandPage(
//                                       client: widget.client,
//                                     ));
//                               }
//                               else
//                                 PageNavigator(ctx: context).nextPage(
//                                     page: StorePage(
//                                   client: widget.client,
//                                 ));
//                               //Navigator.pushNamed(context, '/home/command', arguments: client);
//                             },
//                             icon: (respone == 200)
//                                 ? Image.asset('assets/caddie_rempli.png')
//                                 : Icon(Icons.shopping_cart_outlined),
//                             color: primaryColor,
//                           ),
//                           IconButton(onPressed: (){
//                             PageNavigator(ctx: context).nextPage(
//                                 page: ActivityListPage(
//                                   client: widget.client,
//                                 ));
//                           }, icon: Icon(Icons.local_activity_outlined, color: primaryColor,))
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Divider(
//                   color: Colors.grey,
//                 )
//               ],
//             );
//         });
//   }
// }

// class ClientItem extends StatefulWidget {
//   final Client client;
//
//   const ClientItem({super.key, required this.client});
//
//   @override
//   State<ClientItem> createState() => _ClientItemState();
// }
//
// class _ClientItemState extends State<ClientItem> {
//   // List<String> items = [
//   //   'A visité',
//   //   'Visité',
//   //   'Livré',
//   //   'Encaissé',
//   //   'Livré & encaissé',
//   //   'Annulée'
//   // ];
//   Widget icon = Icon(Icons.shopping_cart_outlined);
//   int respone = 200;
//   double total = 0;
//
//   // Function to fetch JSON data from an API
//   Future<void> fetchData(Client client) async {
//     print('stat: ${client.stat}');
//     String url = AppUrl.commandsOfOpportunite +
//         AppUrl.user.etblssmnt!.code! +
//         '/' +
//         widget.client.idOpp!;
//     if (client.stat == 3 || client.stat == 5)
//       url = AppUrl.deliveryOfOpportunite +
//           AppUrl.user.etblssmnt!.code! +
//           '/' +
//           widget.client.idOpp!;
//     print('url of CmdOfOpp $url}');
//     http.Response req = await http.get(Uri.parse(url), headers: {
//       "Accept": "application/json",
//       "content-type": "application/json; charset=UTF-8",
//       "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
//     });
//     print("res cmdOpp code : ${req.statusCode}");
//     print("res cmdOpp body: ${req.body}");
//     if (req.statusCode == 200) {
//       respone = 200;
//       icon = Image.asset('assets/caddie_rempli.png');
//       var res = json.decode(req.body);
//       total = res['brut'];
//       List<dynamic> data = res['lignes'];
//       print('sizeof: ${data.length}');
//       try {
//         List<Product> products = [];
//         Future.forEach(data.toList(), (element) async {
//           print('quantité: ${element['qte'].toString()}');
//           double d = element['qte'];
//           int quantity = d.toInt();
//           // double dStock = element['stockDep'];
//           // int quantityStock = dStock.toInt();
//           var artCode = element['artCode'];
//           print('imghhh $artCode');
//           print('url: ${AppUrl.getUrlImage + '$artCode'}');
//           http.Response req = await http
//               .get(Uri.parse(AppUrl.getUrlImage + '$artCode'), headers: {
//             "Accept": "application/json",
//             "content-type": "application/json; charset=UTF-8",
//             "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/",
//           });
//           print("res imgArticle code : ${req.statusCode}");
//           print("res imgArticle body: ${req.body}");
//           if (req.statusCode == 200) {
//             List<dynamic> data = json.decode(req.body);
//             if (data.length > 0) {
//               var item = data.first;
//               print('item: ${item['path']}');
//               print('price: ${element['pPrv']} ${element['pBrut']} ');
//               double total = 0;
//               if (element['total'] != null)
//                 total = element['total'];
//               else if (element['cout'] != null) total = element['cout'];
//               products.add(Product(
//                   quantity: quantity,
//                   price: element['pBrut'],
//                   total: total,
//                   id: element['artCode'],
//                   image: AppUrl.baseUrl + item['path'],
//                   name: element['lib']));
//             }
//           }
//         }).then((value) {
//           client.command = Command(
//               res: res,
//               id: res['numero'],
//               date: DateTime.parse(res['date']),
//               total: 0,
//               paid: 0,
//               products: products,
//               nbProduct: products.length);
//         });
//
//         // get image
//       } catch (e, stackTrace) {
//         print('Exception: $e');
//         print('Stack trace: $stackTrace');
//       }
//     } else {
//       respone = 404;
//       client.command = null;
//     }
//     print('command of ${client.name} ${client.id} is: ${client.command}');
//     client.total = total.toString();
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   showLoaderDialog(context);
//     //   fetchData().then((value) {
//     //     Navigator.pop(context);
//     //   });
//     // });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Color color = Colors.grey;
//     double priorityrating = 0;
//     double emergencyrating = 0;
//     if (widget.client.priority != null)
//       priorityrating = widget.client.priority!.toDouble();
//     if (widget.client.emergency != null)
//       emergencyrating = widget.client.emergency!.toDouble();
//     print('lib: ${widget.client.priority}');
//     if (double.parse(widget.client.total.toString()) > 0) {
//       color = primaryColor;
//     } else if (double.parse(widget.client.total.toString()) < 0) {
//       color = Colors.red;
//     }
//     return FutureBuilder(
//         future: fetchData(widget.client),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // Future is still running, return a loading indicator or some placeholder.
//             return Center(
//               child: Row(
//                 children: [
//                   CircularProgressIndicator(
//                     color: primaryColor,
//                   ),
//                   Container(
//                       margin: EdgeInsets.only(left: 15, top: 35, bottom: 35),
//                       child: Text("Loading...")),
//                 ],
//               ),
//             );
//           } else if (snapshot.hasError) {
//             // There was an error in the future, handle it.
//             print('Error: ${snapshot.hasError}');
//             return Text('Error: ${snapshot.error}');
//           } else {
//             Color color = Colors.grey;
//             double priorityrating = 0;
//             double emergencyrating = 0;
//             if (widget.client.priority != null)
//               priorityrating = widget.client.priority!.toDouble();
//             if (widget.client.emergency != null)
//               emergencyrating = widget.client.emergency!.toDouble();
//             print('lib: ${widget.client.priority}');
//             if (double.parse(widget.client.total.toString()) > 0) {
//               color = primaryColor;
//             } else if (double.parse(widget.client.total.toString()) < 0) {
//               color = Colors.red;
//             }
//             print(
//                 'states is:: ${widget.client.stat} ${AppUrl.filtredOpporunity.pipeline!.steps.length}');
//             if (AppUrl.filtredOpporunity.pipeline!.steps
//                     .where((element) => element.id == widget.client.stat!)
//                     .length ==
//                 0) return Container();
//
//             String? s = AppUrl.filtredOpporunity.pipeline!.steps
//                 .where((element) => element.id == widget.client.stat!)
//                 .first
//                 .name;
//             return InkWell(
//               onTap: () {
//                 PageNavigator(ctx: context).nextPage(
//                     page: OpportunityPage(
//                   client: widget.client,
//                 ));
//               },
//               child: Column(
//                 children: [
//                   Container(
//                     height: 150,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Icon(
//                           Icons.person_pin_rounded,
//                           color: primaryColor,
//                         ),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   padding: EdgeInsets.only(left: 0),
//                                   width: 100,
//                                   child: Text(
//                                     '${widget.client.lib!}',
//                                     textAlign: TextAlign.center,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .headline3!
//                                         .copyWith(color: primaryColor),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                                 (widget.client.stat! > 0)
//                                     ? Text(
//                                         ' (${s})',
//                                         textAlign: TextAlign.center,
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .headline3!
//                                             .copyWith(
//                                                 fontWeight: FontWeight.normal,
//                                                 color: Colors.red),
//                                         maxLines: 2,
//                                         overflow: TextOverflow.ellipsis,
//                                       )
//                                     : Text(''),
//                               ],
//                             ),
//                             Text('Client: ${widget.client.name!}',
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodyText1!
//                                     .copyWith(color: Colors.grey)),
//                             Text('Ville : ${widget.client.city}',
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodyText1!
//                                     .copyWith(color: Colors.grey)),
//                             Text(
//                               '${AppUrl.formatter.format(double.parse(widget.client.total!))} DZD',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .headline4!
//                                   .copyWith(
//                                       color: color,
//                                       fontWeight: FontWeight.normal),
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   'Priorité: ',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .headline5!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 RatingBar.builder(
//                                   ignoreGestures: true,
//                                   initialRating: priorityrating,
//                                   minRating: 1.0,
//                                   maxRating: 5.0,
//                                   itemCount: 5,
//                                   itemSize: 25,
//                                   // Number of stars
//                                   itemBuilder: (context, index) => Icon(
//                                     index >= priorityrating
//                                         ? Icons.star_border_outlined
//                                         : Icons.star,
//                                     color: Colors.yellow,
//                                   ),
//                                   onRatingUpdate: (rating) {},
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   'Urgence: ',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .headline5!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 RatingBar.builder(
//                                   ignoreGestures: true,
//                                   initialRating: emergencyrating,
//                                   minRating: 1.0,
//                                   maxRating: 5.0,
//                                   itemCount: 5,
//                                   itemSize: 25,
//                                   // Number of stars
//                                   itemBuilder: (context, index) => Icon(
//                                     index >= emergencyrating
//                                         ? Icons.star_border_outlined
//                                         : Icons.star,
//                                     color: Colors.yellow,
//                                   ),
//                                   onRatingUpdate: (rating) {},
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         Visibility(
//                           visible: true,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               IconButton(
//                                   onPressed: () {
//                                     if (widget.client.phone != null)
//                                       PhoneUtils()
//                                           .makePhoneCall(widget.client.phone!);
//                                     else
//                                       _showAlertDialog(context,
//                                           'Aucun numéro de téléphone pour ce client');
//                                   },
//                                   icon: Icon(
//                                     Icons.call,
//                                     color: primaryColor,
//                                   )),
//                               IconButton(
//                                 onPressed: () {
//                                   print('client; ${widget.client.command}');
//                                   if (respone == 200) {
//                                     if (widget.client.stat == 3 ||
//                                         widget.client.stat == 5)
//                                       PageNavigator(ctx: context).nextPage(
//                                           page: CommandDelivredPage(
//                                         client: widget.client,
//                                       ));
//                                     else
//                                       PageNavigator(ctx: context).nextPage(
//                                           page: CommandPage(
//                                         client: widget.client,
//                                       ));
//                                   } else
//                                     PageNavigator(ctx: context).nextPage(
//                                         page: StorePage(
//                                       client: widget.client,
//                                     ));
//                                   //Navigator.pushNamed(context, '/home/command', arguments: client);
//                                 },
//                                 icon: (respone == 200)
//                                     ? Image.asset('assets/caddie_rempli.png')
//                                     : Icon(Icons.shopping_cart_outlined),
//                                 color: primaryColor,
//                               ),
//                               IconButton(
//                                   onPressed: () {
//                                     PageNavigator(ctx: context).nextPage(
//                                         page: ActivityListPage(
//                                       client: widget.client,
//                                     ));
//                                   },
//                                   icon: Icon(
//                                     Icons.local_activity_outlined,
//                                     color: primaryColor,
//                                   ))
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Divider(
//                     color: Colors.grey,
//                   )
//                 ],
//               ),
//             );
//           }
//         });
//   }
// }

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
