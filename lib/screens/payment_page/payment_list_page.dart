import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/constants/utils.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/payment.dart';
import 'package:mobilino_app/providers/clients_map_provider.dart';
import 'package:mobilino_app/providers/command_provider.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/widgets/add_payment_dialog.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/drawers/payment_drawer.dart';
import 'package:mobilino_app/screens/notes_page/title_note_dialog.dart';
import 'package:mobilino_app/widgets/payment_page.dart';
import 'package:provider/provider.dart';

import 'dialog_filtred_commands_clients.dart';
import 'payment_client_list_page.dart';

class PaymentListPage extends StatefulWidget {
  const PaymentListPage({super.key});

  static const String routeName = '/payment';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => PaymentListPage(),
    );
  }

  @override
  State<PaymentListPage> createState() => _PaymentListPageState();
}

class _PaymentListPageState extends State<PaymentListPage> {
  DateTime dateStart = DateTime.now();
  DateTime dateEnd = DateTime.now();

  @override
  void initState() {
    super.initState();
    dateStart = DateTime(
      dateStart.year,
      dateStart.month,
      dateStart.day,
      0, // new hour
      0, // new minute
      0, // new second
    );
    dateEnd = DateTime(
        dateEnd.year,
        dateEnd.month,
        dateEnd.day,
        23,
        // new hour
        59,
        // new minute
        59,
        // new second
        999);
    AppUrl.filtredCommandsClient.clients = [Client(id: '-1', name: 'Tout')];
    AppUrl.filtredCommandsClient.client =
        AppUrl.filtredCommandsClient.clients.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoaderDialog(context);
      _fetchData(context).then((value) {
        Navigator.pop(context);
      });
    });
  }

  // Function to fetch JSON data from an API
  // Future<void> fetchData(BuildContext context) async {
  //   final provider = Provider.of<ClientsMapProvider>(context, listen: false);
  //   provider.clientsList = [];
  //   final query = '';
  //   print('url getClients: ${AppUrl.tiersPage}');
  //   http.Response req = await http.get(Uri.parse(AppUrl.tiersPage), headers: {
  //     "Accept": "application/json",
  //     "content-type": "application/json; charset=UTF-8",
  //     "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
  //   });
  //   print("res article code : ${req.statusCode}");
  //   print("res article body: ${req.body}");
  //   if (req.statusCode == 200) {
  //     List<dynamic> data = json.decode(req.body);
  //     print('length ${data.length}');
  //     for (int i = 0; i < data.toList().length; i++) {
  //       var element = data.toList()[i];
  //       print('code client:  ${element['code']} ${element['rs']}');
  //       req = await http.get(
  //           Uri.parse(AppUrl.tiersEcheance +
  //               '${AppUrl.user.etblssmnt!.code}/${element['code']}'),
  //           headers: {
  //             "Accept": "application/json",
  //             "content-type": "application/json; charset=UTF-8",
  //             "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
  //           });
  //       print("res total code : ${req.statusCode}");
  //       print("res total body: ${req.body}");
  //       if (req.statusCode == 200) {
  //         double total = 0;
  //         List<dynamic> echeances = json.decode(req.body);
  //         echeances.toList().forEach((ech) {
  //           if (ech['echArecev'] != null && ech['echRecu'] != null) {
  //             total = total + ech['echArecev'] - ech['echRecu'];
  //           }
  //         });
  //         LatLng latLng;
  //         if (element['longitude'] == null || element['latitude'] == null)
  //           latLng = LatLng(1.354474457244855, 1.849465150689236);
  //         else
  //           latLng = LatLng(element['latitude'], element['longitude']);
  //         print('debggggg');
  //         provider.clientsList.add(Client(
  //             name: element['rs'],
  //             totalPay: total,
  //             location: latLng,
  //             type: element['type'],
  //             name2: element['rs2'],
  //             phone: element['tel1'],
  //             phone2: element['tel2'],
  //             city: element['ville'],
  //             id: element['code']));
  //       }
  //       provider.notifyListeners();
  //     }
  //   }
  //   print('size is : ${provider.clientsList.length}');
  //   provider.notifyListeners();
  // }
  Future<void> fetchData(BuildContext context) async {
    String url = AppUrl.userReglement +
        AppUrl.user.etblssmnt!.code! +
        '/' +
        AppUrl.filtredCommandsClient.collaborateur!.salCode!;
    //'SAL004';
    print('urlPay: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res payment code : ${req.statusCode}");
    print("res payment body: ${req.body}");
    final provider = Provider.of<CommandProvider>(context, listen: false);
    if (req.statusCode == 200) {
      // add commands
      provider.paymentList = [];
      List<dynamic> data = json.decode(req.body);
      //data.toList().forEach((element) {
      for (int i = 0; i < data.length; i++) {
        var element = data[i];
        String dateString = element['regDate'];
        DateTime parsedDate = DateTime.parse(dateString);
        if (AppUrl.isDateBetween(parsedDate, dateStart, dateEnd) == false)
          continue;
        if (AppUrl.filtredCommandsClient.client!.id != '-1') {
          if (AppUrl.filtredCommandsClient.client!.id != element['pcfCode'])
            continue;
        }
        print('elementIS: ${element}');
        req = await http
            .get(Uri.parse(AppUrl.getOneTier + element['pcfCode']), headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
        print("res tier code: ${req.statusCode}");
        print("res tier body: ${req.body}");
        if (req.statusCode == 200) {
          var res = json.decode(req.body);
          LatLng latLng;
          if (res['longitude'] == null || res['latitude'] == null)
            latLng = LatLng(1.354474457244855, 1.849465150689236);
          else
            latLng = LatLng(res['latitude'], res['longitude']);
          String typeClient = 'Client';
          if (res['type'] == 'P') typeClient = 'Prospect';
          if (res['type'] == 'F') typeClient = 'Fournisseur';
          Client client = new Client(
            id: res['code'],
            type: res['type'],
            name: res['rs'],
            name2: res['rs2'],
            phone2: res['tel2'],
            phone: res['tel1'],
            city: res['ville'],
            location: latLng,
          );
          provider.paymentList.add(Payment(
              date: parsedDate,
              code: element['regNumero'],
              total: element['regRecu'],
              paid: 0,
              client: client,
              type: element['regType'],
              currentPaid: 0));
          provider.notifyListeners();
        }
      }
      //});
    }
  }

  Future<void> _fetchData(BuildContext context) async {
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.filtredClients = [];
    http.Response req = await http.get(
        Uri.parse(AppUrl.tiersPage + '?PageNumber=1&PageSize=20'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
    print("res tiers code : ${req.statusCode}");
    print("res tiers body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      for (int i = 0; i < data.toList().length; i++) {
        var element = data.toList()[i];
        print('code client:  ${element['code']}');
        req = await http.get(
            Uri.parse(AppUrl.tiersEcheance +
                '${AppUrl.user.etblssmnt!.code}/${element['code']}'),
            headers: {
              "Accept": "application/json",
              "content-type": "application/json; charset=UTF-8",
              "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
            });
        print("res total code : ${req.statusCode}");
        print("res total body: ${req.body}");
        if (req.statusCode == 200) {
          double total = 0;
          List<dynamic> echeances = json.decode(req.body);
          echeances.toList().forEach((ech) {
            total = total + ech['echArecev'] - ech['echRecu'];
            print('ech: ${ech['echArecev']}');
          });
          LatLng latLng;
          if (element['longitude'] == null || element['latitude'] == null) {
            latLng = LatLng(1.354474457244855, 1.849465150689236);
          } else {
            try {
              latLng = LatLng(element['latitude'], element['longitude']);
            } catch (e) {
              print('latlong err: $e');
              latLng = LatLng(1.354474457244855, 1.849465150689236);
            }
          }
          String? familleId = element['familleId'];
          String? sFamilleId = element['sFamilleId'];
          print('TiersFams: ${element['familleId']} ${element['sFamilleId']}');
          if (familleId != null) {
            req = await http
                .get(Uri.parse(AppUrl.getFamilly + '$familleId'), headers: {
              "Accept": "application/json",
              "content-type": "application/json; charset=UTF-8",
              "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
            });
            print("res familleId code : ${req.statusCode}");
            print("res familleId body: ${req.body}");
            if (req.statusCode == 200) {
              print('ddd: ${json.decode(req.body)['lib']}');
              familleId = json.decode(req.body)['lib'];
            }
          }

          if (sFamilleId != null) {
            req = await http
                .get(Uri.parse(AppUrl.getSFamilly + '$sFamilleId'), headers: {
              "Accept": "application/json",
              "content-type": "application/json; charset=UTF-8",
              "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
            });
            print("res sfamilleId code : ${req.statusCode}");
            print("res sfamilleId body: ${req.body}");
            if (req.statusCode == 200) {
              sFamilleId = json.decode(req.body)['lib'];
            }
          }
          print('TiersFams!!: $familleId $sFamilleId');
          AppUrl.filtredCommandsClient.clients.add(Client(
              name: element['rs'],
              totalPay: total,
              location: latLng,
              familleId: familleId,
              sFamilleId: sFamilleId,
              type: element['type'],
              name2: element['rs2'],
              phone: element['tel1'],
              phone2: element['tel2'],
              city: element['ville'],
              id: element['code']));
          //provider.notifyListeners();
        }
      }
    }
    provider.notifyListeners();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateStart,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            // Day color
            buttonTheme: ButtonThemeData(
              colorScheme: ColorScheme.light(
                primary: primaryColor, // Change the color here
              ),
            ),
            colorScheme: ColorScheme.light(primary: primaryColor)
                .copyWith(secondary: primaryColor),
            // Button text color
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dateStart = DateTime(picked.year, picked.month, picked.day, 0, 0, 0);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateEnd,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            // Day color
            buttonTheme: ButtonThemeData(
              colorScheme: ColorScheme.light(
                primary: primaryColor, // Change the color here
              ),
            ),
            colorScheme: ColorScheme.light(primary: primaryColor)
                .copyWith(secondary: primaryColor),
            // Button text color
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dateEnd =
            DateTime(picked.year, picked.month, picked.day, 23, 59, 59, 999);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('sal: ${AppUrl.user.salCode} etb: ${AppUrl.user.etblssmnt!.code}');
    print('start: $dateStart end : $dateEnd');
    return FutureBuilder(
        future: fetchData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Future is still running, return a loading indicator or some placeholder.
            return AlertDialog(
              content: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text("Loading..."),
                ],
              ),
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
            return Scaffold(
              appBar: AppBar(
                iconTheme: IconThemeData(
                  color: Colors.white, // Set icon color to white
                ),
                backgroundColor: Theme.of(context).primaryColor,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encaissements',
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Client : ${AppUrl.filtredCommandsClient.client!.name}',
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Collaborateur : ${AppUrl.filtredCommandsClient.collaborateur!.userName}',
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                      onPressed: () {
                        //_showDatePicker(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return FiltredCommandsClientDialog();
                          },
                        ).then((value) {
                          setState(() {});
                        });
                      },
                      icon: Icon(
                        Icons.sort,
                        color: Colors.white,
                      ))
                  // IconButton(
                  //   icon: Icon(
                  //     Icons.search,
                  //     color: Colors.white,
                  //   ),
                  //   onPressed: () {
                  //     showSearch(
                  //         context: context,
                  //         delegate: ClientSearchDelegate(),
                  //         query: '');
                  //   },
                  // ),
                ],
              ),
              drawer: DrawerPaymentPage(),
              floatingActionButton: FloatingActionButton(
                backgroundColor: primaryColor,
                onPressed: () {
                  PageNavigator(ctx: context)
                      .nextPage(page: PaymentClientListPage());
                },
                child: Icon(
                  Icons.add_card_outlined,
                  color: Colors.white,
                ),
              ),
              body: Column(
                children: [
                  Container(
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
                        GestureDetector(
                          onTap: () {
                            _selectStartDate(context);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                color: primaryColor,
                              ),
                              Text(
                                'Du ${DateFormat('dd-MM-yyyy').format(dateStart)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(color: primaryColor),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _selectEndDate(context);
                          },
                          child: Row(
                            children: [
                              Text(
                                'Au ${DateFormat('dd-MM-yyyy').format(dateEnd)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(color: primaryColor),
                              ),
                              Icon(
                                Icons.calendar_month_outlined,
                                color: primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<CommandProvider>(
                      builder: (context, commands, snapshot) {
                    return Expanded(
                      child: (commands.paymentList.length != 0)
                          ? ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                print(
                                    'size of paymentList: ${commands.paymentList.length}');
                                return CommandItem(
                                  payment: commands.paymentList[index],
                                );
                              },
                              itemCount: commands.paymentList.length)
                          : Center(
                              child: Text(
                              'Aucun règlement',
                              style: Theme.of(context).textTheme.headline6,
                            )),
                    );
                  }),
                ],
              ),
            );
        });
  }
}

class CommandItem extends StatelessWidget {
  final Payment payment;

  const CommandItem({
    super.key,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    late Icon icon;
    print('typeReg: ${payment.type}');
    if (payment.type == 'ESP' || payment.type == 'E') {
      icon = Icon(
        Icons.money_outlined,
        color: primaryColor,
      );
    } else {
      icon = Icon(
        Icons.payment_outlined,
        color: primaryColor,
      );
    }
    Color color = primaryColor;
    if (payment.client!.type == 'C') color = Colors.blue;
    if (payment.client!.type == 'F') color = Colors.red;
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: 50,
          child: Row(
            children: [
              icon,
              SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    child: Row(
                      children: [
                        Text(
                          '${payment.type} ',
                          style:
                              Theme.of(context).textTheme.headline4!.copyWith(
                                    color: Colors.black,
                                  ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          '${payment.client!.name} ',
                          style:
                              Theme.of(context).textTheme.headline4!.copyWith(
                                    color: color,
                                  ),
                        ),
                      ],
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        '${DateFormat('yyyy-MM-dd hh:mm:ss').format(payment.date!)}', // todo
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(color: Colors.grey)),
                  ),
                ],
              ),
              SizedBox(
                width: 20,
              ),
              Center(
                  child: Text(
                '${AppUrl.formatter.format(payment.total)} DZD', // todo
                style: Theme.of(context).textTheme.headline4!.copyWith(
                      color: black,
                      fontWeight: FontWeight.normal,
                    ),
              )),
            ],
          ),
        ),
        Divider(
          color: Colors.grey,
        )
      ],
    );
  }
}

// class ClientItem extends StatelessWidget {
//   final Client client;
//
//   const ClientItem({super.key, required this.client});
//
//   @override
//   Widget build(BuildContext context) {
//     Color color = Colors.grey;
//     Color txtColor = primaryColor;
//     if (client.type == 'C') txtColor = Colors.blue;
//     if (client.type == 'F') txtColor = Colors.red;
//     if (client.totalPay! > 0) {
//       color = primaryColor;
//     } else if (client.totalPay! < 0) {
//       color = Colors.red;
//     }
//     return InkWell(
//       onTap: () {
//         PageNavigator(ctx: context).nextPage(
//             page: PaymentPage(
//           client: client,
//         ));
//         // showDialog(
//         //     context: context,
//         //     builder: (BuildContext context) {
//         //       return PaymentDialog();
//         //     });
//       },
//       child: Column(
//         children: [
//           Container(
//             width: double.infinity,
//             height: 80,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Icon(
//                   Icons.person_pin_rounded,
//                   color: primaryColor,
//                 ),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   //crossAxisAlignment: CrossAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '${client.name} ',
//                       style: Theme.of(context)
//                           .textTheme
//                           .headline5!
//                           .copyWith(color: txtColor),
//                     ),
//                     Text('${client.city}',
//                         style: Theme.of(context)
//                             .textTheme
//                             .bodyText1!
//                             .copyWith(color: Colors.grey)),
//                   ],
//                 ),
//                 Text(
//                   '${AppUrl.formatter.format(client.totalPay)} DZD',
//                   style: Theme.of(context)
//                       .textTheme
//                       .headline4!
//                       .copyWith(color: color, fontWeight: FontWeight.normal),
//                 ),
//                 Stack(
//                   children: [
//                     Align(
//                       alignment: Alignment.topRight,
//                       child: IconButton(
//                           onPressed: () {
//                             if (client.phone != null)
//                               PhoneUtils().makePhoneCall(client.phone!);
//                             else
//                               showAlertDialog(context,
//                                   'Aucun numéro de téléphone pour ce client');
//                           },
//                           icon: Icon(
//                             Icons.call_outlined,
//                             color: Colors.grey,
//                             size: 20,
//                           )),
//                     ),
//                     Align(
//                       alignment: Alignment.bottomLeft,
//                       child: IconButton(
//                           onPressed: () {
//                             if (client.phone != null)
//                               PhoneUtils().makeSms(client.phone!);
//                             else
//                               showAlertDialog(context,
//                                   'Aucun numéro de téléphone pour ce client');
//                           },
//                           icon: Icon(
//                             Icons.mail_outline,
//                             color: Colors.grey,
//                             size: 20,
//                           )),
//                     )
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Divider(
//             color: Colors.grey,
//           )
//         ],
//       ),
//     );
//   }
// }
//
// class ClientSearchDelegate extends SearchDelegate {
//   // final Client client;
//   // final VoidCallback callback;
//
//   ClientSearchDelegate();
//
//   @override
//   List<Widget>? buildActions(BuildContext context) => [
//         IconButton(
//             onPressed: () {
//               if (query.isNotEmpty)
//                 query = '';
//               else
//                 close(context, null);
//             },
//             icon: Icon(Icons.clear))
//       ];
//
//   @override
//   Widget? buildLeading(BuildContext context) {
//     return IconButton(
//         onPressed: () {
//           close(context, null);
//         },
//         icon: Icon(Icons.arrow_back));
//   }
//
//   @override
//   Widget buildResults(BuildContext context) {
//     final provider = Provider.of<ClientsMapProvider>(context, listen: false);
//     provider.filtredClients = [];
//     return FutureBuilder(
//       future: fetchData(context),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           // Future is still running, return a loading indicator or some placeholder.
//           return AlertDialog(
//             content: Row(
//               //mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 CircularProgressIndicator(
//                   color: primaryColor,
//                 ),
//                 SizedBox(
//                   width: 30,
//                 ),
//                 Text("Loading..."),
//               ],
//             ),
//           );
//         } else if (snapshot.hasError) {
//           // There was an error in the future, handle it.
//           print('Error: ${snapshot.hasError} ${snapshot.error} ');
//           return AlertDialog(
//             content: Row(
//               //mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Icon(
//                   Icons.error_outline,
//                   color: Colors.red,
//                 ),
//                 SizedBox(
//                   width: 30,
//                 ),
//                 // Text('Error: ${snapshot.error}')
//                 Text('Nous sommes désolé, la qualité de votre connexion ne vous permet pas de vous connecter à votre serveur.'
//' Veuillez réessayer ultérieurement. Merci'),
//               ],
//             ),
//           );
//         } else {
//           List<Client> list = [];
//           for (Client client in provider.filtredClients) {
//             try {
//               if (client.name!.toLowerCase().contains(query.toLowerCase()) ||
//                   client.phone!.toLowerCase().contains(query.toLowerCase()) ||
//                   client.total!.toLowerCase().contains(query.toLowerCase()) ||
//                   client.city!.toLowerCase().contains(query.toLowerCase())) {
//                 list.add(client);
//               }
//             } catch (_) {
//               continue;
//             }
//           }
//           Set<Client> uniqueClientSet = list.toSet();
//           List<Client> uniqueClientList = uniqueClientSet.toList();
//           if (uniqueClientList.isEmpty)
//             return Center(
//               child: Text(
//                 'Aucune résultat !',
//                 style: Theme.of(context).textTheme.headline2,
//               ),
//             );
//           else
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ListView.builder(
//                   physics: BouncingScrollPhysics(),
//                   itemBuilder: (context, index) => ClientItem(
//                         client: uniqueClientList[index],
//                       ),
//                   itemCount: uniqueClientList.length),
//             );
//         }
//       },
//     );
//   }
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     final provider = Provider.of<ClientsMapProvider>(context, listen: false);
//     provider.filtredClients = [];
//     return FutureBuilder(
//       future: fetchData(context),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           // Future is still running, return a loading indicator or some placeholder.
//           return AlertDialog(
//             content: Row(
//               //mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 CircularProgressIndicator(
//                   color: primaryColor,
//                 ),
//                 SizedBox(
//                   width: 30,
//                 ),
//                 Text("Loading..."),
//               ],
//             ),
//           );
//         } else if (snapshot.hasError) {
//           // There was an error in the future, handle it.
//           print('Error: ${snapshot.hasError} ${snapshot.error} ');
//           return AlertDialog(
//             content: Row(
//               //mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Icon(
//                   Icons.error_outline,
//                   color: Colors.red,
//                 ),
//                 SizedBox(
//                   width: 30,
//                 ),
//                 // Text('Error: ${snapshot.error}')
//                 Text('Nous sommes désolé, la qualité de votre connexion ne vous permet pas de vous connecter à votre serveur.'
//   ' Veuillez réessayer ultérieurement. Merci'),
//               ],
//             ),
//           );
//         } else {
//           List<Client> list = [];
//           for (Client client in provider.filtredClients) {
//             try {
//               if (client.name!.toLowerCase().contains(query.toLowerCase()) ||
//                   client.phone!.toLowerCase().contains(query.toLowerCase()) ||
//                   client.total!.toLowerCase().contains(query.toLowerCase()) ||
//                   client.city!.toLowerCase().contains(query.toLowerCase())) {
//                 list.add(client);
//               }
//             } catch (_) {
//               continue;
//             }
//           }
//           Set<Client> uniqueClientSet = list.toSet();
//           List<Client> uniqueClientList = uniqueClientSet.toList();
//           if (uniqueClientList.isEmpty)
//             return Center(
//               child: Text(
//                 'Aucune résultat !',
//                 style: Theme.of(context).textTheme.headline2,
//               ),
//             );
//           else
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ListView.builder(
//                   physics: BouncingScrollPhysics(),
//                   itemBuilder: (context, index) => ClientItem(
//                         client: uniqueClientList[index],
//                       ),
//                   itemCount: uniqueClientList.length),
//             );
//         }
//       },
//     );
//   }
//
//   // Function to fetch JSON data from an API
//   Future<void> fetchData(BuildContext context) async {
//     final provider = Provider.of<ClientsMapProvider>(context, listen: false);
//     provider.filtredClients = [];
//     http.Response req = await http.get(
//         Uri.parse(AppUrl.tiersPage + '?PageNumber=1&rs=$query&PageSize=20'),
//         headers: {
//           "Accept": "application/json",
//           "content-type": "application/json; charset=UTF-8",
//           "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
//         });
//     print("res article code : ${req.statusCode}");
//     print("res article body: ${req.body}");
//     if (req.statusCode == 200) {
//       List<dynamic> data = json.decode(req.body);
//       for (int i = 0; i < data.toList().length; i++) {
//         var element = data.toList()[i];
//         req = await http.get(
//             Uri.parse(AppUrl.tiersEcheance +
//                 '${AppUrl.user.etblssmnt!.code}/${element['code']}'),
//             headers: {
//               "Accept": "application/json",
//               "content-type": "application/json; charset=UTF-8",
//               "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
//             });
//         print("res total code : ${req.statusCode}");
//         print("res total body: ${req.body}");
//         if (req.statusCode == 200) {
//           double total = 0;
//           List<dynamic> echeances = json.decode(req.body);
//           echeances.toList().forEach((ech) {
//             if (ech['echArecev'] != null && ech['echRecu'] != null) {
//               total = total + ech['echArecev'] - ech['echRecu'];
//             }
//           });
//           print('code client:  ${element['ville']}');
//           LatLng latLng;
//           if (element['longitude'] == null || element['latitude'] == null)
//             latLng = LatLng(1.354474457244855, 1.849465150689236);
//           else
//             latLng = LatLng(element['latitude'], element['longitude']);
//           provider.filtredClients.add(Client(
//               name: element['rs'],
//               location: latLng,
//               totalPay: total,
//               type: element['type'],
//               name2: element['rs2'],
//               phone: element['tel1'],
//               phone2: element['tel2'],
//               city: element['ville'],
//               id: element['code']));
//         }
//       }
//     }
//     print('size is : ${provider.clientsList.length}');
//     provider.notifyListeners();
//   }
// }

showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Container(
        width: 200, height: 100, child: Image.asset('assets/CRM-Loader.gif')),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
