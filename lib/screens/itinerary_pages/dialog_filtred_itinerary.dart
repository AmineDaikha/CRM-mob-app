import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/pipeline.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/styles/colors.dart';

class FiltredItineraryDialog extends StatefulWidget {
  const FiltredItineraryDialog({
    super.key,
  });

  @override
  State<FiltredItineraryDialog> createState() =>
      _FiltredItineraryDialogState();
}

class _FiltredItineraryDialogState
    extends State<FiltredItineraryDialog> {
  DateTime selectedDate = AppUrl.filtredOpporunity.date!;
  late Collaborator selectedCollaborator =
      AppUrl.filtredOpporunity.collaborateur!;
  late Team selectedTeam = AppUrl.filtredOpporunity.team!;
  late Pipeline selectedPipeline = AppUrl.filtredOpporunity.pipeline!;


  @override
  Widget build(BuildContext context) {
    //selectedDate = AppUrl.filtredOpporunity.date!;
    //selectedStateItem = states.first;
    print('itemsTeams: ${AppUrl.user.teams.length} $selectedTeam');
    return SimpleDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Filtres des opportunités',
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
          height: 450,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                InkWell(
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
                          'Date',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                      Text(
                        '${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ],
                  ),
                ),
                ListTile(
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
                          borderSide: BorderSide(width: 2, color: primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2, color: primaryColor),
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
                          AppUrl.user.collaborator = [Collaborator(
                            id: '-1',
                            userName: '${AppUrl.user.userId}',
                          )];
                          selectedCollaborator =
                              AppUrl.user.collaborator.first;
                          AppUrl.filtredOpporunity.collaborateur =
                              AppUrl.user.collaborator.first;

                        } else {
                          String url =
                              AppUrl.getCollaborateur + newValue.id.toString();
                          print('url of getCollaborateurs $url');
                          http.Response req =
                              await http.get(Uri.parse(url), headers: headers);
                          print("res Collaborateur code : ${req.statusCode}");
                          print("res Collaborateur body: ${req.body}");
                          if (req.statusCode == 200 || req.statusCode == 201) {
                            List<dynamic> data = json.decode(req.body);
                            //AppUrl.user.collaborator = [];
                            print('size from api: ${data.length}');
                            List<Collaborator> collaborators = [];
                            data.forEach((element) {
                              try {
                                collaborators.add(Collaborator(
                                  id: element['id'],
                                  userName: element['userName'],
                                  salCode: element['salCode']
                                ));
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
                                        element.userName != AppUrl.user.userId)
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
                        AppUrl.user.collaborator =
                            List<Collaborator>.from(AppUrl.user.allCollaborator)
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
                ListTile(
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
                          borderSide: BorderSide(width: 2, color: primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2, color: primaryColor),
                        )),
                    hint: Text(
                      'Selectioner le collaborateur',
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
                SizedBox(
                  height: 20,
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
                    AppUrl.filtredOpporunity.team = selectedTeam;
                    AppUrl.filtredOpporunity.collaborateur =
                        selectedCollaborator;
                    AppUrl.filtredOpporunity.date = selectedDate;
                    AppUrl.selectedDate = selectedDate;
                    print('collaboratorrrrrr ${selectedCollaborator.userName}');
                    print(
                        'collaboratorrrrrr ${AppUrl.filtredOpporunity.collaborateur!.userName}');
                    Navigator.of(context).pop();
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

  // Future<void> _showDatePicker(BuildContext context) async {
  //   DateTime selectedDate = AppUrl.selectedDate;
  //   DateTime? pickedMonth = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //     initialDatePickerMode: DatePickerMode.day,
  //   );
  //
  //   if (pickedMonth != null && pickedMonth != selectedDate) {
  //     // A month was selected
  //     //AppUrl.selectedDate = pickedMonth;
  //     print('Selected Month: ${DateFormat('yyyy-MM-dd').format(selectedDate)}');
  //     print('Selected Month: ${DateFormat('yyyy-MM-dd').format(pickedMonth)}');
  //     //print('Selected Week of the Month: ${_getWeekOfMonth(pickedMonth)}');// Assaire / Tounée
  //     setState(() {
  //       this.selectedDate = pickedMonth;
  //     });
  //   }
  // }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    print('date is : ${DateFormat('yyyy-MM-dd').format(picked!)}');
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        print('date is : ${DateFormat('yyyy-MM-dd').format(selectedDate)}');
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
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

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
