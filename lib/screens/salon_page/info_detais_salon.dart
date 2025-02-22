import 'package:flutter/material.dart';
import 'package:mobilino_app/models/project.dart';
import 'package:mobilino_app/models/salon.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/widgets/dialog_lib.dart';
import 'package:intl/intl.dart';

import 'articles_widget.dart';
import 'collaborators_widget.dart';

class SalonDetailsWidget extends StatefulWidget {
  final Salon salon;

  const SalonDetailsWidget({Key? key, required this.salon}) : super(key: key);

  @override
  State<SalonDetailsWidget> createState() => _SalonDetailsWidgetState();
}

class _SalonDetailsWidgetState extends State<SalonDetailsWidget> {
  int selectedItemIndex = 0; // Index of the selected item
  List<String> tabs = [
    'Détails de la foire / salon',
    'Equipes assigné',
    'Equipements Utilisés',
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
                    width: 150.0,
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
        ],
      ),
    );
  }

  Widget processingTabSelected() {
    switch (selectedItemIndex) {
      case 0:
        return DetailsSalonWidget(salon: widget.salon);
      case 1:
        return CollaboratorsWidget(salon: widget.salon);
      case 2:
        return ArticlesWidget(salon: widget.salon);
    }
    return Container();
  }
}


class DetailsSalonWidget extends StatefulWidget {
  const DetailsSalonWidget({
    super.key,
    required this.salon,
  });

  final Salon salon;

  @override
  State<DetailsSalonWidget> createState() => _DetailsSalonWidgetState();
}

class _DetailsSalonWidgetState extends State<DetailsSalonWidget> {
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
                  height: 500,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (widget.salon.object != null)
                          ? GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return LibDialog(
                                      lib: widget.salon.object,
                                    );
                                  },
                                ).then((value) {
                                  widget.salon.object = value;
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
                                      'Code : ${widget.salon.code!}',
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
                                          'Intitulé : ',
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
                                            '${widget.salon.object!}',
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
                                      'Statut: (${widget.salon.status})',
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
                                            Text('Type : ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4!
                                                    .copyWith()),
                                            (widget.salon.res['typeT']['lib'] != null) ? Text('${widget.salon.res['typeT']['lib']}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4!
                                                    .copyWith(
                                                        color: Colors.blue)) : Container(),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Lieu : ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4!
                                                    .copyWith()),
                                            (widget.salon.res['lieuT']['lib'] != null) ?Text('${widget.salon.res['lieuT']['lib']}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4!
                                                    .copyWith(
                                                        color: Colors.blue)) : Container(),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Description : ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4!
                                                    .copyWith()),
                                            (widget.salon.res['description'] !=
                                                    null)
                                                ? Text(
                                                    '${widget.salon.res['description']}',
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
                                      lib: widget.salon.object,
                                    );
                                  },
                                ).then((value) {
                                  widget.salon.object = value;
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
                            'Date début : ${DateFormat('dd-MM-yyyy').format(widget.salon.startDate!)}',
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
                            'Date fin : ${DateFormat('dd-MM-yyyy').format(widget.salon.endDate!)}',
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
                          child: (widget.salon.delivryDate != null)
                              ? Text(
                                  'Date de livraison: ${DateFormat('dd-MM-yyyy').format(widget.salon.delivryDate!)}',
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
                          'Tiers : ${widget.salon.client!.name!}',
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
