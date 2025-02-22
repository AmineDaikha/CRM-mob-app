import 'dart:convert';

import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/command.dart';
import 'package:mobilino_app/models/payment.dart';
import 'package:mobilino_app/providers/command_provider.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:provider/provider.dart';

import 'deliver_page.dart';

class PaymentHistoryFragment extends StatefulWidget {
  Client client;

  PaymentHistoryFragment({super.key, required this.client});

  @override
  State<PaymentHistoryFragment> createState() => _PaymentHistoryFragmentState();
}

class _PaymentHistoryFragmentState extends State<PaymentHistoryFragment> {
  AnimateIconController controller = AnimateIconController();
  DateTime dateStart = DateTime.now();
  DateTime dateEnd = DateTime.now();

  // Function to fetch JSON data from an API
  Future<void> fetchData() async {
    //http://"+AppUrl.user.company!+".my-crm.net:5188/api/Livraisons/client/ETB001/Fou002
    //http://"+AppUrl.user.company!+".my-crm.net:5188/api/Livraisons/client/ETB001/Fou002
    String url = AppUrl.reglement +
        AppUrl.user.etblssmnt!.code! +
        '/' +
        widget.client.id!;
    print('url: $url');
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
        if (AppUrl.filtredCommandsClient.allCollaborators == false) {
          if (AppUrl.filtredCommandsClient.collaborateur!.salCode !=
              element['salCode']) continue;
        }
        provider.paymentList.add(Payment(
            date: parsedDate,
            code: element['regNumero'],
            total: element['regRecu'],
            paid: 0,
            type: element['regType'],
            currentPaid: 0));
        provider.notifyListeners();
      }
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
                //   margin: EdgeInsets.all(8),
                //   child: (AppUrl.filtredCommandsClient.allCollaborators)
                //       ? Text(
                //     'Collaborateurs: Tout',
                //     style: Theme.of(context)
                //         .textTheme
                //         .headline4!
                //         .copyWith(color: primaryColor),
                //   )
                //       : Text(
                //     'Collaborateurs: ${AppUrl.filtredCommandsClient.collaborateur!.userName}',
                //     style: Theme.of(context)
                //         .textTheme
                //         .headline4!
                //         .copyWith(color: primaryColor),
                //   ),
                // ),
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
                //               '${AppUrl.formatter.format(widget.client.totalPay)} DZD',
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
                    child: (commands.paymentList.length != 0)
                        ? ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              print(
                                  'size of paymentList: ${commands.paymentList.length}');
                              return CommandItem(
                                client: widget.client,
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
            );
        });
  }
}

class CommandItem extends StatelessWidget {
  final Client client;
  final Payment payment;

  const CommandItem({super.key, required this.payment, required this.client});

  @override
  Widget build(BuildContext context) {
    late Icon icon;
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
                    child: Text(
                      '${payment.type} ',
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                            color: primaryColor,
                          ),
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
