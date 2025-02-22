import 'dart:convert';

import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/command.dart';
import 'package:mobilino_app/models/product.dart';
import 'package:mobilino_app/providers/command_provider.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:provider/provider.dart';

import 'deliver_page.dart';

class CommandsHistoryFragment extends StatefulWidget {
  Client client;

  CommandsHistoryFragment({super.key, required this.client});

  @override
  State<CommandsHistoryFragment> createState() =>
      _CommandsHistoryFragmentState();
}

class _CommandsHistoryFragmentState extends State<CommandsHistoryFragment> {
  AnimateIconController controller = AnimateIconController();
  DateTime dateStart = DateTime.now();
  DateTime dateEnd = DateTime.now();

  // Function to fetch JSON data from an API
  // Future<void> fetchData() async {
  //   var body = jsonEncode({
  //     "filter": null,
  //     "equipe": null,
  //     "tiers": widget.client.id,
  //     "priorite": null,
  //     "urgence": null,
  //     "collaborateur": AppUrl.user.userId,
  //     "collaborateurs": [],
  //     "dateDebut": null,
  //     "dateFin": null
  //   });
  //   print('idClient: ${widget.client.id}');
  //   http.Response req = await http
  //       .post(Uri.parse(AppUrl.opportunitiesFiltred), body: body, headers: {
  //     "Accept": "application/json",
  //     "content-type": "application/json; charset=UTF-8",
  //     "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
  //   });
  //   print("res opp code : ${req.statusCode}");
  //   print("res opp body: ${req.body}");
  //   final provider = Provider.of<CommandProvider>(context, listen: false);
  //   if (req.statusCode == 200) {
  //     provider.commandList = [];
  //     List<dynamic> data = json.decode(req.body);
  //     print('size of opportunities : ${data.toList().length}');
  //     data.toList().forEach((element) async {
  //       print('id opp:  ${element['code']}');
  //       getCommandOpp(element['code']);
  //     });
  //   }
  // }
  // Future<bool?> getCommandOpp(String id) async {
  //   print(
  //       'url of CmdOfOpp ${AppUrl.commandsOfOpportunite + AppUrl.user.etblssmnt!.code! + '/' + id}');
  //   http.Response req = await http.get(
  //       Uri.parse(AppUrl.commandsOfOpportunite +
  //           AppUrl.user.etblssmnt!.code! +
  //           '/' +
  //           id),
  //       headers: {
  //         "Accept": "application/json",
  //         "content-type": "application/json; charset=UTF-8",
  //         "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
  //       });
  //   print("res cmdOpp code : ${req.statusCode}");
  //   print("res cmdOpp body: ${req.body}");
  //   final provider = Provider.of<CommandProvider>(context, listen: false);
  //   if (req.statusCode == 200) {
  //     var res = json.decode(req.body);
  //     List<dynamic> data = res['lignes'];
  //     print('sizeof: ${data.length}');
  //     try {
  //       List<Product> products = [];
  //       Future.forEach(data.toList(), (element) async {
  //         print('quantité: ${element['qte'].toString()}');
  //         double d = element['qte'];
  //         int quantity = d.toInt();
  //         double dStock = element['stockDep'];
  //         int quantityStock = d.toInt();
  //         var artCode = element['artCode'];
  //         print('imghhh $artCode');
  //         print('url: ${AppUrl.getUrlImage + '$artCode'}');
  //         http.Response req = await http
  //             .get(Uri.parse(AppUrl.getUrlImage + '$artCode'), headers: {
  //           "Accept": "application/json",
  //           "content-type": "application/json; charset=UTF-8",
  //           "Referer": "http://"+AppUrl.user.company!+".localhost:4200/",
  //         });
  //         print("res imgArticle code : ${req.statusCode}");
  //         print("res imgArticle body: ${req.body}");
  //         if (req.statusCode == 200) {
  //           List<dynamic> data = json.decode(req.body);
  //           if (data.length > 0) {
  //             var item = data.first;
  //             print('item: ${item['path']}');
  //             products.add(Product(
  //                 quantity: quantity,
  //                 quantityStock: quantityStock,
  //                 price: element['pVte'],
  //                 total: element['total'],
  //                 id: element['artCode'],
  //                 image: AppUrl.baseUrl + item['path'],
  //                 name: element['lib']));
  //           }
  //         }
  //       }).then((value){
  //         provider.commandList.add(Command(
  //             id: res['numero'],
  //             date: DateTime.parse(res['date']),
  //             total: 0,
  //             paid: 0,
  //             products: products,
  //             nbProduct: products.length));
  //       });
  //
  //       return true;
  //       // get image
  //     } catch (e, stackTrace) {
  //       print('Exception: $e');
  //       print('Stack trace: $stackTrace');
  //
  //     }
  //   } else {
  //   }
  //
  //   return false;
  // }
  Future<void> fetchData() async {
    String url = AppUrl.getMyCommands +
        '${AppUrl.user.etblssmnt!.code}/${AppUrl.filtredCommandsClient.collaborateur!.salCode}';
    print('urlis: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res myCommands code : ${req.statusCode}");
    print("res myCommands body : ${req.body}");
    final provider = Provider.of<CommandProvider>(context, listen: false);
    if (req.statusCode == 200) {
      provider.commandList = [];
      List<dynamic> data = json.decode(req.body);
      print('size commands : ${data.toList().length}');
      //data.toList().forEach((element) async {
      for (int i = 0; i < data.length; i++) {
        var element = data[i];
        if (AppUrl.isDateBetween(
                DateTime.parse(element['date']), dateStart, dateEnd) ==
            false) continue;
        if (AppUrl.filtredCommandsClient.client!.id != '-1') {
          if (AppUrl.filtredCommandsClient.client!.id !=
              element['pcfCode']) continue;
        }
        print('type is: ${element['type']}');
        if (element['stype'] == 'C' && element['type'] == 'V') {
          String pcfCode = element['pcfCode'];
          http.Response req =
              await http.get(Uri.parse(AppUrl.getOneTier + pcfCode), headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
            "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
          });
          print("res oneTier code : ${req.statusCode}");
          print("res oneTier body: ${req.body}");
          if (req.statusCode == 200) {
            var res = json.decode(req.body);
            print('code client:  ${res['code']}');
            print('brut cmd  ${element['brut']}');
            LatLng latLng;
            if (res['longitude'] == null || res['latitude'] == null)
              latLng = LatLng(1.354474457244855, 1.849465150689236);
            else
              latLng = LatLng(res['latitude'], res['longitude']);
            Client client = Client(
                name: res['rs'],
                location: latLng,
                name2: res['rs2'],
                phone: res['tel1'],
                phone2: res['tel2'],
                city: res['ville'],
                id: res['code']);
            provider.commandList.add(Command(
                id: element['numero'],
                date: DateTime.parse(element['date']),
                total: element['brut'],
                deliver: element['codeChauffeur'],
                paid: 0,
                products: [],
                client: client,
                nbProduct: 0));
            provider.notifyListeners();
          }
        }
      }

      // });
    }
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
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
                SizedBox(
                  height: 20,
                ),
                Consumer<CommandProvider>(
                    builder: (context, commands, snapshot) {
                  return Expanded(
                    child: (commands.commandList.length != 0)
                        ? ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              print(
                                  'size of commandList: ${commands.commandList.length}');
                              return CommandItem(
                                client: commands.commandList[index].client!,
                                command: commands.commandList[index],
                              );
                            },
                            itemCount: commands.commandList.length)
                        : Center(
                            child: Text(
                            'Aucune commande',
                            style: Theme.of(context).textTheme.headline6,
                          )),
                  );
                }),
              ],
            );
        });
  }
}

class CommandItem extends StatelessWidget {
  final Client client;
  final Command command;

  const CommandItem({super.key, required this.command, required this.client});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        client.command = command;
        PageNavigator(ctx: context).nextPage(
            page: DeliverdPage(
          client: client,
          type: 'Commande',
        ));
      },
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 50,
            child: Row(
              children: [
                Icon(
                  Icons.file_copy_outlined,
                  color: primaryColor,
                ),
                SizedBox(
                  width: 20,
                ),
                Center(
                  child: Container(
                    width: 100,
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // Limit the number of lines
                      '${command.client!.name} ',
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                            color: black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      child: Text(
                        '${AppUrl.formatter.format(command.total)} DZD',
                        style: Theme.of(context).textTheme.headline4!.copyWith(
                              color: primaryColor,
                            ),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          '${DateFormat('yyyy-MM-dd  HH:mm:ss').format(command.date)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: Colors.grey)),
                    ),
                  ],
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
}
