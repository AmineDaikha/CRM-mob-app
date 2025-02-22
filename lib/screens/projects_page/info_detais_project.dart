import 'package:flutter/material.dart';
import 'package:mobilino_app/models/project.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/widgets/dialog_lib.dart';
import 'package:intl/intl.dart';

class ProjectDetailsWidget extends StatelessWidget {
  final Project project;

  const ProjectDetailsWidget({Key? key, required this.project})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 1.0),
                child: Container(
                  height: 600,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (project.object != null)
                          ? GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return LibDialog(
                                      lib: project.object,
                                    );
                                  },
                                ).then((value) {
                                  project.object = value;
                                  // Update the UI when the dialog is dismissed
                                  // by setting the new value and triggering a rebuild.
                                  //setState(() {});
                                });
                              },
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Code du projet: ${project.code!}',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Intitulé du projet: ',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3!
                                              .copyWith(
                                                  fontWeight:
                                                      FontWeight.normal),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: Text(
                                            '${project.object!}',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline3!
                                                .copyWith(color: primaryColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      'Statut: (${project.status})',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline3!
                                          .copyWith(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.red),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Type du projet:  ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4!
                                                    .copyWith()),
                                            Text(
                                                '${project.res['type']['lib']}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4!
                                                    .copyWith(
                                                        color: Colors.blue)),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Sous type du projet:  ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4!
                                                    .copyWith()),
                                            (project.res['sType'] != null)
                                                ? Text(
                                                    '${project.res['sType']['lib']}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline4!
                                                        .copyWith(
                                                            color: Colors.blue))
                                                : Container(),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Description projet:  ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4!
                                                    .copyWith()),
                                            (project.res['description'] != null)
                                                ? Text(
                                                    '${project.res['description']}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline4!
                                                        .copyWith(
                                                            color: Colors.blue))
                                                : Container(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return LibDialog(
                                      lib: project.object,
                                    );
                                  },
                                ).then((value) {
                                  project.object = value;
                                  // Update the UI when the dialog is dismissed
                                  // by setting the new value and triggering a rebuild.
                                  //setState(() {});
                                });
                              },
                              child: Center(
                                child: Text('Nom de l\'Affaire',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline2!
                                        .copyWith(color: Colors.black)),
                              ),
                            ),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            //_selectStartDate(context);
                            //showDateTimeDialog(context);
                          },
                          child: Text(
                            'Nombre de lot: ${project.res['cdcf']['nbLot']}',
                            style:
                                Theme.of(context).textTheme.headline4!.copyWith(
                                    //fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            //_selectStartDate(context);
                            //showDateTimeDialog(context);
                          },
                          child: Text(
                            'Date début : ${DateFormat('dd-MM-yyyy').format(project.startDate!)}',
                            style: Theme.of(context)
                                .textTheme
                                .headline2!
                                .copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            //_selectStartDate(context);
                            //showDateTimeDialog(context);
                          },
                          child: Text(
                            'Date fin : ${DateFormat('dd-MM-yyyy').format(project.endDate!)}',
                            style: Theme.of(context)
                                .textTheme
                                .headline2!
                                .copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            //_selectStartDate(context);
                            //showDateTimeDialog(context);
                          },
                          child: (project.delivryDate != null)
                              ? Text(
                                  'Date de livraison: ${DateFormat('dd-MM-yyyy').format(project.delivryDate!)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal),
                                )
                              : Container(),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: Text(
                          'Tiers : ${project.client!.name!}',
                          style: Theme.of(context)
                              .textTheme
                              .headline2!
                              .copyWith(color: Colors.black),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onPressed: () {
                    // Handle button press
                  },
                  child: Text(
                    "Modifier l'état",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
