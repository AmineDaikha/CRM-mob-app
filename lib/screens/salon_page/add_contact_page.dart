import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/contact.dart';
import 'package:mobilino_app/models/salon.dart';
import 'package:mobilino_app/models/type_activity.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/text_field.dart';

import '../activities_pages/activity_list_page.dart';

class AddNewContactPage extends StatefulWidget {
  final Client client;
  final Salon salon;

  const AddNewContactPage(
      {super.key, required this.client, required this.salon});

  @override
  State<AddNewContactPage> createState() => _AddNewContactPageState();
}

class _AddNewContactPageState extends State<AddNewContactPage> {
  final TextEditingController nameRs = TextEditingController();
  final TextEditingController namRS2 = TextEditingController();
  final TextEditingController tel1 = TextEditingController();
  final TextEditingController tel2 = TextEditingController();
  final TextEditingController email = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  List<TypeActivity> civilit = [];
  TypeActivity? selectedCivilit;

  @override
  void initState() {
    super.initState();
    //selectedCivilit = civilit.first;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: (civilit.isEmpty) ? getCivilite() : null,
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
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.white, // Set icon color to white
              ),
              backgroundColor: primaryColor,
              title: Text(
                'Ajouter un contact',
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(color: Colors.white),
              ),
            ),
            body: Form(
              key: _formkey,
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/addclient.png',
                        fit: BoxFit.cover,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        child: ListTile(
                          title: Text(
                            'Civilité : ',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          subtitle: DropdownButtonFormField<TypeActivity>(
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
                              'Selectioner civilité',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(color: Colors.grey),
                            ),
                            value: selectedCivilit,
                            onChanged: (newValue) {
                              setState(() {
                                selectedCivilit = newValue!;
                              });
                            },
                            items: civilit.map<DropdownMenuItem<TypeActivity>>(
                                (TypeActivity value) {
                              return DropdownMenuItem<TypeActivity>(
                                value: value,
                                child: Container(
                                  width: 190,
                                  child: Text(
                                    value.name!,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: customTextField(
                              obscure: false,
                              controller: nameRs,
                              hint: 'Nom',
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: customTextFieldEmpty(
                              obscure: false,
                              controller: namRS2,
                              hint: 'Prénom',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: customTextFieldEmpty(
                              obscure: false,
                              controller: tel1,
                              hint: 'Téléphone mobile',
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: customTextFieldEmpty(
                              obscure: false,
                              controller: tel2,
                              hint: 'Téléphone direct',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      customTextFieldEmpty(
                        obscure: false,
                        controller: email,
                        hint: 'Adresse e-mail ',
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                          width: 200,
                          height: 45,
                          // todo 7
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            onPressed: () {
                              if (selectedCivilit == null) {
                                showAlertDialog(
                                    context, 'Il faut choisir civilité');
                                return;
                              }
                              if (_formkey.currentState != null &&
                                  _formkey.currentState!.validate()) {
                                Contact contact = Contact(
                                    famillyName: nameRs.text.trim(),
                                    firstName: namRS2.text.trim(),
                                    telMobile: tel1.text.trim(),
                                    telDirect: tel2.text.trim(),
                                    email: email.text.trim(),
                                    origin: widget.client.id,
                                    civilte: selectedCivilit!.code);
                                showLoaderDialog(context);
                                sendContact(contact).then((value) {
                                  if (value != null) {
                                    sendVisitor(contact).then((valueAddVisit) {
                                      if (valueAddVisit) {
                                        showMessage(
                                            message:
                                                'Visiteur a été ajouté avec succès',
                                            context: context,
                                            color: primaryColor);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      } else {
                                        Navigator.pop(context);
                                        showMessage(
                                            message: 'Échec ...',
                                            context: context,
                                            color: Colors.red);
                                      }
                                    });
                                  } else {
                                    Navigator.pop(context);
                                    // showMessage(
                                    //     message: 'Échec de l\'ajout du contact',
                                    //     context: context,
                                    //     color: Colors.red);
                                  }
                                });
                              }
                            },
                            child: const Text(
                              "Valider",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<void> getCivilite() async {
    http.Response req = await http.get(Uri.parse(AppUrl.getCivilte), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res civ code: ${req.statusCode}");
    print("res civ body: ${req.body}");

    if (req.statusCode == 200 || req.statusCode == 201) {
      List<dynamic> data = json.decode(req.body);
      data.forEach((element) {
        civilit.add(TypeActivity(code: element['code'], name: element['lib']));
      });
    } else {
      print('Failed to load data');
    }
  }

  Future<Contact?> sendContact(Contact contact) async {
    print('ff: ${AppUrl.client.location}');
    var body = jsonEncode({
      "table": "CCT",
      "origin": '${contact.origin}',
      "civile": contact.civilte,
      "nom": contact.famillyName,
      "prenom": contact.firstName,
      "teld": contact.telDirect,
      "telm": contact.telMobile,
      "email": contact.email,
      "etbCode": AppUrl.user.etblssmnt!.code,
    });
    print('obj :$body');
    http.Response req =
        await http.post(Uri.parse(AppUrl.contact), body: body, headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res add contact code : ${req.statusCode}");
    print("res add contact body: ${req.body}");

    if (req.statusCode == 200 || req.statusCode == 201) {
      var res = json.decode(req.body);

      contact.code = res['numero'];
      return contact;
    } else {
      print('Failed to load data');
    }
    return null;
  }

  Future<bool> sendVisitor(Contact contact) async {
    String url = AppUrl.getAllCollaboratorsSalon;
    print('url : $url');
    var body = jsonEncode({
      "efsCode": widget.salon.code,
      "pcfCode": contact.origin,
      "cctCode": contact.code,
    });
    http.Response req = await http.post(Uri.parse(url), body: body, headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res addContact code : ${req.statusCode}");
    print("res addContact body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
