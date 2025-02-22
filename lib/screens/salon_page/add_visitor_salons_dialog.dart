import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/contact.dart';
import 'package:mobilino_app/models/pipeline.dart';
import 'package:mobilino_app/models/salon.dart';
import 'package:mobilino_app/models/step_pip.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/screens/clients_page/add_client_page1.dart';
import 'package:mobilino_app/screens/home_page/clients_list_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:mobilino_app/widgets/contacts_page.dart';
import 'package:mobilino_app/widgets/text_field.dart';

import 'add_contact_page.dart';

class AddVisitorDialog extends StatefulWidget {
  Client client = Client();
  final Salon salon;

  AddVisitorDialog({super.key, required this.salon});

  @override
  State<AddVisitorDialog> createState() => _FiltredCommandsClientDialogState();
}

class _FiltredCommandsClientDialogState extends State<AddVisitorDialog> {
  final TextEditingController _client = TextEditingController();
  final TextEditingController _contacts = TextEditingController();
  List<Contact> contactTier = [];

  @override
  void initState() {
    super.initState();
    _client.text = 'Sélectionner un Tiers';
    _contacts.text = 'Ajouter des Contacts';
  }

  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Ajouter un visiteur',
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
          height: 318,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          PageNavigator(ctx: context)
                              .nextPage(
                                  page: ClientsListForAddClientPage(
                            callback: reload,
                          ))
                              .then((value) async {
                            print('finish add ${AppUrl.selectedClient}');
                            if (AppUrl.selectedClient == null) return;
                            if (AppUrl.selectedClient!.id == null) return;
                            widget.client.name = AppUrl.selectedClient!.name;
                            widget.client.id = AppUrl.selectedClient!.id;
                            _client.text = widget.client.name!;
                            // get contacts
                            final Map<String, String> headers = {
                              "Accept": "application/json",
                              "content-type": "application/json; charset=UTF-8",
                              "Referer": "http://" +
                                  AppUrl.user.company! +
                                  ".localhost:4200/",
                              'Authorization': 'Bearer ${AppUrl.user.token}',
                            };
                            String url = AppUrl.getContacts + widget.client.id!;
                            print('url of getContacts $url');
                            http.Response req = await http.get(Uri.parse(url),
                                headers: headers);
                            print("res contacts code : ${req.statusCode}");
                            print("res contacts body: ${req.body}");
                            if (req.statusCode == 200 ||
                                req.statusCode == 201) {
                              widget.client.contacts = [];
                              List<dynamic> data = json.decode(req.body);
                              data.forEach((element) {
                                widget.client.contacts.add(Contact(
                                  code: element['code'],
                                  num: element['numero'],
                                  origin: element['origin'],
                                  famillyName: element['nom'],
                                  firstName: element['prenom'],
                                ));
                              });
                              contactTier = widget.client.contacts;
                            }
                            print(
                                'sizeContacts ${widget.client.contacts.length}');
                            print('contactTier ${contactTier.length}');
                            reload();
                          });
                        },
                        icon: Icon(
                          Icons.person_add_alt,
                          color: primaryColor,
                        ),
                      ),
                      // Your icon
                      SizedBox(width: 16.0),
                      // Adjust the space between icon and text field
                      Expanded(
                        child: customTextField(
                          obscure: false,
                          enable: false,
                          controller: _client,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    PageNavigator(ctx: context)
                        .nextPage(page: AddClientPage1())
                        .then((value) {
                      print('finish add');
                      reload();
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Le tier n\'existe pas ?',
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor),
                          ),
                          Text(
                            'Ajouter un nouveau tier',
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 1.0,
                                    decorationColor: primaryColor,
                                    color: primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: Text(
                    'Contacts de Tiers',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            PageNavigator(ctx: context)
                                .nextPage(
                                    page: ContactsPage(
                                        contacts: widget.client.contacts,
                                        client: widget.client))
                                .then((value) {
                              _contacts.text = '';
                              for (Contact contact
                                  in AppUrl.user.selectedContact)
                                _contacts.text = _contacts.text +
                                    contact.famillyName! +
                                    ' ' +
                                    contact.firstName! +
                                    ' | ';
                              _contacts.text
                                  .substring(0, _contacts.text.length - 2);
                            });
                          },
                          icon: Icon(
                            Icons.group_add_outlined,
                            color: primaryColor,
                          ),
                        ),
                        // Your icon
                        SizedBox(width: 16.0),
                        // Adjust the space between icon and text field
                        Expanded(
                          child: customTextFieldEmptyActivityContacts(
                            obscure: false,
                            enable: false,
                            controller: _contacts,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_client.text.isEmpty ||
                        _client.text.trim() == 'Sélectionner un Tiers') {
                      showAlertDialog(
                          context, 'Il faut selectionner le tier d\'abord !');
                      return;
                    }
                    try {
                      if (AppUrl.selectedClient!.id == null)
                        showAlertDialog(
                            context, 'Il faut selectionner le tier d\'abord !');
                    } catch (_) {
                      showAlertDialog(
                          context, 'Il faut selectionner le tier d\'abord !');
                      return;
                    }
                    PageNavigator(ctx: context)
                        .nextPage(
                            page: AddNewContactPage(client: this.widget.client, salon: widget.salon,))
                        .then((value) {
                      print('finish add');
                      reload();
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Le contact n\'existe pas ?',
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor),
                          ),
                          Text(
                            'Ajouter un nouveau contact',
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 1.0,
                                    decorationColor: primaryColor,
                                    color: primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onPressed: () async {
                    if (_contacts.text.isNotEmpty &&
                        _contacts.text.trim() != 'Ajouter des Contacts' &&
                        AppUrl.user.selectedContact.length > 0) {
                      ConfirmationDialog confirmationDialog =
                          ConfirmationDialog();
                      bool confirmed = await confirmationDialog
                          .showConfirmationDialog(context, 'confirmChang');
                      if (confirmed) {
                        showLoaderDialog(context);
                        sendVisitor(AppUrl.user.selectedContact.first)
                            .then((value) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          if (value) {
                            showMessage(
                                message: 'Visiteur a été ajouté avec succès',
                                context: context,
                                color: primaryColor);
                          } else {
                            showMessage(
                                message: 'Échec ... Le visiteur existe déja',
                                context: context,
                                color: Colors.red);
                          }
                        });
                      }
                    } else {
                      showAlertDialog(
                          context, 'Il faut selectionner les contacts!');
                    }
                  },
                  child: const Text(
                    "Ajouter",
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

  Future<bool> sendVisitor(Contact contact) async {
    String url = AppUrl.getAllCollaboratorsSalon;
    print('url : $url');
    var body = jsonEncode({
      "efsCode": widget.salon.code,
      "pcfCode": AppUrl.selectedClient!.id,
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
