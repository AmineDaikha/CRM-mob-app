import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/project.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:mobilino_app/widgets/dialog_lib.dart';
import 'package:intl/intl.dart';
import 'package:mobilino_app/widgets/text_field.dart';

import '../activities_pages/activity_list_page.dart';
import 'concurrents_widget.dart';
import 'info_cdc.dart';
import 'ouver_plis.dart';

class ProcessingDetailsWidget extends StatefulWidget {
  final Project project;

  const ProcessingDetailsWidget({Key? key, required this.project})
      : super(key: key);

  @override
  State<ProcessingDetailsWidget> createState() =>
      _ProcessingDetailsWidgetState();
}

class _ProcessingDetailsWidgetState extends State<ProcessingDetailsWidget> {
  int selectedItemIndex = 0; // Index of the selected item
  List<String> tabs = [
    'CDC',
    'Ouverture des Plis',
    'Notes',
    'Activités',
    // 'Concurrents',
    // 'Résultats par lot',
    'Synthèse'
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 50.0, // Adjust the height of the container
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              // Number of items
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Handle item tap
                    setState(() {
                      selectedItemIndex = index;
                    });
                  },
                  child: Container(
                    width: 120.0,
                    // Adjust the width of each item
                    margin: EdgeInsets.all(8.0),
                    decoration: selectedItemIndex == index
                        ? BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                            width: 2.5,
                            color: Theme.of(context).primaryColor,
                          )))
                        : BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                            width: 2.5,
                            color: Colors.transparent,
                          ))),
                    // color: selectedItemIndex == index
                    //     ? Colors.blue // Color when item is selected
                    //     : Colors.grey,
                    // Default color
                    child: Center(
                      child: Text(
                        '${tabs[index]}',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.0),
          processingTabSelected()
          // Padding(
          //   padding:
          //       const EdgeInsets.symmetric(horizontal: 16, vertical: 1.0),
          //   child: Container(
          //     height: 800,
          //     width: double.infinity,
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.start,
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget processingTabSelected() {
    switch (selectedItemIndex) {
      case 0:
        return CDCWidget(project: widget.project);
      case 1:
        return OuvertPlis(project: widget.project);
      case 2:
        return Center(
          child: Text('Aucune note'),
        );
      case 3:
        return Center(
          child: Text('Aucune activité'),
        );
      case 4:
        return SyntheseWidget(project: widget.project);
      // case 4:
      //   return ConcurrentsWidget(project: widget.project,);
      //     //Center(child: Text('Pas des lots'),);
      // case 5:
      //   return Center(child: Text('Pas des lots'),);
      // case 6:
      //   return SyntheseWidget(project: widget.project);
    }
    return Container();
  }
}

class SyntheseWidget extends StatelessWidget {
  final TextEditingController _lib = TextEditingController();

  SyntheseWidget({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    if (project.res['cdcf']['synthese'] != null) {
      _lib.text = project.res['cdcf']['synthese'];
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
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
                project.res['cdcf']['synthese'] = _lib.text.trim();
                editSynthese(project).then((value) {
                  Navigator.pop(context);
                });
                // Future.delayed(Duration(seconds: 1)).then((value) {
                // showMessage(
                //     message:
                //     'Échec ...',
                //     context: context,
                //     color: Colors.red);
                //   Navigator.pop(context);
                // });
              }
            },
            child: Text(
              "        Valider        ",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> editSynthese(Project project) async {
    String url = AppUrl.projects + '/${project.code}';
    print('url: $url');
    print('obj json: ${project.res['users']}');
    print('sal: ${AppUrl.user.salCode}');
    http.Response req =
        await http.put(Uri.parse(url), body: jsonEncode(project.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res editProject code : ${req.statusCode}");
    print("res editProject body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
