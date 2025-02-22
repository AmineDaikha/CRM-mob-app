import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/filtred_activities.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/models/type_activity.dart';

import '../styles/colors.dart';
import 'confirmation_opportunity_dialog.dart';

class FiltredActivitiesDialog extends StatefulWidget {
  final FiltredActivities filtred;
  final List<TypeActivity> allTypes;

  const FiltredActivitiesDialog(
      {super.key, required this.filtred, required this.allTypes});

  @override
  State<FiltredActivitiesDialog> createState() =>
      _FiltredActivitiesDialogState();
}

class _FiltredActivitiesDialogState extends State<FiltredActivitiesDialog> {
  late Collaborator selectedCollaborator = widget.filtred.collborator!;
  late Team selectedTeam = widget.filtred.team!;
  String selectedStateItem = '';
  late TypeActivity selectedTypeActivity;
  late DateTime selectedStartTimeDate;
  late DateTime selectedEndTimeDate;
  List<TypeActivity> listTypes = [];
  List<String> states = [
    'Tout',
    'En attente',
    'En cours',
    'Terminée',
    'Non réalisée',
    'Annulée',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listTypes = widget.allTypes.toList();
    listTypes.add(widget.filtred.type);
    print('typeIS: ${widget.allTypes.length} ${widget.filtred.type.name}');
    selectedTypeActivity = widget.filtred.type;
    //selectedTypeActivity = widget.allTypes.first;
    selectedStateItem = widget.filtred.state;
    selectedStartTimeDate = widget.filtred.start;
    selectedEndTimeDate = widget.filtred.end;
  }

  @override
  Widget build(BuildContext context) {
    //selectedStateItem = states.first;
    AppUrl.changed = false;
    print('frfr : ${AppUrl.user.collaborator.length}');
    return SimpleDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Filtres des activites',
        style: Theme.of(context).textTheme.headline2,
      ),
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            // Set desired border radius
            color: Colors.white,
          ),
          width: 450,
          height: 550,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Visibility(
                  visible: (AppUrl.user.teams.length > 1),
                  child: ListTile(
                    title: Text(
                      'Filtre des équipes',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: DropdownButtonFormField<Team>(
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(width: 2, color: primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(width: 2, color: primaryColor),
                          )),
                      hint: Text(
                        'Selectioner l\'équipe',
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(color: Colors.grey),
                      ),
                      value: selectedTeam,
                      onChanged: (newValue) async {
                        print('ffffff');
                        selectedTeam = newValue!;
                        if (newValue.id != -1) {
                          // get Collaborateurs
                          final Map<String, String> headers = {
                            "Accept": "application/json",
                            "content-type": "application/json; charset=UTF-8",
                            "Referer": "http://" +
                                AppUrl.user.company! +
                                ".localhost:4200/",
                            'Authorization': 'Bearer ${AppUrl.user.token}',
                          };
                          if (newValue.id == AppUrl.user.equipeId) {
                            AppUrl.user.collaborator = [
                              Collaborator(
                                id: '-1',
                                userName: '${AppUrl.user.userId}',
                              )
                            ];
                            selectedCollaborator =
                                AppUrl.user.collaborator.first;
                            AppUrl.filtredOpporunity.collaborateur =
                                AppUrl.user.collaborator.first;
                          } else {
                            String url = AppUrl.getCollaborateur +
                                newValue.id.toString();
                            print('url of getCollaborateurs $url');
                            http.Response req = await http.get(Uri.parse(url),
                                headers: headers);
                            print("res Collaborateur code : ${req.statusCode}");
                            print("res Collaborateur body: ${req.body}");
                            if (req.statusCode == 200 ||
                                req.statusCode == 201) {
                              List<dynamic> data = json.decode(req.body);
                              //AppUrl.user.collaborator = [];
                              print('size from api: ${data.length}');
                              List<Collaborator> collaborators = [];
                              data.forEach((element) {
                                try {
                                  collaborators.add(Collaborator(
                                      id: element['id'],
                                      userName: element['userName'],
                                      salCode: element['salCode']));
                                } catch (e) {
                                  print('error: $e');
                                }
                              });
                              selectedCollaborator = collaborators.first;
                              collaborators.insert(
                                  0,
                                  Collaborator(
                                    id: '-1',
                                    userName: '${AppUrl.user.userId}',
                                  ));
                              AppUrl.user.collaborator =
                                  List<Collaborator>.from(collaborators)
                                      .where((element) =>
                                          element.userName !=
                                          AppUrl.user.userId)
                                      .toList();
                              AppUrl.filtredOpporunity.collaborateur =
                                  AppUrl.user.collaborator.first;
                              print(
                                  'collaborators size: ${AppUrl.user.collaborator.length}');
                            }
                          }
                        } else {
                          selectedCollaborator =
                              AppUrl.user.allCollaborator.first;
                          AppUrl.filtredOpporunity.collaborateur =
                              AppUrl.user.collaborator.first;
                          AppUrl.user.collaborator = List<Collaborator>.from(
                                  AppUrl.user.allCollaborator)
                              .where((element) =>
                                  element.userName != AppUrl.user.userId)
                              .toList();
                        }
                        setState(() {});
                      },
                      items: AppUrl.user.teams
                          .map<DropdownMenuItem<Team>>((Team value) {
                        return DropdownMenuItem<Team>(
                          value: value,
                          child: Text(
                            value.lib!,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Visibility(
                  //visible : true,
                  visible: true,
                  child: ListTile(
                    title: Text(
                      'Filtre des collaborateurs',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: DropdownButtonFormField<Collaborator>(
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(width: 2, color: primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(width: 2, color: primaryColor),
                          )),
                      hint: Text(
                        'Selectioner le collaborateur',
                        style: Theme.of(context)
                            .textTheme
                            .headline6  !
                            .copyWith(color: Colors.grey),
                      ),
                      value: selectedCollaborator,
                      onChanged: (newValue) {
                        setState(() {
                          selectedCollaborator = newValue!;
                        });
                      },
                      items: AppUrl.user.collaborator
                          .map<DropdownMenuItem<Collaborator>>(
                              (Collaborator value) {
                        return DropdownMenuItem<Collaborator>(
                          value: value,
                          child: Text(
                            value.userName!,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Type',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle: DropdownButtonFormField<TypeActivity>(
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2, color: primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2, color: primaryColor),
                        )),
                    hint: Text(
                      'Selectioner le type',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .copyWith(color: Colors.grey),
                    ),
                    value: selectedTypeActivity,
                    onChanged: (newValue) {
                      setState(() {
                        selectedTypeActivity = newValue!;
                      });
                    },
                    items: listTypes.toSet().toList().map<DropdownMenuItem<TypeActivity>>(
                        (TypeActivity value) {
                      return DropdownMenuItem<TypeActivity>(
                        value: value,
                        child: Container(
                          width: AppUrl.getFullWidth(context)*0.5,
                          child: Text(
                            value.name!,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Etat',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2, color: primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2, color: primaryColor),
                        )),
                    hint: Text(
                      'Selectioner l\'état ',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.grey),
                    ),
                    value: selectedStateItem,
                    onChanged: (newValue) {
                      setState(() {
                        selectedStateItem = newValue!;
                      });
                    },
                    items: states.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: primaryColor,
                      ),
                      Container(
                        width: 50,
                        child: Text(
                          'Date début',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                      Text(
                        '${DateFormat('dd-MM-yyyy').format(selectedStartTimeDate)}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    _selectDateEnd(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: primaryColor,
                      ),
                      Container(
                        width: 50,
                        child: Text(
                          'Date fin',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                      Text(
                        '${DateFormat('dd-MM-yyyy').format(selectedEndTimeDate)}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onPressed: () {
                    widget.filtred.state = selectedStateItem;
                    widget.filtred.start = selectedStartTimeDate;
                    widget.filtred.end = selectedEndTimeDate;
                    widget.filtred.type = selectedTypeActivity;
                    widget.filtred.team = selectedTeam;
                    widget.filtred.collborator = selectedCollaborator;
                    print('lgro ${selectedCollaborator.salCode}');
                    if(selectedCollaborator.salCode == null){
                      //selectedCollaborator.salCode = AppUrl
                    }
                    AppUrl.changed = true;
                    Navigator.of(context).pop(AppUrl.changed);
                  },
                  child: const Text(
                    "Confirmer",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedStartTimeDate,
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
        });
    print('date is : ${DateFormat('yyyy-MM-dd').format(picked!)}');
    if (picked != null && picked != selectedStartTimeDate) {
      setState(() {
        selectedStartTimeDate = picked;
        print(
            'date is : ${DateFormat('yyyy-MM-dd').format(selectedStartTimeDate)}');
      });
    }
  }

  Future<void> _selectDateEnd(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedEndTimeDate,
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
        });
    print('date is : ${DateFormat('yyyy-MM-dd').format(picked!)}');
    if (picked != null && picked != selectedEndTimeDate) {
      setState(() {
        selectedEndTimeDate = picked;
        print(
            'date is : ${DateFormat('yyyy-MM-dd').format(selectedEndTimeDate)}');
      });
    }
  }

  Future<void> showDateTimeDialog(BuildContext context, DateTime date) async {
    // Initialize result variables
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    // Show date picker
    selectedDate = await showDatePicker(
        context: context,
        initialDate: date,
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
        });

    // Check if date was selected
    if (selectedDate != null) {
      // Show time picker
      selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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
        setState(() {
          date = selectedDateTime;
        });
      }
    }
  }

  Widget buildChoiceItem(BuildContext context, String choice, Icon icon) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          icon,
          SizedBox(width: 16),
          Text(
            choice,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
