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

class FiltredClientDialog extends StatefulWidget {
  const FiltredClientDialog({
    super.key,
  });

  @override
  State<FiltredClientDialog> createState() =>
      _FiltredCommandsClientDialogState();
}

class _FiltredCommandsClientDialogState extends State<FiltredClientDialog> {
  late Familly selectedFamilly;
  late SFamilly selectedSFamilly;

  List<SFamilly> sFamillyList = [];

  Future<void> fetchDataFamilly() async {
    AppUrl.tierFamillies = [];
    AppUrl.tierSFamillies = [];
    String url = '${AppUrl.tierFamilly}';
    print('url : $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res familly code : ${req.statusCode}");
    print("res familly body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      print('length ${data.length}');
      data.forEach((element) {
        AppUrl.tierFamillies.add(
            Familly(code: element['code'], name: element['lib'], type: ''));
      });
    }
    await fetchDataSFamilly();
    AppUrl.tierFamillies.insert(0, Familly(code: '-1', name: 'Tout', type: ''));
    AppUrl.tierSFamillies
        .insert(0, SFamilly(code: '-1', name: 'Tout', type: '1'));
    AppUrl.filtredClient.first = false;
  }

  Future<void> fetchDataSFamilly() async {
    String url = '${AppUrl.tierSFamilly}';
    print('url : $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res sfamilly code : ${req.statusCode}");
    print("res sfamilly body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      print('length ${data.length}');
      data.forEach((element) {
        AppUrl.tierSFamillies.add(SFamilly(
            code: element['code'],
            name: element['lib'],
            type: element['fatCode']));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //selectedDate = AppUrl.filtredCommandsClient.date!;
    //selectedStateItem = states.first;
    return FutureBuilder(
        future: (AppUrl.filtredClient.first) ? fetchDataFamilly() : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Future is still running, return a loading indicator or some placeholder.
            return AlertDialog(
              content: Container(
                  width: 200,
                  height: 100,
                  child: Image.asset('assets/CRM-Loader.gif')),
            );
          }
          try{
          print('instansOf : ${AppUrl.filtredClient.selectedFamilly}');
          if (AppUrl.filtredClient.selectedFamilly == null) {
            selectedFamilly = AppUrl.tierFamillies.first;
            selectedSFamilly = AppUrl.tierSFamillies.first;
          } else {
            selectedFamilly = AppUrl.filtredClient.selectedFamilly!;
            sFamillyList = AppUrl.tierSFamillies
                .where((element) => element.type == selectedFamilly!.code)
                .toList();

            if (AppUrl.filtredClient.selectedSFamilly != null) {
              selectedSFamilly = AppUrl.filtredClient.selectedSFamilly!;
            } else {
              selectedSFamilly = sFamillyList.first;
            }
          }
          }catch(e){
            print(' err: $e');
          }
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
                          'Famille',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: DropdownButtonFormField<Familly>(
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
                            'Selectioner la famille',
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(color: Colors.grey),
                          ),
                          value: selectedFamilly,
                          onChanged: (newValue) {
                            selectedFamilly = newValue!;
                            print(
                                'fjhbkjbkkrt ${selectedFamilly.code} ${selectedFamilly.name} ${selectedFamilly.type}');
                            print(
                                'fjhbkjbkkrt ${newValue.code} ${newValue.name} ${newValue.type}');
                            if (selectedFamilly != null) {
                              sFamillyList =
                                  List<SFamilly>.from(AppUrl.tierSFamillies)
                                      .where((element) =>
                                          element.type == selectedFamilly.code)
                                      .toList();
                              sFamillyList.insert(
                                  0, SFamilly(code: '-1', name: 'Tout', type: ''));
                              selectedSFamilly = sFamillyList.first;
                              print('fjhbkjbkkrtlengh ${sFamillyList.length}');
                              AppUrl.filtredClient.selectedFamilly = selectedFamilly;
                            }
                            setState(() {});
                          },
                          items: AppUrl.tierFamillies
                              .map<DropdownMenuItem<Familly>>((Familly value) {
                            return DropdownMenuItem<Familly>(
                              value: value,
                              child: Text(
                                value.name,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Sous Famille',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: DropdownButtonFormField<SFamilly>(
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
                              print(
                                  'frfrffrfrfrf ${selectedSFamilly.code} ${selectedSFamilly.name} ${selectedSFamilly.type}');
                              print('fjhbkjbkkrt ${sFamillyList.length}');
                            });
                          },
                          items: sFamillyList.map<DropdownMenuItem<SFamilly>>(
                              (SFamilly value) {
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
                          AppUrl.filtredClient.selectedFamilly =
                              selectedFamilly;
                          AppUrl.filtredClient.selectedSFamilly =
                              selectedSFamilly;
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
        });
  }
}
