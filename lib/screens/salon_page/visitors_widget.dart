import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/constants/utils.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/concurrent.dart';
import 'package:mobilino_app/models/contact.dart';
import 'package:mobilino_app/models/lot.dart';
import 'package:mobilino_app/models/salon.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/concurrent_list_page.dart';
import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:mobilino_app/widgets/text_field.dart';

import 'add_visitor_salons_dialog.dart';

class VisitorssWidget extends StatefulWidget {
  final Salon salon;

  VisitorssWidget({super.key, required this.salon});

  @override
  State<VisitorssWidget> createState() => _VisitorssWidgetState();
}

class _VisitorssWidgetState extends State<VisitorssWidget> {
  List<Contact> contacts = [];

  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        //future: fetchConcurrents(),
        future: fetchDataVisitors(),
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
            floatingActionButton: FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddVisitorDialog(salon: widget.salon,);
                  },
                ).then((value) {
                  setState(() {});
                });
              },
              child: Icon(
                Icons.person_add_alt,
                color: Colors.white,
              ),
            ),
            body: Container(
              height: AppUrl.getFullHeight(context) * 0.8,
              padding: EdgeInsets.only(top: 20, right: 10, left: 10),
              child: (contacts.length > 0)
                  ? ListView.separated(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        return VisitorItem(
                          contact: contacts[index],
                          callback: reload,
                          contacts: contacts,
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                          height: 5,
                        );
                      },
                    )
                  : Center(
                      child: Text('Aucun visiteur !'),
                    ),
            ),
          );
        });
  }

  Future<void> fetchDataVisitors() async {
    contacts = [];
    String url = AppUrl.getAllCollaboratorsSalon + '?efsCode=${widget.salon.code}';
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res visitor code : ${req.statusCode}");
    print("res visitor body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      //activitiesProcesses[process] = types;
      print('efrfr : ${data.length}');
      //data.toList().forEach((element) {
      for(int i = 0; i<data.length; i++) {
        var element = data[i];
        try {
          print('elemnt : $element');
          Contact contact = Contact(
            efsCode: element['efsCode'],
            origin: element['contact']['origin'],
            firstName: element['contact']['prenom'],
            famillyName: element['contact']['nom'],
            date: DateTime.parse(element['contact']['dtcre']),
            telMobile: element['contact']['telm'],
            telDirect: element['contact']['teld'],
          );
          contact.res = element;
          contacts.add(contact);
        } catch (e) {
          print(e);
          continue;
        }
      }
        //});
    }
  }
}

class VisitorItem extends StatefulWidget {
  final Contact contact;
  final VoidCallback callback;
  final List<Contact> contacts;

  const VisitorItem(
      {super.key,
      required this.contact,
      required this.callback,
      required this.contacts});

  @override
  State<VisitorItem> createState() => _VisitorItemState();
}

class _VisitorItemState extends State<VisitorItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.all(8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor),
        // Set border color to red
        borderRadius:
            BorderRadius.circular(10.0), // Optional: Set border radius
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 200,
                child: Row(
                  children: [
                    Text(
                      'Visiteur : ',
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      '${widget.contact.famillyName} ${widget.contact.firstName}',
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                'Entreprise associé : ${widget.contact.origin}',
                style: Theme.of(context).textTheme.headline5!.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
              ),
              Text(
                'Date : ${DateFormat('dd-MM-yyyy').format(widget.contact.date!)}',
                style: Theme.of(context).textTheme.headline4!.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () async {
                    ConfirmationDialog confirmationDialog =
                        ConfirmationDialog();
                    bool confirmed = await confirmationDialog
                        .showConfirmationDialog(context, 'confirmChang');
                    if (confirmed) {
                      showLoaderDialog(context);
                      deleteSalonVisitor(widget.contact).then((value) {
                        if (value) {
                          showMessage(
                              message: 'Le visiteur a été supprimé avec succès',
                              context: context,
                              color: primaryColor);
                          widget.contacts.remove(widget.contact);
                          widget.callback();
                          Navigator.pop(context);
                        } else {
                          showMessage(
                              message: 'Échec de la supprission du contact',
                              context: context,
                              color: Colors.red);
                          Navigator.pop(context);
                        }
                      });
                    }
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  )),
              IconButton(
                  onPressed: () {
                    if (widget.contact.telMobile != null)
                      PhoneUtils().makePhoneCall(widget.contact.telMobile!);
                    else
                      showAlertDialog(context,
                          'pas de numéro de téléphone pour ce contact');
                  },
                  icon: Icon(
                    Icons.call_outlined,
                    color: primaryColor,
                  ))
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> deleteSalonVisitor(Contact contact) async {
    String url = AppUrl.getAllCollaboratorsSalon + '/${contact.efsCode}/${contact.origin}';
    print('url : $url');
    http.Response req = await http
        .delete(Uri.parse(url), body: jsonEncode(contact.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res deleteContact code : ${req.statusCode}");
    print("res deleteContact body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}

class AddConcurrentDialog extends StatefulWidget {
  Client client;
  Lot lot;
  String type;
  Concurrent? concurrent;

  AddConcurrentDialog(
      {required this.client,
      required this.lot,
      required this.type,
      this.concurrent});

  @override
  State<AddConcurrentDialog> createState() => _AddConcurrentDialogState();
}

class _AddConcurrentDialogState extends State<AddConcurrentDialog> {
  TextEditingController _client = TextEditingController();
  TextEditingController _total = TextEditingController();

  //TextEditingController _tva = TextEditingController();
  TextEditingController _ttc = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String txtBtn = 'Ajouter';

  void reload() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _client.text = 'Ajouter un Concurrent';
    if (widget.type == 'edit') {
      txtBtn = 'Modifier';
      _client.text = widget.concurrent!.name!;
      _total.text = widget.concurrent!.total.toString();
      //_tva.text = widget.concurrent!.tva.toString();
      _ttc.text = widget.concurrent!.ttc.toString();
      print('jfndk : ${widget.concurrent!.pcfCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
        key: formKey,
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (widget.type == 'edit') return;
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
                            reload();
                          });
                        },
                        icon: (widget.type == 'add')
                            ? Icon(
                                Icons.person_add_alt,
                                color: primaryColor,
                              )
                            : Icon(
                                Icons.person,
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
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: customTextField(
                    obscure: false,
                    controller: _total,
                    maxLines: null,
                    hint: 'Écrivez le Total',
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                //   child: customTextField(
                //     obscure: false,
                //     controller: _tva,
                //     maxLines: null,
                //     hint: 'Écrivez le TVA',
                //     keyboardType:
                //         TextInputType.numberWithOptions(decimal: true),
                //   ),
                // ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: customTextField(
                    obscure: false,
                    controller: _ttc,
                    maxLines: null,
                    hint: 'Écrivez le TTC',
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    onPressed: () async {
                      if (widget.type == 'add') {
                        if (widget.client.name == null) {
                          showAlertDialog(context,
                              'Il faut choisir le concurrent d\'abord');
                          return;
                        }
                        if (formKey.currentState != null &&
                            formKey.currentState!.validate()) {
                          // final provider = Provider.of<ActivityProvider>(context,
                          //     listen: false);
                          // provider.activityList.add(activity);
                          ConfirmationDialog confirmationDialog =
                              ConfirmationDialog();
                          bool confirmed = await confirmationDialog
                              .showConfirmationDialog(context, 'confirmChang');
                          if (confirmed) {
                            // confirm
                            showLoaderDialog(context);
                            Concurrent concurrent = Concurrent(
                                numLot: widget.lot.numLot,
                                pcfCode: AppUrl.selectedClient!.id,
                                total: double.parse(_total.text.trim()),
                                ttc: double.parse(_ttc.text.trim()),
                                name: AppUrl.selectedClient!.name);
                            sendProjetLotsConcurrents(concurrent).then((value) {
                              if (value) {
                                widget.lot.concurrent.add(concurrent);
                                showMessage(
                                    message:
                                        'Le concurrent a été ajouté avec succès',
                                    context: context,
                                    color: primaryColor);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              } else {
                                showMessage(
                                    message: 'Échec de l\'ajout du concurrent',
                                    context: context,
                                    color: Colors.red);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            });
                            // Future.delayed(Duration(seconds: 1)).then((value) {

                            // });
                          }
                        }
                      } else {
                        if (formKey.currentState != null &&
                            formKey.currentState!.validate()) {
                          // final provider = Provider.of<ActivityProvider>(context,
                          //     listen: false);
                          // provider.activityList.add(activity);
                          ConfirmationDialog confirmationDialog =
                              ConfirmationDialog();
                          bool confirmed = await confirmationDialog
                              .showConfirmationDialog(context, 'confirmChang');
                          if (confirmed) {
                            // confirm
                            showLoaderDialog(context);
                            widget.concurrent!.total =
                                double.parse(_total.text.trim());
                            widget.concurrent!.ttc =
                                double.parse(_ttc.text.trim());
                            editProjetLotsConcurrents(widget.concurrent!)
                                .then((value) {
                              if (value) {
                                showMessage(
                                    message:
                                        'Le concurrent a été modifié avec succès',
                                    context: context,
                                    color: primaryColor);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              } else {
                                showMessage(
                                    message:
                                        'Échec de la modification du concurrent',
                                    context: context,
                                    color: Colors.red);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            });
                            // Future.delayed(Duration(seconds: 1)).then((value) {

                            // });
                          }
                        }
                      }
                    },
                    child: Text(
                      "$txtBtn",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> sendProjetLotsConcurrents(Concurrent concurrent) async {
    String url = AppUrl.projetLotsConcurrents;
    print('url: $url');
    Map<String, dynamic> jsonObject = {
      "prjCode": "${widget.lot.prjCode}",
      "cdcfCode": "${widget.lot.cdcfCode}",
      "pcfCode": "${concurrent.pcfCode}",
      "numLot": concurrent.numLot,
      "montantLotHt": concurrent.total,
      "montantLotTtc": concurrent.ttc,
      "notes": null,
      "attribue": false,
    };
    print('obj json: $jsonObject');
    http.Response req =
        await http.post(Uri.parse(url), body: jsonEncode(jsonObject), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res addConcurrent code : ${req.statusCode}");
    print("res addConcurrent body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> editProjetLotsConcurrents(Concurrent concurrent) async {
    String url = AppUrl.projetLotsConcurrents +
        '/${widget.lot.prjCode}/${widget.lot.cdcfCode}/${concurrent.pcfCode}/${concurrent.numLot}';
    print('url: $url');
    concurrent.res['montantLotHt'] = concurrent.total;
    concurrent.res['montantLotTtc'] = concurrent.ttc;
    print('obj json: ${concurrent.res}');
    http.Response req = await http
        .put(Uri.parse(url), body: jsonEncode(concurrent.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res editConcurrent code : ${req.statusCode}");
    print("res editConcurrent body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
