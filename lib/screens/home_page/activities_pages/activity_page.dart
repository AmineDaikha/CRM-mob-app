import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/activity.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/process.dart';
import 'package:mobilino_app/models/type_activity.dart';
import 'package:mobilino_app/providers/activity_provider.dart';
import 'package:mobilino_app/screens/activities_pages/dialog_cancel_activities.dart';
import 'package:mobilino_app/screens/activities_pages/report_activities.dart';
import 'package:mobilino_app/screens/home_page/clients_list_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:mobilino_app/widgets/text_field.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'camera_page.dart';
import 'notes_page/note_liste_page.dart';

class ActivityPage extends StatefulWidget {
  final VoidCallback callback;
  final Client client;
  late Activity activity;
  final List<Process> allProcesses;
  final List<TypeActivity> allTypes;

  //final Map<Process, List<TypeActivity>> activitiesProcesses;

  ActivityPage({
    super.key,
    required this.callback,
    required this.client,
    required this.activity,
    required this.allProcesses,
    required this.allTypes,
    //required this.activitiesProcesses
  });

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<TypeActivity> actionTypes = [];
  BoxDecoration decoration = BoxDecoration(
      border: Border(
    bottom: BorderSide(width: 2.5, color: primaryColor),
    // left: BorderSide(width: 2.5, color: white),
    // right: BorderSide(width: 2.5, color: white),
    // top: BorderSide(width: 2.5, color: white),
  ));
  late Activity oldActivity;
  late Opacity validateButton;
  late DateTime selectedStartTimeDate = DateTime.now();
  late DateTime selectedEndTimeDate = DateTime.now();
  late Process? selectedProcessesItem;
  late TypeActivity? selectedTypeItem = TypeActivity();
  String selectedStateItem = '';

  String selectedTypeTierItem = '';
  String selectedContactTierItem = '';
  String selectedServiceItem = '';
  double ratingPriority = 0.0;
  double ratingEmergency = 0.0;
  final formKey = GlobalKey<FormState>();
  final TextEditingController _comment = TextEditingController();
  final TextEditingController _service = TextEditingController();
  final TextEditingController _object = TextEditingController();
  final TextEditingController _client = TextEditingController();

  List<Process> processes = [];
  List<String> services = [
    'En attente',
    'En cours',
    'Terminée',
    'Non réalisée',
    'Annulée'
  ];
  List<String> states = [
    'En attente',
    'En cours',
    'Terminée',
    'Non réalisée',
    'Annulée',
    'Reporter'
  ];
  List<String> typesTier = [
    'Prospect',
    'Client',
    'Client Export',
    'Fournisseur Local',
    'Fournisseur Etranger'
  ];

  List<String> contactTier = [
    'Prospect',
    'Client',
    'Client Export',
    'Fournisseur Local',
    'Fournisseur Etranger'
  ];

  //List<String> typesList = ['Création Devis', 'Qualification Opportunité', 'Rdv Client', 'Négociation', 'Réunion de travail'];

  Future<void> showDateTimeDialog(BuildContext context, String type) async {
    // Initialize result variables
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    // Show date picker
    selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    // Check if date was selected
    if (selectedDate != null) {
      // Show time picker
      selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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
        if (type == 'start')
          selectedStartTimeDate = selectedDateTime;
        else
          selectedEndTimeDate = selectedDateTime;
        print('date:: $type');
        reload();
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('oppoCodeIs : ${widget.activity.client.idOpp}');
    _client.text = widget.client.name!;
    oldActivity = widget.activity.cloneActivity();
    selectedStateItem = widget.activity.state!;
    selectedTypeTierItem = typesTier.first;
    selectedContactTierItem = contactTier.first;
    if (widget.activity.service != null)
      selectedServiceItem = widget.activity.service!;
    else
      selectedServiceItem = services.first;
    selectedProcessesItem = widget.activity.processes!;
    selectedTypeItem = widget.activity.type!;
    actionTypes = widget.allTypes
        .where((element) => selectedProcessesItem!.code == element.divers)
        .toList();
    selectedStartTimeDate = widget.activity.dateStart!;
    selectedEndTimeDate = widget.activity.dateEnd!;
    if (widget.activity.emergency != null)
      ratingEmergency = widget.activity.emergency!;
    else
      ratingEmergency = 0.0;
    ratingPriority = widget.activity.priority!;
    if (widget.activity.object != null) _object.text = widget.activity.object!;
    if (widget.activity.comment != null)
      _comment.text = widget.activity.comment!;
    // if (widget.activitiesProcesses.keys.isNotEmpty) {
    //   selectedProcessesItem = widget.activitiesProcesses.keys.toList().first;
    //   print('fff: ${widget.activitiesProcesses[selectedProcessesItem]!.length}');
    //   if (widget.activitiesProcesses[selectedProcessesItem]!.isNotEmpty)
    //     selectedTypeItem =
    //         widget.activitiesProcesses[selectedProcessesItem]!.first;
    // }
    validateButton = Opacity(
      opacity: 0.5,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: primaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        onPressed: () {},
        child: const Text(
          "Modifier",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Scaffold(
          appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.white, // Set icon color to white
              ),
              backgroundColor: primaryColor,
              title: ListTile(
                title: Text(
                  'Activité pour : ',
                  style: Theme.of(context)
                      .textTheme
                      .headline3!
                      .copyWith(color: Colors.white),
                ),
                subtitle: Text(
                  '${widget.client.name}',
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: Colors.white),
                ),
              )),
          body: ListView(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                child: Center(
                  child: Text(
                    'L\'état : ${widget.activity.state}',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
              Container(
                height: 50.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: states.length, // Number of items
                  itemBuilder: (context, index) {
                    Icon icon = Icon(
                      Icons.access_time_outlined,
                      color: Colors.yellow,
                    );
                    switch (index) {
                      // case 0:
                      //   icon = Icon(
                      //     Icons.access_time_outlined,
                      //     color: Colors.yellow,
                      //   );
                      //   return GestureDetector(
                      //       onLongPress: () {
                      //         showMenu(
                      //           context: context,
                      //           position: RelativeRect.fromLTRB(
                      //               100.0, 100.0, 100.0, 100.0),
                      //           items: [
                      //             PopupMenuItem(
                      //               value: 1,
                      //               child: Text('${states[index]}'),
                      //             ),
                      //           ],
                      //         ).then((value) => {});
                      //       },
                      //       onTap: () {},
                      //       child: Container(
                      //         width: MediaQuery.of(context).size.width / 4,
                      //         child: icon,
                      //         decoration:
                      //             (widget.activity.state == states[index])
                      //                 ? decoration
                      //                 : BoxDecoration(
                      //                     border: Border(
                      //                         bottom: BorderSide(
                      //                     width: 2.5,
                      //                     color: Colors.transparent,
                      //                   ))),
                      //       ));
                      case 1:
                        icon = Icon(
                          Icons.timer_outlined,
                          color: Colors.blue,
                        );
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                                onLongPress: () {
                                  showMenu(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                        100.0, 100.0, 100.0, 100.0),
                                    items: [
                                      PopupMenuItem(
                                        value: 1,
                                        child: Text('${states[index]}'),
                                      ),
                                    ],
                                  );
                                },
                                onTap: () async {
                                  if (widget.activity.state == states[1]) {
                                    showAlertDialog(context,
                                        'Cette activité a déjà commencée');
                                    return;
                                  }
                                  if (widget.activity.state == states[2]) {
                                    showAlertDialog(context,
                                        'Cette activité est déjà terminée');
                                    return;
                                  }
                                  ConfirmationDialog confirmationDialog =
                                      ConfirmationDialog();
                                  bool confirmed = await confirmationDialog
                                      .showConfirmationDialog(
                                          context, 'progressAct');
                                  if (confirmed) {
                                    showLoaderDialog(context);
                                    widget.activity.state = states[1];
                                    progressActivity(context, widget.activity)
                                        .then((value) {
                                      if (value) {
                                        showMessage(
                                            message:
                                                'Activité a été commencée avec succès',
                                            context: context,
                                            color: primaryColor);
                                        Navigator.pop(context);
                                        widget.callback();
                                        setState(() {});
                                      } else {
                                        Navigator.pop(context);
                                        showMessage(
                                            message: 'Échec ...',
                                            context: context,
                                            color: Colors.red);
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: icon,
                                  decoration:
                                      (widget.activity.state == states[index])
                                          ? decoration
                                          : BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                              width: 2.5,
                                              color: Colors.transparent,
                                            ))),
                                )),
                            Text('commencer')
                          ],
                        );
                      case 2:
                        icon = Icon(
                          Icons.check_box_outlined,
                          color: primaryColor,
                        );
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                                onLongPress: () {
                                  showMenu(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                        100.0, 100.0, 100.0, 100.0),
                                    items: [
                                      PopupMenuItem(
                                        value: 1,
                                        child: Text('${states[index]}'),
                                      ),
                                    ],
                                  );
                                },
                                onTap: () async {
                                  if (widget.activity.state == states[2]) {
                                    showAlertDialog(context,
                                        'Cette activité est déjà terminée');
                                    return;
                                  }
                                  if (widget.activity.state == states[4]) {
                                    showAlertDialog(context,
                                        'Cette activité a déjà annulée');
                                    return;
                                  }
                                  if (widget.activity.state != 'En cours') {
                                    showAlertDialog(context,
                                        'Il faut lancer l\'activité d\'abord !');
                                    return;
                                  }
                                  ConfirmationDialog confirmationDialog =
                                      ConfirmationDialog();
                                  bool confirmed = await confirmationDialog
                                      .showConfirmationDialog(
                                          context, 'endAct');
                                  if (confirmed) {
                                    showLoaderDialog(context);
                                    widget.activity.state = states[2];
                                    endActivity(context, widget.activity)
                                        .then((value) {
                                      if (value) {
                                        showMessage(
                                            message:
                                                'Activité a été terminée avec succès',
                                            context: context,
                                            color: primaryColor);
                                        Navigator.pop(context);
                                        widget.callback();
                                        setState(() {});
                                      } else {
                                        Navigator.pop(context);
                                        showMessage(
                                            message: 'Échec ...',
                                            context: context,
                                            color: Colors.red);
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: icon,
                                  decoration:
                                      (widget.activity.state == states[index])
                                          ? decoration
                                          : BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                              width: 2.5,
                                              color: Colors.transparent,
                                            ))),
                                )),
                            Text('Terminer'),
                          ],
                        );
                      // case 3:
                      //   icon = Icon(
                      //     Icons.warning_amber,
                      //     color: Colors.red,
                      //   );
                      //   return GestureDetector(
                      //       onLongPress: () {
                      //         showMenu(
                      //           context: context,
                      //           position: RelativeRect.fromLTRB(
                      //               100.0, 100.0, 100.0, 100.0),
                      //           items: [
                      //             PopupMenuItem(
                      //               value: 1,
                      //               child: Text('${states[index]}'),
                      //             ),
                      //           ],
                      //         );
                      //       },
                      //       onTap: () {},
                      //       child: Container(
                      //         width: MediaQuery.of(context).size.width / 4,
                      //         child: icon,
                      //         decoration:
                      //             (widget.activity.state == states[index])
                      //                 ? decoration
                      //                 : BoxDecoration(
                      //                     border: Border(
                      //                         bottom: BorderSide(
                      //                     width: 2.5,
                      //                     color: Colors.transparent,
                      //                   ))),
                      //       ));
                      case 4:
                        icon = Icon(
                          Icons.cancel_outlined,
                          color: Colors.grey,
                        );
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                                onLongPress: () {
                                  showMenu(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                        100.0, 100.0, 100.0, 100.0),
                                    items: [
                                      PopupMenuItem(
                                        value: 1,
                                        child: Text('${states[index]}'),
                                      ),
                                    ],
                                  );
                                },
                                onTap: () {
                                  if (widget.activity.state == states[4]) {
                                    showAlertDialog(context,
                                        'Cette activité a déjà annulée');
                                    return;
                                  }
                                  if (widget.activity.state == states[2]) {
                                    showAlertDialog(context,
                                        'Cette activité est déjà terminée');
                                    return;
                                  }
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CancelActivitiesDialog(
                                        activity: widget.activity,
                                      );
                                    },
                                  ).then((valueAct) {
                                    if (valueAct == null ||
                                        valueAct == 'null') {
                                    } else {
                                      Activity act = valueAct;
                                      print('gggggg:: ${act.motif}');
                                      showLoaderDialog(context);
                                      widget.activity.state = states[4];
                                      cancelActivity(context, widget.activity)
                                          .then((value) {
                                        if (value) {
                                          showMessage(
                                              message:
                                                  'Activité a été annulée avec succès',
                                              context: context,
                                              color: primaryColor);
                                          Navigator.pop(context);
                                          widget.callback();
                                          setState(() {});
                                        } else {
                                          Navigator.pop(context);
                                          showMessage(
                                              message: 'Échec ...',
                                              context: context,
                                              color: Colors.red);
                                        }
                                      });
                                    }
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: icon,
                                  decoration:
                                      (widget.activity.state == states[index])
                                          ? decoration
                                          : BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                              width: 2.5,
                                              color: Colors.transparent,
                                            ))),
                                )),
                            Text('Annuler'),
                          ],
                        );
                      case 5:
                        icon = Icon(
                          Icons.refresh,
                          color: Colors.orange,
                        );
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                                onLongPress: () {
                                  showMenu(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                        100.0, 100.0, 100.0, 100.0),
                                    items: [
                                      PopupMenuItem(
                                        value: 1,
                                        child: Text('${states[index]}'),
                                      ),
                                    ],
                                  );
                                },
                                onTap: () {
                                  if (widget.activity.state == states[2]) {
                                    showAlertDialog(context,
                                        'Cette activité est déjà terminée');
                                    return;
                                  }
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ReportedActivitiesDialog(
                                        activity: widget.activity,
                                      );
                                    },
                                  ).then((valueAct) {
                                    if (valueAct == null ||
                                        valueAct == 'null') {
                                    } else {
                                      Activity act = valueAct;
                                      showLoaderDialog(context);
                                      widget.activity.state = states[0];
                                      reportActivity(context, widget.activity)
                                          .then((value) {
                                        if (value) {
                                          showMessage(
                                              message:
                                                  'Activité reportée avec succès',
                                              context: context,
                                              color: primaryColor);
                                          Navigator.pop(context);
                                          widget.callback();
                                          selectedStartTimeDate =
                                              widget.activity.dateStart!;
                                          selectedEndTimeDate =
                                              widget.activity.dateEnd!;
                                          setState(() {});
                                        } else {
                                          Navigator.pop(context);
                                          showMessage(
                                              message: 'Échec ...',
                                              context: context,
                                              color: Colors.red);
                                        }
                                      });
                                    }
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: icon,
                                  decoration:
                                      (widget.activity.state == states[index])
                                          ? decoration
                                          : BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                              width: 2.5,
                                              color: Colors.transparent,
                                            ))),
                                )),
                            Text('Reporter')
                          ],
                        );
                      default:
                        return Container();
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.person_outline,
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
              ListTile(
                title: Text(
                  'Catégorie',
                  style: Theme.of(context).textTheme.headline6,
                ),
                subtitle: DropdownButtonFormField<Process>(
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(width: 2, color: primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(width: 2, color: primaryColor),
                      )),
                  hint: Text(
                    'Selectioner la catégorie ',
                    style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(color: Colors.grey),
                  ),
                  value: selectedProcessesItem,
                  onChanged: (newValue) {
                    setState(() {
                      selectedProcessesItem = newValue!;
                      actionTypes = widget.allTypes
                          .where((element) =>
                              selectedProcessesItem!.code == element.divers)
                          .toList();
                      selectedTypeItem = widget.allTypes
                          .where((element) =>
                              selectedProcessesItem!.code == element.divers)
                          .toList()
                          .first;
                      // selectedTypeItem = widget
                      //     .activitiesProcesses[selectedProcessesItem]!.first;
                    });
                    reload();
                  },
                  items: widget.allProcesses
                      .toList()
                      .map<DropdownMenuItem<Process>>((Process value) {
                    return DropdownMenuItem<Process>(
                      value: value,
                      child: Text(
                        value.name!,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    );
                  }).toList(),
                ),
              ),
              ListTile(
                title: Text(
                  'Type',
                  style: Theme.of(context).textTheme.headline6,
                ),
                subtitle: DropdownButtonFormField<TypeActivity>(
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(width: 2, color: primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(width: 2, color: primaryColor),
                      )),
                  hint: Text(
                    'Selectioner le type ',
                    style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(color: Colors.grey),
                  ),
                  value: selectedTypeItem,
                  onChanged: (newValue) {
                    setState(() {
                      selectedTypeItem = newValue!;
                    });
                    reload();
                  },
                  items: actionTypes.map<DropdownMenuItem<TypeActivity>>(
                      (TypeActivity value) {
                    return DropdownMenuItem<TypeActivity>(
                      value: value,
                      child: Text(
                        value.name!,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: customTextField(
                  obscure: false,
                  controller: _object,
                  hint: 'Objet',
                ),
              ),
              Visibility(
                visible: false,
                child: ListTile(
                  title: Text(
                    'Etat',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2, color: primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2, color: primaryColor),
                        )),
                    hint: Text(
                      'Selectioner l\'état ',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.grey),
                    ),
                    value: selectedStateItem,
                    onChanged: (newValue) {
                      setState(() {
                        selectedStateItem = newValue!;
                      });
                      reload();
                    },
                    items: states.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Priorité',
                    style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  RatingBar.builder(
                    initialRating: ratingPriority,
                    minRating: 1.0,
                    maxRating: 5.0,
                    itemCount: 5,
                    // Number of stars
                    itemBuilder: (context, index) => Icon(
                      index >= ratingPriority
                          ? Icons.star_border_outlined
                          : Icons.star,
                      color: Colors.yellow,
                    ),
                    onRatingUpdate: (rating) {
                      print('New rating: $rating');
                      setState(() {
                        ratingPriority = rating;
                        print('rrrr: $ratingPriority');
                      });
                      reload();
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Urgence',
                    style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  RatingBar.builder(
                    initialRating: ratingEmergency,
                    minRating: 1.0,
                    maxRating: 5.0,
                    itemCount: 5,
                    // Number of stars
                    itemBuilder: (context, index) => Icon(
                      index >= ratingEmergency
                          ? Icons.star_border_outlined
                          : Icons.star,
                      color: Colors.yellow,
                    ),
                    onRatingUpdate: (rating) {
                      print('New rating: $rating');
                      setState(() {
                        ratingEmergency = rating;
                      });
                      reload();
                    },
                  ),
                ],
              ),
              Visibility(
                visible: false,
                child: ListTile(
                  title: Text(
                    'Type de Tiers',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2, color: primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2, color: primaryColor),
                        )),
                    hint: Text(
                      'Selectioner le type de tiers ',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.grey),
                    ),
                    value: selectedTypeTierItem,
                    onChanged: (newValue) {
                      setState(() {
                        selectedTypeTierItem = newValue!;
                      });
                      reload();
                    },
                    items:
                        typesTier.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Visibility(
                visible: false,
                child: ListTile(
                  title: Text(
                    'Contacts du tiers',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2, color: primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2, color: primaryColor),
                        )),
                    hint: Text(
                      'Selectioner contacts du tiers ',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.grey),
                    ),
                    value: selectedContactTierItem,
                    onChanged: (newValue) {
                      setState(() {
                        selectedContactTierItem = newValue!;
                      });
                      reload();
                    },
                    items: contactTier
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: customTextFieldEmptyActivity(
                  obscure: false,
                  reload: reload,
                  controller: _comment,
                  hint: 'Commentaire',
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: customTextFieldEmptyActivity(
                  obscure: false,
                  reload: reload,
                  controller: _service,
                  hint: 'Service concerné (Structure)',
                ),
              ),
              // ListTile(
              //   title: Text(
              //     'Service concerné (Structure)',
              //     style: Theme.of(context).textTheme.headline6,
              //   ),
              //   subtitle: DropdownButtonFormField<String>(
              //     decoration: InputDecoration(
              //         fillColor: Colors.white,
              //         filled: true,
              //         focusedBorder: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(12),
              //           borderSide: BorderSide(width: 2, color: primaryColor),
              //         ),
              //         enabledBorder: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(12),
              //           borderSide: BorderSide(width: 2, color: primaryColor),
              //         )),
              //     hint: Text(
              //       'Selectioner service concerné',
              //       style: Theme.of(context)
              //           .textTheme
              //           .headline4!
              //           .copyWith(color: Colors.grey),
              //     ),
              //     value: selectedServiceItem,
              //     onChanged: (newValue) {
              //       setState(() {
              //         selectedServiceItem = newValue!;
              //       });
              //       reload();
              //     },
              //     items: services.map<DropdownMenuItem<String>>((String value) {
              //       return DropdownMenuItem<String>(
              //         value: value,
              //         child: Text(
              //           value,
              //           style: Theme.of(context).textTheme.headline4,
              //         ),
              //       );
              //     }).toList(),
              //   ),
              // ),
              SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () {
                  //showDateTimeDialog(context, 'start');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: primaryColor,
                    ),
                    Container(
                      width: 50,
                      child: Text(
                        'Début',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                    Text(
                      '${DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedStartTimeDate)}',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  //showDateTimeDialog(context, 'end');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: primaryColor,
                    ),
                    Container(
                      width: 50,
                      child: Text(
                        'Fin  ',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                    Text(
                      '${DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedEndTimeDate)}',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ],
                ),
              ),
              // SizedBox(
              //   height: 20,
              // ),
              // Visibility(
              //   visible: true,
              //   child: Container(
              //     width: 200,
              //     padding: EdgeInsets.symmetric(horizontal: 30),
              //     child: ElevatedButton(
              //       style: ElevatedButton.styleFrom(
              //           primary: Theme.of(context).primaryColor,
              //           elevation: 0,
              //           shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(5))),
              //       onPressed: () async {
              //         // Ensure that plugin services are initialized so that `availableCameras()`
              //         // can be called before `runApp()`
              //         WidgetsFlutterBinding.ensureInitialized();
              //
              //         // Obtain a list of the available cameras on the device.
              //         final cameras = await availableCameras();
              //
              //         // Get a specific camera from the list of available cameras.
              //         final firstCamera = cameras.first;
              //         PageNavigator(ctx: context).nextPage(
              //             page: TakePictureScreen(
              //           camera: firstCamera,
              //           callback: reload,
              //         ));
              //         //PageNavigator(ctx: context).nextPage(page: CameraScreen());
              //       },
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             'PRISE DE PHOTO',
              //             style: Theme.of(context)
              //                 .textTheme
              //                 .headline4!
              //                 .copyWith(color: Colors.white),
              //           ),
              //           Icon(
              //             Icons.camera_alt_outlined,
              //             color: Colors.white,
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              // Container(
              //   width: 100,
              //   height: 150,
              //   child: Column(
              //     children: [
              //       if (AppUrl.imageUrl == '')
              //         Container(
              //           width: 100,
              //           height: 150,
              //           child: Image.asset(
              //             'assets/noimage.jpg',
              //             fit: BoxFit
              //                 .cover, // Adjust the image fit property as needed
              //           ),
              //         )
              //       else
              //         //Image.network('${AppUrl.baseUrl}${widget.note.image}', fit: BoxFit.cover, width: 200, height: 150,)
              //         Image.file(
              //           File(AppUrl.imageUrl),
              //           fit: BoxFit.cover,
              //           width: 200,
              //           height: 150,
              //         )
              //     ],
              //   ),
              // ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.orange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onPressed: () {
                    PageNavigator(ctx: context).nextPage(
                        page: NoteListPage(
                      client: widget.client,
                      activity: widget.activity,
                    ));
                  },
                  child: const Text(
                    "Les notes",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: validateButton,
              ),
              SizedBox(
                height: 20,
              )
            ],
          )),
    );
  }

  Future<bool> sendActivity(BuildContext context, Activity activity) async {
    //int etat = states.indexOf(activity.state!);
    Map<String, dynamic> jsonObject;
    activity.res['users'].forEach((element) {
      element['ID'] = element['userName'];
    });
    //activity.res['etat'] = states.indexOf(activity.state!);
    activity.res['date'] = activity.dateStart.toString();
    activity.res['objet'] = activity.object;
    activity.res['type'] = activity.type!.code;
    activity.res['date'] = activity.dateStart.toString();
    activity.res['level'] = activity.priority!.toInt();
    activity.res['urgence'] = activity.emergency!.toInt();
    activity.res['datrap'] = activity.dateStart.toString();
    activity.res['datfin'] = activity.dateEnd.toString();
    print('obj: ${activity.res}');
    String url = AppUrl.editAcivitiesOpp + activity.id!;
    http.Response req = await http
        .put(Uri.parse(url), body: jsonEncode(activity.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res actEdit code : ${req.statusCode}");
    print("res actEdit body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> progressActivity(BuildContext context, Activity activity) async {
    //int etat = states.indexOf(activity.state!);
    activity.res['users'].forEach((element) {
      element['ID'] = element['userName'];
    });
    activity.res['etat'] = states.indexOf(activity.state!);
    activity.res['dateReelDebut'] = DateTime.now().toString();
    // activity.res['date'] = activity.dateStart.toString();
    // activity.res['objet'] = activity.object;
    // activity.res['type'] = activity.type!.code;
    // activity.res['date'] = activity.dateStart.toString();
    // activity.res['level'] = activity.priority!.toInt();
    // activity.res['urgence'] = activity.emergency!.toInt();
    // activity.res['datrap'] = activity.dateStart.toString();
    // activity.res['datfin'] = activity.dateEnd.toString();

    print('obj: ${activity.res}');
    String url = AppUrl.editAcivitiesOpp + activity.id!;
    http.Response req = await http
        .put(Uri.parse(url), body: jsonEncode(activity.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res actEdit code : ${req.statusCode}");
    print("res actEdit body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> endActivity(BuildContext context, Activity activity) async {
    //int etat = states.indexOf(activity.state!);
    activity.res['users'].forEach((element) {
      element['ID'] = element['userName'];
    });
    activity.res['etat'] = states.indexOf(activity.state!);
    activity.res['dateReelFin'] = DateTime.now().toString();

    print('obj: ${activity.res}');
    String url = AppUrl.editAcivitiesOpp + activity.id!;
    http.Response req = await http
        .put(Uri.parse(url), body: jsonEncode(activity.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res actEdit code : ${req.statusCode}");
    print("res actEdit body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> cancelActivity(BuildContext context, Activity activity) async {
    //int etat = states.indexOf(activity.state!);
    activity.res['users'].forEach((element) {
      element['ID'] = element['userName'];
    });
    activity.res['etat'] = states.indexOf(activity.state!);
    activity.res['motifAnnul'] = activity.motif;

    print('obj: ${activity.res}');
    String url = AppUrl.editAcivitiesOpp + activity.id!;
    http.Response req = await http
        .put(Uri.parse(url), body: jsonEncode(activity.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res actEdit code : ${req.statusCode}");
    print("res actEdit body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> reportActivity(BuildContext context, Activity activity) async {
    //int etat = states.indexOf(activity.state!);
    activity.res['users'].forEach((element) {
      element['ID'] = element['userName'];
    });
    activity.res['etat'] = states.indexOf(activity.state!);
    activity.res['date'] = activity.dateStart.toString();
    activity.res['datfin'] = activity.dateEnd.toString();

    print('obj: ${activity.res}');
    String url = AppUrl.editAcivitiesOpp + activity.id!;
    http.Response req = await http
        .put(Uri.parse(url), body: jsonEncode(activity.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res actEdit code : ${req.statusCode}");
    print("res actEdit body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  void reload() {
    widget.activity = Activity(
      id: widget.activity.id,
      user: AppUrl.user,
      processes: selectedProcessesItem,
      type: selectedTypeItem,
      object: _object.text.trim(),
      //state: selectedStateItem,
      priority: ratingPriority,
      emergency: ratingEmergency,
      typeTier: selectedTypeTierItem,
      contact: null,
      comment: _comment.text.trim(),
      service: selectedServiceItem,
      start: DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedStartTimeDate),
      end: DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedEndTimeDate),
      dateStart: selectedStartTimeDate,
      dateEnd: selectedEndTimeDate,
      client: widget.client,
      res: widget.activity.res,
    );
    setState(() {
      if (oldActivity == widget.activity) {
        validateButton = Opacity(
          opacity: 0.5,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            onPressed: () {},
            child: const Text(
              "Modifier",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        );
      } else {
        validateButton = Opacity(
          opacity: 1,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            onPressed: () async {
              if (widget.activity.state == states[2]) {
                showAlertDialog(context, 'Cette activité est déjà terminée');
                return;
              }
              if (formKey.currentState != null &&
                  formKey.currentState!.validate()) {
                Activity activity = Activity(
                  id: widget.activity.id,
                  user: AppUrl.user,
                  processes: selectedProcessesItem,
                  type: selectedTypeItem,
                  object: _object.text.trim(),
                  state: widget.activity.state,
                  priority: ratingPriority,
                  emergency: ratingEmergency,
                  typeTier: selectedTypeTierItem,
                  contact: null,
                  comment: _comment.text.trim(),
                  service: selectedServiceItem,
                  start: DateFormat('yyyy-MM-dd HH:mm:ss')
                      .format(selectedStartTimeDate),
                  end: DateFormat('yyyy-MM-dd HH:mm:ss')
                      .format(selectedEndTimeDate),
                  dateStart: selectedStartTimeDate,
                  dateEnd: selectedEndTimeDate,
                  client: widget.client,
                );
                activity.res = widget.activity.res;
                print('rating;; $ratingPriority');
                print('rating;; $ratingEmergency');
                // final provider = Provider.of<ActivityProvider>(context,
                //     listen: false);
                // provider.activityList.add(activity);
                ConfirmationDialog confirmationDialog = ConfirmationDialog();
                bool confirmed = await confirmationDialog
                    .showConfirmationDialog(context, 'confirmEditAct');
                if (confirmed) {
                  // confirm
                  showLoaderDialog(context);
                  sendActivity(context, activity).then((value) {
                    if (value) {
                      showMessage(
                          message: 'Activité a été modifiée avec succès',
                          context: context,
                          color: primaryColor);
                      widget.callback();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                      showMessage(
                          message: 'Échec de modification de l\'activité',
                          context: context,
                          color: Colors.red);
                    }
                  });
                }
              }
            },
            child: const Text(
              "Modifier",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        );
      }
    });
  }
}

showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Container(
        width: 200,
        height: 100,
        child: Image.asset('assets/CRM-Loader.gif')),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
