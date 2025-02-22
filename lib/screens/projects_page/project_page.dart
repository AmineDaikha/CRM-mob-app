import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/constants/utils.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/command.dart';
import 'package:mobilino_app/models/product.dart';
import 'package:mobilino_app/models/project.dart';
import 'package:mobilino_app/models/type_activity.dart';
import 'package:mobilino_app/screens/home_page/notes_page/note_liste_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/confirmation_opportunity_dialog.dart';
import 'package:mobilino_app/widgets/dialog_lib.dart';
import 'package:mobilino_app/widgets/dialog_opp_state.dart';
import 'package:mobilino_app/widgets/payment_page.dart';
import 'package:mobilino_app/widgets/text_field.dart';

import 'info_detais_project.dart';
import 'processing_project.dart';

class ProjectPage extends StatefulWidget {
  final Project project;

  const ProjectPage({super.key, required this.project});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  Widget icon = Icon(Icons.shopping_cart_outlined);
  int respone = 200;
  double total = 0;

  Future<void> fetchData(Project project) async {
    String url = AppUrl.getAllProjects + '/${project.code}';
    print('url getOneProject $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res getOneProject code : ${req.statusCode}");
    print("res getOneProject body: ${req.body}");
    if (req.statusCode == 200) {
      var res = json.decode(req.body);
      widget.project.res = res;
    }
  }

  Future<void> fetchDataReg() async {
    AppUrl.user.typeReg = [];
    String url = AppUrl.getTypesReg;
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res typeReg code : ${req.statusCode}");
    print("res typeReg body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      //activitiesProcesses[process] = types;
      data.toList().forEach((element) {
        AppUrl.user.typeReg.add(TypeActivity(
          id: element['id'],
          code: element['code'],
          name: element['lib'],
        ));
      });
      //activitiesProcesses[process] = types;
    }
    await fetchData(widget.project);
  }

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    double priorityrating = 0;
    double emergencyrating = 0;

    return FutureBuilder(
        future: fetchDataReg(),
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
                  Expanded(
                    child: Text(
                        'Nous sommes désolé, la qualité de votre connexion ne vous permet pas de vous connecter à votre serveur.'
                        ' Veuillez réessayer ultérieurement. Merci'),
                  ),
                ],
              ),
            );
          }
          print('project: ${widget.project.code}');
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(100),
                child: AppBar(
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(20.0),
                    // Adjust this as needed
                    child: Container(
                      color: Colors.white,
                      child: TabBar(
                          //isScrollable: true,
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Theme.of(context).primaryColor),
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Theme.of(context).primaryColor,
                          indicator: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                            width: 2.5,
                            color: Theme.of(context).primaryColor,
                          ))),
                          tabs: [
                            Tab(
                              text: 'Infos générales',
                            ),
                            Tab(
                              text: 'Suivi ouverture des plis',
                            ),
                          ]),
                    ),
                  ),
                  iconTheme: IconThemeData(
                    color: Colors.white, // Set icon color to white
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  title: ListTile(
                    title: Text(
                      'Projet ',
                      style: Theme.of(context)
                          .textTheme
                          .headline3!
                          .copyWith(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${widget.project.object}',
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  actions: [],
                ),
              ),
              // appBar: AppBar(
              //   backgroundColor: primaryColor,
              //   iconTheme: IconThemeData(
              //     color: Colors.white, // Set icon color to white
              //   ),
              //   title: ListTile(
              //     title: Text(
              //       'Projet ',
              //       style: Theme
              //           .of(context)
              //           .textTheme
              //           .headline3!
              //           .copyWith(color: Colors.white),
              //     ),
              //     subtitle: Text(
              //       '${widget.project.object}',
              //       style: Theme
              //           .of(context)
              //           .textTheme
              //           .headline6!
              //           .copyWith(color: Colors.white),
              //     ),
              //   ),
              // ),
              body: TabBarView(
                children: [
                  ProjectDetailsWidget(
                    project: widget.project,
                  ),
                  ProcessingDetailsWidget(
                    project: widget.project,
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> showDateTimeDialog(BuildContext context) async {
    // Initialize result variables
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    // Show date picker
    selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
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

    // Check if date was selected
    if (selectedDate != null) {
      // Show time picker
      selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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

      // Handle both date and time selection
      if (selectedTime != null) {
        // Combine date and time and show final result
        DateTime selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        widget.project.startDate = selectedDateTime;
        setState(() {});
      }
    }
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: primaryColor,
          ),
          Container(
              margin: EdgeInsets.only(left: 15), child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}
