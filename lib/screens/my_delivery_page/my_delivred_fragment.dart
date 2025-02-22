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
import 'package:mobilino_app/providers/command_provider.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:provider/provider.dart';

import 'deliver_page.dart';

class DelivredHistoryFragment extends StatefulWidget {
  Client client;

  DelivredHistoryFragment({super.key, required this.client});

  @override
  State<DelivredHistoryFragment> createState() =>
      _DelivredHistoryFragmentState();
}

class _DelivredHistoryFragmentState extends State<DelivredHistoryFragment> {
  AnimateIconController controller = AnimateIconController();
  DateTime dateStart = DateTime.now();
  DateTime dateEnd = DateTime.now();
  // Function to fetch JSON data from an API
  Future<void> fetchData() async {
    String url = AppUrl.getMyDelivred +
        '${AppUrl.user.etblssmnt!.code}/${AppUrl.filtredCommandsClient.collaborateur!.salCode}';
    print('urlis: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
    });
    print("res myDelivred code : ${req.statusCode}");
    print("res myDelivred body : ${req.body}");
    final provider = Provider.of<CommandProvider>(context, listen: false);
    if (req.statusCode == 200) {
      provider.deliverdList = [];
      List<dynamic> data = json.decode(req.body);
      print('size commands : ${data.toList().length}');
      //data.toList().forEach((element) async {
      for(int i =0 ; i<data.length; i++){
        var element = data[i];
        if(AppUrl.isDateBetween(DateTime.parse(element['date']), dateStart, dateEnd) == false) continue;
        if (AppUrl.filtredCommandsClient.client!.id != '-1') {
          if (AppUrl.filtredCommandsClient.client!.id !=
              element['pcfCode']) continue;
        }
        print('type is: ${element['type']}');
        if (element['stype'] == 'B' && element['type'] == 'V') {
          String pcfCode = element['pcfCode'];
          http.Response req =
          await http.get(Uri.parse(AppUrl.getOneTier + pcfCode), headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
            "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
          });
          print("res oneTier code : ${req.statusCode}");
          print("res oneTier body: ${req.body}");
          if (req.statusCode == 200) {
            var res = json.decode(req.body);
            print('code client:  ${res['code']}');
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
            provider.deliverdList.add(Command(
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
        }}
      //});
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
        dateEnd = DateTime(picked.year, picked.month, picked.day, 23, 59, 59,999);
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
        23, // new hour
        59, // new minute
        59, // new second
        999
    );
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: fetchData(),
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
            print('Error: ${snapshot.hasError}');
            return Text('Error: ${snapshot.error}');
          } else
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 10),
                //   decoration: BoxDecoration(
                //     color: Colors.grey[300],
                //     boxShadow: [
                //       // BoxShadow(
                //       //   color: Colors.grey.withOpacity(0.1), // Shadow color
                //       //   offset: Offset(0, 5), // Offset from the object
                //       // ),
                //     ],
                //   ),
                //   margin: EdgeInsets.all(8),
                //   height: 50,
                //   child: Stack(
                //     children: [
                //       Align(
                //         alignment: Alignment.centerLeft,
                //         child: Row(
                //           children: [
                //             Icon(
                //               Icons.attach_money_outlined,
                //               color: primaryColor,
                //             ),
                //             Text(
                //               '0.00 DZD',
                //               style: Theme.of(context)
                //                   .textTheme
                //                   .headline3!
                //                   .copyWith(color: primaryColor),
                //             ),
                //           ],
                //         ),
                //       ),
                //       Align(
                //         alignment: Alignment.center,
                //       ),
                //       Align(
                //         alignment: Alignment.centerRight,
                //         child: Icon(
                //           Icons.call_outlined,
                //           color: primaryColor,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
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
                        onTap: (){
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
                    child: (commands.deliverdList.length != 0)
                        ? ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              print(
                                  'size of deliverdList: ${commands.deliverdList.length}');
                              return CommandItem(
                                client: commands.deliverdList[index].client!,
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
          type: 'Livraison',
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
                      child: Text('${DateFormat('yyyy-MM-dd  HH:mm:ss').format(command.date)}',
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
