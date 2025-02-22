import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/pipeline.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/styles/colors.dart';

class FiltredCommandsClientDialog extends StatefulWidget {
  const FiltredCommandsClientDialog({
    super.key,
  });

  @override
  State<FiltredCommandsClientDialog> createState() =>
      _FiltredCommandsClientDialogState();
}

class _FiltredCommandsClientDialogState
    extends State<FiltredCommandsClientDialog> {
  late Collaborator selectedCollaborator =
      AppUrl.filtredCommandsClient.collaborateur!;
  late Client selectedClient =
  AppUrl.filtredCommandsClient.client!;
  late Team selectedTeam = AppUrl.filtredCommandsClient.team!;
  bool all = AppUrl.filtredCommandsClient.allCollaborators;
  void handleCheckbox2(bool? value) {
    setState(() {
      all = value!;
    });
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
          height: 450,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(
                  height: 10,
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
                            salCode: AppUrl.user.salCode
                          )];
                          selectedCollaborator =
                              AppUrl.user.collaborator.first;
                          AppUrl.filtredCommandsClient.collaborateur =
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
                                    salCode: AppUrl.user.salCode
                                ));
                            AppUrl.user.collaborator =
                                List<Collaborator>.from(collaborators)
                                    .where((element) =>
                                        element.userName != AppUrl.user.userId)
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
                ListTile(
                  title: Text(
                    'Filtre des tiers',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle: DropdownButtonFormField<Client>(
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
                    value: selectedClient,
                    onChanged: (newValue) {
                      setState(() {
                        selectedClient = newValue!;
                      });
                    },
                    items: AppUrl.filtredCommandsClient.clients
                        .map<DropdownMenuItem<Client>>(
                            (Client value) {
                          return DropdownMenuItem<Client>(
                            value: value,
                            child: Text(
                              value.name!,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          );
                        }).toList(),
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
                    AppUrl.filtredCommandsClient.client = selectedClient;
                    AppUrl.filtredCommandsClient.team = selectedTeam;
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
