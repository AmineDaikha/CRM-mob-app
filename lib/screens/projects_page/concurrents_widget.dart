import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/concurrent.dart';
import 'package:mobilino_app/models/lot.dart';
import 'package:mobilino_app/models/project.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/concurrent_list_page.dart';
import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:mobilino_app/widgets/text_field.dart';

class ConcurrentsWidget extends StatelessWidget {
  final Project project;

  ConcurrentsWidget({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    print('gjigit ${project.res['cdcf']['nbLot']}');
    // for (int i = 0; i < project.res['cdcf']['nbLot']; i++) {
    //   lots.add(Lot(id: i + 1, nomLot: 'lot ${i + 1}'));
    // }
    print('hhhh : ${project.lots.length}');
    return FutureBuilder(
        //future: fetchConcurrents(),
        future: null,
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
          return Container(
            height: AppUrl.getFullHeight(context) * 0.8,
            child: ListView.builder(
              itemCount: project.res['cdcf']['nbLot'],
              itemBuilder: (context, index) {
                return LotConcurentItem(lot: project.lots[index]);
              },
            ),
          );
        });
  }

// Future<void> fetchConcurrents() async {
//   project.concurrent.clear();
//   String url = AppUrl.getTiersConcurrents;
//   print('url: $url');
//   http.Response req = await http.get(Uri.parse(url), headers: {
//     "Accept": "application/json",
//     "content-type": "application/json; charset=UTF-8",
//     "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
//   });
//   print("res getConcurrent code : ${req.statusCode}");
//   print("res getConcurrent body: ${req.body}");
//   if (req.statusCode == 200) {
//     List<dynamic> data = json.decode(req.body);
//     print('concurrentsSize: ${data.length}');
//     data.toList().forEach((element) {
//       project.concurrent
//           .add(Concurrent(pcfCode: element['code'], name: element['rs']));
//     });
//   }
// }
}

class LotConcurentItem extends StatefulWidget {
  Lot lot;

  LotConcurentItem({super.key, required this.lot});

  @override
  State<LotConcurentItem> createState() => _LotConcurentItemState();
}

class _LotConcurentItemState extends State<LotConcurentItem> {
  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int lenghtOfConcurrent = 110;
    if (widget.lot.concurrent.length > 0)
      lenghtOfConcurrent = 100 * widget.lot.concurrent.length;
    print('htjitt : ${widget.lot.concurrent.length}');
    return Container(
      height: 200,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Concurrents lot ${widget.lot.id}',
                style: Theme.of(context).textTheme.headline5!.copyWith(
                    color: Colors.black, fontWeight: FontWeight.normal),
              ),
              IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddConcurrentDialog(
                          client: Client(),
                          lot: widget.lot,
                          type: 'add',
                        );
                      },
                    ).then((value) {
                      setState(() {});
                    });
                  },
                  icon: Icon(
                    Icons.add_circle_outline_sharp,
                    color: primaryColor,
                  ))
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 100, //lenghtOfConcurrent.toDouble(),
            child: (widget.lot.concurrent.length == 0)
                ? Text('Aucun concurrent')
                : ListView.separated(
                    separatorBuilder: (context, index) => Container(
                      height: 5,
                      color: Colors.white,
                    ),
                    itemCount: widget.lot.concurrent.length,
                    itemBuilder: (context, index) {
                      return ConcurentItem(
                        concurrent: widget.lot.concurrent[index],
                        lot: widget.lot,
                        callback: reload,
                      );
                    },
                  ),
          ),
          Divider(),
        ],
      ),
    );
  }
}

class ConcurentItem extends StatefulWidget {
  final Concurrent concurrent;
  final Lot lot;
  final VoidCallback callback;

  const ConcurentItem(
      {super.key,
      required this.concurrent,
      required this.lot,
      required this.callback});

  @override
  State<ConcurentItem> createState() => _ConcurentItemState();
}

class _ConcurentItemState extends State<ConcurentItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddConcurrentDialog(
              client: Client(),
              lot: widget.lot,
              concurrent: widget.concurrent,
              type: 'edit',
            );
          },
        ).then((value) {
          setState(() {});
        });
      },
      child: Container(
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
                  child: Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    'CONCURRENT : ${widget.concurrent.name}',
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                  ),
                ),
                Text(
                  'Total : ${AppUrl.formatter.format(widget.concurrent.total)} DZD',
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.normal,
                      ),
                ),
                // Text(
                //   'TVA : ${AppUrl.formatter.format(widget.concurent.tva)} DZD',
                //   style: Theme.of(context).textTheme.headline5!.copyWith(
                //         color: primaryColor,
                //         fontWeight: FontWeight.normal,
                //       ),
                // ),
                Text(
                  'TTC : ${AppUrl.formatter.format(widget.concurrent.ttc)} DZD',
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                        color: primaryColor,
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
                        deleteProjetLotsConcurrents(widget.concurrent)
                            .then((value) {
                          if (value) {
                            showMessage(
                                message:
                                    'Le concurrent a été supprimé avec succès',
                                context: context,
                                color: primaryColor);
                            widget.lot.concurrent.remove(widget.concurrent);
                            widget.callback();
                            Navigator.pop(context);
                          } else {
                            showMessage(
                                message:
                                    'Échec de la supprission du concurrent',
                                context: context,
                                color: Colors.red);
                            Navigator.pop(context);
                          }
                        });
                      }
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    )),
                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddConcurrentDialog(
                            client: Client(),
                            lot: widget.lot,
                            concurrent: widget.concurrent,
                            type: 'edit',
                          );
                        },
                      ).then((value) {
                        setState(() {});
                      });
                    },
                    icon: Icon(
                      Icons.edit_note_outlined,
                      color: primaryColor,
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> deleteProjetLotsConcurrents(Concurrent concurrent) async {
    String url = AppUrl.projetLotsConcurrents +
        '/${widget.lot.prjCode}/${widget.lot.cdcfCode}/${concurrent.pcfCode}/${concurrent.numLot}';
    http.Response req = await http
        .delete(Uri.parse(url), body: jsonEncode(concurrent.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res deleteConcurrent code : ${req.statusCode}");
    print("res deleteConcurrent body: ${req.body}");
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
  TextEditingController _delay = TextEditingController();
  TextEditingController _ttc = TextEditingController();
  TextEditingController _note = TextEditingController();
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
      if (widget.concurrent!.delay != null)
        _delay.text = widget.concurrent!.delay.toString();
      if (widget.concurrent!.note != null)
        _note.text = widget.concurrent!.note.toString();
      _ttc.text = widget.concurrent!.ttc.toString();
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
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: customTextField(
                    obscure: false,
                    controller: _delay,
                    maxLines: null,
                    hint: 'Écrivez le délai (nb jours)',
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: customTextFieldEmpty(
                    obscure: false,
                    controller: _note,
                    maxLines: null,
                    hint: 'Écrivez la note',
                    // keyboardType:
                    //     TextInputType.numberWithOptions(decimal: true),
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
                                delay: int.parse(_delay.text.trim()),
                                total: double.parse(_total.text.trim()),
                                ttc: double.parse(_ttc.text.trim()),
                                note: _note.text.trim(),
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
                            widget.concurrent!.delay =
                                int.parse(_delay.text.trim());
                            widget.concurrent!.note = _note.text.trim();
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
      "delai": concurrent.delay,
      "notes": concurrent.note,
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
    concurrent.res['delai'] = concurrent.delay;
    concurrent.res['notes'] = concurrent.note;
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
