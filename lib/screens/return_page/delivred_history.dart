import 'dart:convert';

import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/command.dart';
import 'package:mobilino_app/providers/command_provider.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:provider/provider.dart';
import 'new_command_return_page.dart';
//import 'deliver_page.dart';

class DelivredHistoryFragment extends StatefulWidget {
  Client client;

  DelivredHistoryFragment({super.key, required this.client});

  @override
  State<DelivredHistoryFragment> createState() =>
      _DelivredHistoryFragmentState();
}

class _DelivredHistoryFragmentState extends State<DelivredHistoryFragment> {
  AnimateIconController controller = AnimateIconController();

  // Function to fetch JSON data from an API
  Future<void> fetchData() async {
    String filter = '';
    print('url: ' +
        AppUrl.livraison +
        AppUrl.user.etblssmnt!.code! +
        '/' +
        widget.client.id!);
    //http://"+AppUrl.user.company!+".my-crm.net:5188/api/Livraisons/client/ETB001/Fou002
    //http://"+AppUrl.user.company!+".my-crm.net:5188/api/Livraisons/client/ETB001/Fou002
    http.Response req = await http.get(
        Uri.parse(AppUrl.livraison +
            AppUrl.user.etblssmnt!.code! +
            '/' +
            widget.client.id! +
            '?PageNumber=1&filter=$filter&PageSize=200'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
        });
    print("res liv code : ${req.statusCode}");
    print("res liv body: ${req.body}");
    final provider = Provider.of<CommandProvider>(context, listen: false);
    if (req.statusCode == 200) {
      // add commands
      provider.deliverdList = [];
      List<dynamic> data = json.decode(req.body);
      data.toList().forEach((element) {
        provider.deliverdList.add(Command(
            id: element['numero'],
            date: DateTime.parse(element['date']),
            total: element['brut'],
            deliver: element['codeChauffeur'],
            paid: 0,
            products: [],
            nbProduct: 0));
        provider.notifyListeners();
      });
    }
  }

  @override
  void initState() {
    super.initState();

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
                  Text('Nous sommes désolé, la qualité de votre connexion ne vous permet pas de vous connecter à votre serveur.'
                      ' Veuillez réessayer ultérieurement. Merci'),
                ],
              ),
            );
          }else
            return
              Scaffold(
              appBar:  AppBar(
                iconTheme: IconThemeData(
                  color: Colors.white, // Set icon color to white
                ),
                backgroundColor: primaryColor,
                title: ListTile(
                  title: Text(
                    'Historique livraison de : ',
                    style: Theme.of(context)
                        .textTheme
                        .headline3!
                        .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
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

                ],
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Visibility(
                    visible: false,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        boxShadow: [
                          // BoxShadow(
                          //   color: Colors.grey.withOpacity(0.1), // Shadow color
                          //   offset: Offset(0, 5), // Offset from the object
                          // ),
                        ],
                      ),
                      margin: EdgeInsets.all(8),
                      height: 50,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.attach_money_outlined,
                                  color: primaryColor,
                                ),
                                Text(
                                  '0.00 DZD',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline3!
                                      .copyWith(color: primaryColor),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.call_outlined,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              color: primaryColor,
                            ),
                            Text(
                              'Du 01 Avril 2023',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(color: primaryColor),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Au 30 Avril 2023',
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
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Consumer<CommandProvider>(
                      builder: (context, commands, snapshot) {
                    return Expanded(
                      child: (commands.deliverdList.length != 0)
                          ? ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                widget.client.command =
                                    commands.deliverdList[index];
                                print(
                                    'size of deliverdList: ${commands.deliverdList.length}');
                                return CommandItem(
                                  client: widget.client,
                                  command: commands.deliverdList[index],
                                );
                              },
                              itemCount: commands.deliverdList.length)
                          : Center(
                              child: Text(
                              'Aucune livraison',
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
  final Client client;
  final Command command;

  const CommandItem({super.key, required this.command, required this.client});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // PageNavigator(ctx: context).nextPage(
        //     page: DeliverdPage(
        //   client: client,
        //   type: 'Livraison',
        // ));
        PageNavigator(ctx: context).nextPage(
            page: NewCommandPage(
              client: client,
              //type: 'Livraison',
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
                  Icons.delivery_dining_outlined,
                  color: primaryColor,
                ),
                SizedBox(
                  width: 20,
                ),
                Center(
                    child: Text(
                  '${command.deliver} ',
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                        color: black,
                        fontWeight: FontWeight.normal,
                      ),
                )),
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
                      child: Text('${command.date}',
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
