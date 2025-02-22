import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/activity.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/pipeline.dart';
import 'package:mobilino_app/models/process.dart';
import 'package:mobilino_app/models/step_pip.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/models/type_activity.dart';
import 'package:mobilino_app/providers/activity_provider.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:mobilino_app/widgets/text_field.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class AddOpportunityPage extends StatefulWidget {
  final Client client;
  const AddOpportunityPage({
    super.key,
    required this.client
  });

  @override
  State<AddOpportunityPage> createState() => _AddOpportunityPageState();
}

class _AddOpportunityPageState extends State<AddOpportunityPage> {
  late DateTime selectedStartTimeDate = widget.client.dateStart!;
  late DateTime selectedEndTimeDate = DateTime.now();
  String selectedStateItem = '';
  double ratingPriority = 3.0;
  double ratingEmergency = 3.0;
  final formKey = GlobalKey<FormState>();
  final TextEditingController _lib = TextEditingController();
  final TextEditingController _client = TextEditingController();
  late Collaborator selectedCollaborator = AppUrl.user.allCollaborator.first;
  late Team selectedTeam = AppUrl.filtredOpporunity.team!;
  late Pipeline selectedPipeline = AppUrl.filtredOpporunity.pipeline!;
  late StepPip selectedStepPip = AppUrl.filtredOpporunity.stepPip!;

  List<String> states = [
    'A visité',
    'Visité',
    'Livré',
    'Encaissé',
    'Livré & encaissé',
    'Annulée'
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
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedStateItem = states.first;
    _client.text = widget.client.name!;
    _lib.text = widget.client.lib!;
  }
  void reload() {
    setState(() {
    });
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
            title: Text(
              'Nouvelle opportunité',
              style: Theme.of(context)
                  .textTheme
                  .headline3!
                  .copyWith(color: Colors.white),
            ),
          ),
          body: Center(
            child: ListView(
              children: [
                SizedBox(height: 20,),
                ListTile(
                  title: Text(
                    'Filtre des équipes',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle: DropdownButtonFormField<Team>(
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
                      'Selectioner l\'équipe',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.grey),
                    ),
                    value: selectedTeam,
                    onChanged: (newValue) async {
                      print('ffffff');
                      selectedTeam = newValue!;

                      if (newValue.id != -1) {
                        // get Collaborateurs
                        final Map<String, String> headers = {
                          "Accept": "application/json",
                          "content-type": "application/json; charset=UTF-8",
                          "Referer": "http://" +
                              AppUrl.user.company! +
                              ".localhost:4200/",
                          'Authorization': 'Bearer ${AppUrl.user.token}',
                        };
                        if (newValue.id == AppUrl.user.equipeId) {
                          AppUrl.user.collaborator = [Collaborator(
                            id: '-1',
                            userName: '${AppUrl.user.userId}',
                          )];
                          selectedCollaborator =
                              AppUrl.user.collaborator.first;
                          AppUrl.filtredOpporunity.collaborateur =
                              AppUrl.user.collaborator.first;

                        } else {
                          String url =
                              AppUrl.getCollaborateur + newValue.id.toString();
                          print('url of getCollaborateurs $url');
                          http.Response req =
                          await http.get(Uri.parse(url), headers: headers);
                          print("res Collaborateur code : ${req.statusCode}");
                          print("res Collaborateur body: ${req.body}");
                          if (req.statusCode == 200 || req.statusCode == 201) {
                            List<dynamic> data = json.decode(req.body);
                            //AppUrl.user.collaborator = [];
                            print('size from api: ${data.length}');
                            List<Collaborator> collaborators = [];
                            data.forEach((element) {
                              try {
                                collaborators.add(Collaborator(
                                  id: element['id'],
                                  userName: element['userName'],
                                ));
                              } catch (e) {
                                print('error: $e');
                              }
                            });
                            selectedCollaborator = collaborators.first;
                            collaborators.insert(
                                0,
                                Collaborator(
                                  id: '-1',
                                  userName: '${AppUrl.user.userId}',
                                ));
                            AppUrl.user.collaborator =
                                List<Collaborator>.from(collaborators)
                                    .where((element) =>
                                element.userName != AppUrl.user.userId)
                                    .toList();
                            AppUrl.filtredOpporunity.collaborateur =
                                AppUrl.user.collaborator.first;
                            print(
                                'collaborators size: ${AppUrl.user.collaborator.length}');
                          }
                        }
                      } else {
                        selectedCollaborator =
                            AppUrl.user.allCollaborator.first;
                        AppUrl.filtredOpporunity.collaborateur =
                            AppUrl.user.collaborator.first;
                        AppUrl.user.collaborator =
                            List<Collaborator>.from(AppUrl.user.allCollaborator)
                                .where((element) =>
                            element.userName != AppUrl.user.userId)
                                .toList();
                      }
                      setState(() {});
                    },
                    items: AppUrl.user.teams
                        .map<DropdownMenuItem<Team>>((Team value) {
                      return DropdownMenuItem<Team>(
                        value: value,
                        child: Text(
                          value.lib!,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Affecté à ',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle: DropdownButtonFormField<Collaborator>(
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
                      'Selectioner le collaborateur',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.grey),
                    ),
                    value: selectedCollaborator,
                    onChanged: (newValue) {
                      setState(() {
                        selectedCollaborator = newValue!;
                        String collabrator = selectedCollaborator.userName!;
                        if(collabrator == '${AppUrl.user.userId}')
                          collabrator = AppUrl.user.userId!;
                        print('collaborator $collabrator');
                      });
                    },
                    items: AppUrl.user.collaborator
                        .map<DropdownMenuItem<Collaborator>>(
                            (Collaborator value) {
                          return DropdownMenuItem<Collaborator>(
                            value: value,
                            child: Text(
                              value.userName!,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          );
                        }).toList(),
                  ),
                ),
                Visibility(
                  visible: false,
                  child: ListTile(
                    title: Text(
                      'Pipeline ',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: DropdownButtonFormField<Pipeline>(
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
                        'Selectioner pipeline',
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(color: Colors.grey),
                      ),
                      value: selectedPipeline,
                      onChanged: (newValue) {
                        selectedPipeline = newValue!;
                        String collabrator = selectedPipeline.name!;
                        AppUrl.filtredOpporunity.pipeline = selectedPipeline;
                        AppUrl.filtredOpporunity.stepPip = selectedPipeline.steps.first;
                        selectedStepPip = AppUrl.filtredOpporunity.stepPip!;
                        print('size of steps: ${AppUrl.filtredOpporunity.pipeline!.steps.length}');
                        print('size of steps: ${selectedPipeline.steps.length}');
                        if(collabrator == '${AppUrl.user.userId}')
                          collabrator = AppUrl.user.userId!;
                        print('collaborator $collabrator');
                        setState(() {
                        });
                      },
                      items: AppUrl.filtredOpporunity.team!.pipelines!
                          .map<DropdownMenuItem<Pipeline>>(
                              (Pipeline value) {
                            return DropdownMenuItem<Pipeline>(
                              value: value,
                              child: Text(
                                value.name!,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: customTextField(
                    obscure: false,
                    controller: _lib,
                    hint: 'Libelle',
                  ),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(onPressed: (){

                      }, icon: Icon(Icons.person_outline, color: primaryColor,),),
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
                Visibility(
                  visible: false,
                  child: ListTile(
                    title: Text(
                      'Etat',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: DropdownButtonFormField<StepPip>(
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
                      value: selectedStepPip,
                      onChanged: (newValue) {
                        setState(() {
                          selectedStepPip = newValue!;
                        });
                      },
                      items:AppUrl.filtredOpporunity.pipeline!.steps.map<DropdownMenuItem<StepPip>>((StepPip value) {
                        return DropdownMenuItem<StepPip>(
                          value: value,
                          child: Text(
                            value.name,
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
                      initialRating: 3.0,
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
                      initialRating: 3.0,
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
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () {
                    showDateTimeDialog(context, 'start');
                  },
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            'Date de début', textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          width: 200,
                        ),
                      ),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            color: primaryColor,
                          ),
                          Text(
                            '${DateFormat('dd-MM-yyyy HH:mm:ss').format(selectedStartTimeDate)}',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Visibility(
                  visible: false,
                  child: InkWell(
                    onTap: () {
                      showDateTimeDialog(context, 'end');
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
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    onPressed: () async {
                      if (formKey.currentState != null &&
                          formKey.currentState!.validate()) {
                        try{
                          print('client: ${widget.client}');

                        }catch (_){
                            _showAlertDialog(context, 'Il faut choisir un client d\'abord !');
                            return;
                        }
                        print('rating;; $ratingPriority');
                          print('rating;; $ratingEmergency');
                          // final provider = Provider.of<ActivityProvider>(context,
                          //     listen: false);
                          // provider.activityList.add(activity);
                        print('id and name client:  ${widget.client.id!} ${widget.client.name!}');
                          ConfirmationDialog confirmationDialog =
                              ConfirmationDialog();
                          bool confirmed = await confirmationDialog
                              .showConfirmationDialog(context, 'confirmOpp');
                          if (confirmed) {
                            // confirm
                            showLoaderDialog(context);
                            widget.client.lib = _lib.text.trim();
                            widget.client.dateStart = selectedStartTimeDate;
                            widget.client.priority = ratingPriority.toInt();
                            widget.client.emergency = ratingEmergency.toInt();
                            sendOpportunity(context, widget.client).then((value) {
                              if (value != null) {
                                Navigator.pop(context, value);
                                Navigator.pop(context, value);
                              } else {
                                showMessage(
                                    message: 'Échec de creation de l\'opportunité',
                                    context: context,
                                    color: Colors.red);
                                Navigator.pop(context, null);
                                Navigator.pop(context, null);
                              }
                            });
                          }
                      }
                    },
                    child: const Text(
                      "AJOUTER",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          )),
    );
  }

  Future<String?> sendOpportunity(BuildContext context, Client client) async {
    print('date is: ${client.dateStart}');
    print('userId: ${AppUrl.user.userId}');
    print('userId: ${AppUrl.user.userId}');
    String collabrator = selectedCollaborator.userName!;
    if(collabrator == '${AppUrl.user.userId}')
      collabrator = AppUrl.user.userId!;
    print('collaborator $collabrator');
    double total = 0;
    if(widget.client.command != null)
      total = widget.client.command!.total;
    int etat = states.indexOf(selectedStateItem) + 1;
    Map<String, dynamic> jsonObject = {
      "libelle": client.lib,
      "proprio": collabrator,
      "montant": total,
      "dateCreation": DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
      "dateDebut": DateFormat('yyyy-MM-ddTHH:mm:ss').format(client!.dateStart!),
      "priorite": client.priority,
      "urgence": client.emergency,
      "userCreat": "${AppUrl.user.userId}",
      //"etapeId": selectedStepPip.id,
      "etapeId": '1',
      "tiersId": client.id,
      "etbCode": AppUrl.user.etblssmnt!.code!,
      "notes": [],
    };

    print('objet json: ${jsonObject}');
    print('userCreat: ${jsonObject['proprio']}');
    print('url: ${AppUrl.opportunities}');
    print('url: http://"+AppUrl.user.company!+".my-crm.net:5188/api/Opportunites');

    http.Response req = await http.post(Uri.parse(AppUrl.opportunities),
        body: jsonEncode(jsonObject),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
        });
    print("res addOpp code : ${req.statusCode}");
    print("res addOpp body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      var res = json.decode(req.body);
      print('code:  ${res['code']}');
      return res['code'].toString();
    } else {
      return null;
    }
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
void _showAlertDialog(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.yellow,
              size: 50.0,
            ),
          ],
        ),
        content: Text(
          '$text',
          style: Theme.of(context).textTheme.headline6!,
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(primaryColor)),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Ok',
                style: Theme.of(context)
                    .textTheme
                    .headline3!
                    .copyWith(color: Colors.white)),
          ),
        ],
      );
    },
  );
}