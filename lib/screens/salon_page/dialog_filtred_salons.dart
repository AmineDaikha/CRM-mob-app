import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/pipeline.dart';
import 'package:mobilino_app/models/step_pip.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/styles/colors.dart';

class FiltredSalonsDialog extends StatefulWidget {
  const FiltredSalonsDialog({
    super.key,
  });

  @override
  State<FiltredSalonsDialog> createState() =>
      _FiltredCommandsClientDialogState();
}

class _FiltredCommandsClientDialogState extends State<FiltredSalonsDialog> {
  late Collaborator selectedCollaborator =
      AppUrl.filtredCommandsClient.collaborateur!;
  late StepPip selectedStep;
  late Client selectedClient = AppUrl.filtredCommandsClient.client!;
  late Team selectedTeam = AppUrl.filtredCommandsClient.team!;
  DateTime selectedDate = AppUrl.filtredCommandsClient.date;
  DateTime selectedDateEnd = AppUrl.filtredCommandsClient.dateEnd;
  bool all = AppUrl.filtredCommandsClient.allCollaborators;

  List<StepPip> allSteps = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allSteps = List<StepPip>.from(AppUrl.filtredCommandsClient.projectSteps);
    allSteps.insert(0, StepPip(id: -1, name: 'Tout', color: ''));
    if(AppUrl.filtredCommandsClient.stepPipSalon == null || AppUrl.filtredCommandsClient.stepPipSalon!.id == -1){
      selectedStep = allSteps.first;
      AppUrl.filtredCommandsClient.stepPipSalon = selectedStep;
    }
    else {
      selectedStep = allSteps.where((element) => element.id == AppUrl.filtredCommandsClient.stepPipSalon!.id).first;
    }
  }

  void handleCheckbox2(bool? value) {
    setState(() {
      all = value!;
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
    print('date is : ${DateFormat('yyyy-MM-dd').format(picked!)}');
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        print('date is : ${DateFormat('yyyy-MM-dd').format(selectedDate)}');
      });
    }
  }

  Future<void> _selectDateEnd(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateEnd,
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
    print('date is : ${DateFormat('yyyy-MM-dd').format(picked!)}');
    if (picked != null && picked != selectedDateEnd) {
      setState(() {
        selectedDateEnd = picked;
        print('date is : ${DateFormat('yyyy-MM-dd').format(selectedDateEnd)}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //selectedDate = AppUrl.filtredCommandsClient.date!;
    //selectedStateItem = states.first;
    return SimpleDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Filtration',
        style: Theme.of(context).textTheme.headline3,
      ),
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            // Set desired border radius
            color: Colors.white,
          ),
          width: 550,
          height: 300,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    //showDateTimeDialog(context, selectedDate);
                    _selectDate(context).then((value) => print(
                        'Selected Month222: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'));
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
                          'Du : ',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                      Text(
                        '${DateFormat('dd-MM-yyyy').format(selectedDate)}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    //showDateTimeDialog(context, selectedDate);
                    _selectDateEnd(context).then((value) => print(
                        'Selected Month222: ${DateFormat('yyyy-MM-dd').format(selectedDateEnd)}'));
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
                          'Au : ',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                      Text(
                        '${DateFormat('dd-MM-yyyy').format(selectedDateEnd)}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: false,
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
                                  salCode: AppUrl.user.salCode)
                            ];
                            selectedCollaborator =
                                AppUrl.user.collaborator.first;
                            AppUrl.filtredCommandsClient.collaborateur =
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
                                      salCode: AppUrl.user.salCode));
                              AppUrl.user.collaborator =
                                  List<Collaborator>.from(collaborators)
                                      .where((element) =>
                                          element.userName !=
                                          AppUrl.user.userId)
                                      .toList();
                              AppUrl.filtredCommandsClient.collaborateur =
                                  AppUrl.user.collaborator.first;
                              print(
                                  'collaborators size: ${AppUrl.user.collaborator.length}');
                            }
                          }
                        } else {
                          selectedCollaborator =
                              AppUrl.user.allCollaborator.first;
                          AppUrl.filtredCommandsClient.collaborateur =
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
                  visible: false,
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
                        'Selectioner l\'équipe',
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
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
                Visibility(
                  child: ListTile(
                    title: Text(
                      'Les étapes : ',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: DropdownButtonFormField<StepPip>(
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
                        'Selectioner l\'étape',
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(color: Colors.grey),
                      ),
                      value: selectedStep,
                      onChanged: (newValue) {
                        setState(() {
                          selectedStep = newValue!;
                        });
                      },
                      items: allSteps
                          .map<DropdownMenuItem<StepPip>>((StepPip value) {
                        return DropdownMenuItem<StepPip>(
                          value: value,
                          child: Container(
                            width: 190,
                            child: Text(
                              value.name,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
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
                    AppUrl.filtredCommandsClient.stepPipSalon = selectedStep;
                    AppUrl.filtredCommandsClient.client = selectedClient;
                    AppUrl.filtredCommandsClient.team = selectedTeam;
                    AppUrl.filtredCommandsClient.date = selectedDate;
                    AppUrl.filtredCommandsClient.dateEnd = selectedDateEnd;
                    AppUrl.filtredCommandsClient.collaborateur =
                        selectedCollaborator;
                    print('collaboratorrrrrr ${selectedCollaborator.userName}');
                    print(
                        'collaboratorrrrrr ${AppUrl.filtredCommandsClient.collaborateur!.userName}');
                    AppUrl.filtredCommandsClient.allCollaborators = all;
                    Navigator.pop(context);
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
}
