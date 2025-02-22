import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/salon.dart';
import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:mobilino_app/widgets/text_field.dart';
import '../activities_pages/activity_list_page.dart';
import 'info_detais_salon.dart';
import 'visitors_widget.dart';

class SalonPage extends StatefulWidget {
  final Salon salon;

  const SalonPage({super.key, required this.salon});

  @override
  State<SalonPage> createState() => _SalonPageState();
}

class _SalonPageState extends State<SalonPage> {

  Future<void> fetchDataSalon() async {
    String url = AppUrl.getAllSalon + '/${widget.salon.code}';
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res oneSalon code : ${req.statusCode}");
    print("res oneSalon body: ${req.body}");
    if (req.statusCode == 200) {
      var res = json.decode(req.body);
      widget.salon.res = res;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchDataSalon(),
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
          print('salon: ${widget.salon.code}');
          return DefaultTabController(
            length: 3,
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
                          isScrollable: true,
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
                              text: 'Définition de la foire/salon',
                            ),
                            Tab(
                              text: 'Visiteurs',
                            ),
                            Tab(
                              text: 'Synthèse',
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
                      'Foire/Salon : ',
                      style: Theme.of(context)
                          .textTheme
                          .headline3!
                          .copyWith(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${widget.salon.object}',
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
                  SalonDetailsWidget(
                    salon: widget.salon,
                  ),
                  VisitorssWidget(
                    salon: widget.salon,
                  ),
                  SyntheseWidget(salon: widget.salon)
                  // ProcessingDetailsWidget(
                  //   project: widget.salon,
                  // )
                ],
              ),
            ),
          );
        });
  }
}

class SyntheseWidget extends StatelessWidget {
  final TextEditingController _lib = TextEditingController();

  SyntheseWidget({super.key, required this.salon});

  final Salon salon;

  @override
  Widget build(BuildContext context) {
    if (salon.res['synthese'] != null) {
      _lib.text = salon.res['synthese'];
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
            child: customTextFieldEmptyMulti(
              obscure: false,
              controller: _lib,
              hint: 'Synthèse',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              onPressed: () async {
                ConfirmationDialog confirmationDialog = ConfirmationDialog();
                bool confirmed = await confirmationDialog.showConfirmationDialog(
                    context, 'confirmChang');
                if (confirmed) {
                  showLoaderDialog(context);
                  salon.res['synthese'] = _lib.text.trim();
                  editSynthese(salon).then((value) {
                    Navigator.pop(context);
                  });
                }
              },
              child: Text(
                "        Valider        ",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> editSynthese(Salon project) async {
    String url = AppUrl.getAllSalon + '/${salon.code}';
    print('url: $url');
    print('obj json: ${project.res['users']}');
    print('sal: ${AppUrl.user.salCode}');
    http.Response req =
    await http.put(Uri.parse(url), body: jsonEncode(project.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res editSalon code : ${req.statusCode}");
    print("res editSalon body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}