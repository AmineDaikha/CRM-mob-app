import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/familly.dart';
import 'package:mobilino_app/models/pipeline.dart';
import 'package:mobilino_app/models/sfamilly.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/styles/colors.dart';

class FiltredCatalogDialog extends StatefulWidget {
  const FiltredCatalogDialog({
    super.key,
  });

  @override
  State<FiltredCatalogDialog> createState() =>
      _FiltredCommandsClientDialogState();
}

class _FiltredCommandsClientDialogState extends State<FiltredCatalogDialog> {
  late Collaborator selectedCollaborator =
      AppUrl.filtredCommandsClient.collaborateur!;
  late Client selectedClient = AppUrl.filtredCommandsClient.client!;
  late Familly selectedFamilly = AppUrl.filtredCatalog.selectedFamilly!;
  late SFamilly selectedSFamilly = AppUrl.filtredCatalog.selectedSFamilly!;

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
          width: 600,
          height: 275,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: Text(
                    'Filtre des familles',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle: DropdownButtonFormField<Familly>(
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
                      'Selectioner la famille',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.grey),
                    ),
                    value: selectedFamilly,
                    onChanged: (newValue) async {
                      selectedFamilly = newValue!;
                      if (newValue.code != -1) {
                        // get Collaborateurs
                        final Map<String, String> headers = {
                          "Accept": "application/json",
                          "content-type": "application/json; charset=UTF-8",
                          "Referer": "http://" +
                              AppUrl.user.company! +
                              ".localhost:4200/",
                          'Authorization': 'Bearer ${AppUrl.user.token}',
                        };
                        String url = AppUrl.getSfamillyByFamillyID +
                            newValue.code.toString();
                        print('url of getSFamilly $url');
                        http.Response req =
                            await http.get(Uri.parse(url), headers: headers);
                        print("res SFamilly code : ${req.statusCode}");
                        print("res SFamilly body: ${req.body}");
                        if (req.statusCode == 200 || req.statusCode == 201) {
                          List<dynamic> data = json.decode(req.body);
                          //AppUrl.user.collaborator = [];
                          print('size from api: ${data.length}');
                          AppUrl.user.sFamillies = [];
                          data.forEach((element) {
                            try {
                              AppUrl.user.sFamillies.add(SFamilly(
                                  code: element['code'],
                                  name: element['lib'],
                                  type: element['type']));
                            } catch (e) {
                              print('error: $e');
                            }
                          });
                          AppUrl.user.sFamillies.insert(
                              0, SFamilly(code: '-1', name: 'Tout', type: ''));
                          selectedSFamilly = AppUrl.user.sFamillies.first;
                        }
                      } else {
                        // AppUrl.user.sFamillies.insert(
                        //     0,
                        //     SFamilly(
                        //         code: '-1',
                        //         name: 'Tout',
                        //         type: ''));
                        // selectedSFamilly =
                        //     AppUrl.user.sFamillies.first;
                      }
                      setState(() {});
                    },
                    items: AppUrl.user.famillies
                        .map<DropdownMenuItem<Familly>>((Familly value) {
                      return DropdownMenuItem<Familly>(
                        value: value,
                        child: Column(
                          children: [
                            Text(
                              value.name,
                              style: Theme.of(context).textTheme.bodyText1,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            // Divider(
                            //   color: Colors.grey,
                            // ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Filtre des sous familles',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle: DropdownButtonFormField<SFamilly>(
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
                      'Selectioner sous famille',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.grey),
                    ),
                    value: selectedSFamilly,
                    onChanged: (newValue) {
                      setState(() {
                        selectedSFamilly = newValue!;
                      });
                    },
                    items: AppUrl.user.sFamillies
                        .map<DropdownMenuItem<SFamilly>>((SFamilly value) {
                      return DropdownMenuItem<SFamilly>(
                        value: value,
                        child: Text(
                          value.name,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onPressed: () {
                    AppUrl.filtredCatalog.selectedFamilly = selectedFamilly;
                    AppUrl.filtredCatalog.selectedSFamilly = selectedSFamilly;
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/catalog', (route) => false);
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
