import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/concurrent.dart';
import 'package:mobilino_app/models/lot.dart';
import 'package:mobilino_app/models/plis.dart';
import 'package:mobilino_app/models/project.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/collaborator_page.dart';
import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:mobilino_app/widgets/text_field.dart';
import 'package:provider/provider.dart';

import '../activities_pages/activity_list_page.dart';
import 'concurrents_widget.dart';

class OuvertPlis extends StatefulWidget {
  final Project project;

  const OuvertPlis({super.key, required this.project});

  @override
  State<OuvertPlis> createState() => _OuvertPlisState();
}

class _OuvertPlisState extends State<OuvertPlis> {
  final List<String> options = ['Huis clos', 'Présentiel'];
  String currentOption = '';
  final TextEditingController _collaborators = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentOption = options[0];
    _collaborators.text = 'Ajouter des Collaborators';
  }

  Future<void> fetchDataPlis(Project project) async {
    String url = AppUrl.getProjectsOuvPlis + '${project.code}';
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res ouvOlis code : ${req.statusCode}");
    print("res ouvPlis body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.toList().forEach((element) {
        widget.project.plis.add(Plis(
          prjCode: element['prjCode'],
          cdcfCode: element['cdcfCode'],
          etbCode: element['etbCode'],
          attribution: element['attribution'],
          motif: element['motif'],
          nbConcurrents: element['nbConcurrents'],
          dateOuv: element['dateOuv'],
          salCodeOuv: element['salCodeOuv'],
          type: element['type'],
        ));
      });
    }
    await fetchDataLot(project);
    await fetchDataLotConcurrents(project);
    for (Lot lot in widget.project.lots) {
      lot.concurrent = widget.project.concurrent
          .where((lotElement) => lot.numLot == lotElement.numLot)
          .toList();
    }
  }

  Future<void> fetchDataLot(Project project) async {
    widget.project.lots = [];
    String url = AppUrl.getProjetLots + '${project.code}';
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res ouvOlis code : ${req.statusCode}");
    print("res ouvPlis body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      //data.toList().forEach((element) {
      for (int i = 0; i < data.length; i++) {
        var element = data[i];
        widget.project.lots.add(Lot(
          id: i + 1,
          prjCode: element['prjCode'],
          cdcfCode: element['cdcfCode'],
          numLot: element['numLot'],
          nomLot: element['nomLot'],
          attribue: element['attribue'],
          desc: element['descriptionLot'],
        ));
      }
      //});
    }
  }

  Future<void> fetchDataLotConcurrents(Project project) async {
    widget.project.concurrent = [];
    String url = AppUrl.getProjetLotsConcurrents + '${project.code}';
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res lotConcurrents code : ${req.statusCode}");
    print("res lotConcurrents body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.toList().forEach((element) {

        widget.project.concurrent.add(Concurrent(
            numLot: element['numLot'],
            pcfCode: element['pcfCode'],
            cdcfCode: element['cdcfCode'],
            name: element['concurrent']['rs'],
            total: element['montantLotHt'],
            ttc: element['montantLotTtc'],
            delay: element['delai'],
            note: element['notes'],
            res: element));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchDataPlis(widget.project),
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
          if (widget.project.plis.length > 0)
            return SingleChildScrollView(
              child: Column(
                children: [
                  OuvPlisItem(
                      project: widget.project, plis: widget.project.plis[0]),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Concurrents',
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  ConcurrentsWidget(
                    project: widget.project,
                  ),
                ],
              ),
            );
          else
            return SingleChildScrollView(
              child: Column(
                children: [
                  OuvPlisItem(
                    project: widget.project,
                    plis: Plis(),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Concurrents',
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  ConcurrentsWidget(
                    project: widget.project,
                  ),
                ],
              ),
            );
        });
  }
}

class OuvPlisItem extends StatefulWidget {
  final Project project;
  final Plis plis;

  OuvPlisItem({super.key, required this.project, required this.plis});

  @override
  State<OuvPlisItem> createState() => _OuvPlisItemState();
}

class _OuvPlisItemState extends State<OuvPlisItem> {
  final TextEditingController _collaborators = TextEditingController();
  final List<String> options = ['Huis-clos', 'Présentiel'];
  String currentOption = '';

  @override
  initState() {
    super.initState();
    if (widget.plis.type != null)
      currentOption = widget.plis.type!;
    else
      currentOption = options[0];
    _collaborators.text = 'Ajouter des Collaborators';
  }

  Future<void> showDateTimeDialog(BuildContext context) async {
    // Initialize result variables
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    // Show date picker
    selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            // Day color
            buttonTheme: ButtonThemeData(
              colorScheme: ColorScheme.light(
                primary: primaryColor, // Change the color here
              ),
            ),
            colorScheme: ColorScheme.light(primary: primaryColor)
                .copyWith(secondary: primaryColor),
            // Button text color
          ),
          child: child!,
        );
      },
    );

    // Check if date was selected
    if (selectedDate != null) {
      // Show time picker
      selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: primaryColor,
              // Day color
              buttonTheme: ButtonThemeData(
                colorScheme: ColorScheme.light(
                  primary: primaryColor, // Change the color here
                ),
              ),
              colorScheme: ColorScheme.light(primary: primaryColor)
                  .copyWith(secondary: primaryColor),
              // Button text color
            ),
            child: child!,
          );
        },
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
        widget.project.plisDate = selectedDateTime;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: AppUrl.getFullWidth(context) * 0.6,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            //Divider(color: Colors.grey),
            // SizedBox(height: 10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       'Ouverture des Plis :',
            //       style: Theme.of(context).textTheme.headline4,
            //     ),
            //   ],
            // ),
            // SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () {
                  //_selectStartDate(context);
                  showDateTimeDialog(context);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date et Heure d’ouverture: ',
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                          fontWeight: FontWeight.normal),
                    ),
                    (widget.project.plisDate != null)
                        ? Text(
                            '${DateFormat('yyyy-MM-dd').format(widget.project.plisDate!)}',
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text(
                'Collaborateurs',
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
                            .nextPage(page: CollaboratorsPage())
                            .then((value) {
                          _collaborators.text = '';
                          for (Collaborator collaborator
                              in AppUrl.user.selectedCollaborator)
                            _collaborators.text = _collaborators.text +
                                collaborator.userName! +
                                ' | ';
                          _collaborators.text
                              .substring(0, _collaborators.text.length - 2);
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
                      child: customTextField(
                        obscure: false,
                        enable: false,
                        controller: _collaborators,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type : ', style: Theme.of(context).textTheme.headline5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(
                            options[0],
                            style: TextStyle(color: Colors.black, fontSize: 11),
                          ),
                          leading: Radio(
                            activeColor: primaryColor,
                            value: options[0],
                            groupValue: currentOption,
                            onChanged: (value) {
                              setState(() {
                                currentOption = value.toString();
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(
                            options[1],
                            style: TextStyle(color: Colors.black, fontSize: 11),
                          ),
                          leading: Radio(
                            value: options[1],
                            activeColor: primaryColor,
                            groupValue: currentOption,
                            onChanged: (value) {
                              setState(() {
                                currentOption = value.toString();
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey),
            SizedBox(
              height: 5,
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
                  bool confirmed = await confirmationDialog
                      .showConfirmationDialog(context, 'confirmChang');
                  if (confirmed) {
                    showLoaderDialog(context);
                    Future.delayed(Duration(seconds: 1)).then((value) {
                      // showMessage(
                      //     message:
                      //     'Échec ...',
                      //     context: context,
                      //     color: Colors.red);
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
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

class LotConcurentItem extends StatefulWidget {
  const LotConcurentItem({super.key});

  @override
  State<LotConcurentItem> createState() => _LotConcurentItemState();
}

class _LotConcurentItemState extends State<LotConcurentItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Concurrents',
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        SizedBox(
          height: 10,
        ),
        ListView.builder(
          itemBuilder: (context, index) {},
        ),
      ],
    );
  }
}
