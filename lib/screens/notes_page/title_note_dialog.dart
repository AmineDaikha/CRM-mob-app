import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/styles/colors.dart';

class TitleNoteDialog extends StatefulWidget {
  @override
  _TitleNoteDialogState createState() => _TitleNoteDialogState();
}

class _TitleNoteDialogState extends State<TitleNoteDialog> {
  final TextEditingController _numberController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late Team selectedTeam = AppUrl.filtredCommandsClient.team!;
  late Collaborator selectedCollaborator = AppUrl.filtredCommandsClient.collaborateur!;
  late Client selectedClient = AppUrl.filtredCommandsClient.clients.where((element) => element.id != '-1').first;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          'Titre de note',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: txtInputDecoration.copyWith(labelText: 'titre', hintText: 'titre'),
                controller: _numberController,
          //            keyboardType: TextInputType.number,

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Svp, entrer le titre';
                  }
                },
              ),
              Visibility(
                visible: (AppUrl.user.teams.length>1),
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
                          AppUrl.user.collaborator = [
                            Collaborator(
                                id: '-1',
                                userName: '${AppUrl.user.userId}',
                                salCode: AppUrl.user.salCode)
                          ];
                          selectedCollaborator = AppUrl.user.collaborator.first;
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
              ),
              Visibility(
                visible: (AppUrl.user.collaborator.length>1),
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
                  items: AppUrl.filtredCommandsClient.clients.where((element) => element.id != '-1').toList()
                      .map<DropdownMenuItem<Client>>((Client value) {
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
              SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(primaryColor), // Change the color here
                ),
                onPressed: () {
                  if (formKey.currentState != null &&
                      formKey.currentState!
                          .validate()){
                    Navigator.of(context).pop(_numberController.text);
                  }

                },
                child: Text('Confirmer', style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }
}
const txtInputDecoration = InputDecoration(

  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0xff049a9b),
        width: 2,
      )),
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xff049a9b), width: 2)),
  errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xff049a9b), width: 2)),
);