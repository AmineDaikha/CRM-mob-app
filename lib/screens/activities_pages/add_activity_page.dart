import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/http_request.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/activity.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/contact.dart';
import 'package:mobilino_app/models/note.dart';
import 'package:mobilino_app/models/process.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/models/type_activity.dart';
import 'package:mobilino_app/providers/activity_provider.dart';
import 'package:mobilino_app/providers/note_provider.dart';
import 'package:mobilino_app/screens/home_page/clients_list_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/collaborator_page.dart';
import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:mobilino_app/widgets/contacts_page.dart';
import 'package:mobilino_app/widgets/text_field.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import 'camera_page.dart';
import 'notes_page/note_liste_page.dart';

class AddActivityPage extends StatefulWidget {
  final VoidCallback callback;
  final Client client;
  final List<Process> allProcesses;
  final List<TypeActivity> allTypes;
  final DateTime? proposedStart;


  //Map<Process, List<TypeActivity>> activitiesProcesses = {};

  AddActivityPage({
    super.key,
    required this.callback,
    required this.client,
    required this.allTypes,
    required this.allProcesses,
    this.proposedStart
    //required this.activitiesProcesses
  });

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  List<TypeActivity> actionTypes = [];
  late DateTime selectedStartTimeDate = DateTime.now();
  late DateTime selectedEndTimeDate = DateTime.now();
  late Process? selectedProcessesItem;
  TypeActivity? selectedTypeItem = TypeActivity();
  String selectedStateItem = '';
  late Collaborator selectedCollaborator =
      AppUrl.filtredOpporunity.collaborateur!;
  late Team selectedTeam = AppUrl.filtredOpporunity.team!;

  String selectedTypeTierItem = '';
  Contact? selectedContactTierItem;
  String selectedServiceItem = '';
  double ratingPriority = 3.0;
  double ratingEmergency = 3.0;
  final formKey = GlobalKey<FormState>();
  final TextEditingController _comment = TextEditingController();
  final TextEditingController _service = TextEditingController();
  final TextEditingController _object = TextEditingController();
  final TextEditingController _client = TextEditingController();
  final TextEditingController _collaborators = TextEditingController();
  final TextEditingController _contacts = TextEditingController();

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
    // 'En cours',
    // 'Terminée',
    // 'Non réalisée',
    // 'Annulée'
  ];
  List<String> typesTier = [
    'Prospect',
    'Client',
    'Fournisseur',
  ];

  List<Contact> contactTier = [];

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
        }
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
          }
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
    _client.text = 'Ajouter un Tiers';
    try{
      _client.text =widget.client.name!;
    }catch(_){

    }
    _collaborators.text = 'Ajouter des Collaborators';
    _contacts.text = 'Ajouter des Contacts';
    selectedStateItem = states.first;
    selectedTypeTierItem = typesTier.first;
    //selectedContactTierItem = contactTier.first;
    selectedServiceItem = services.first;
    if(widget.allProcesses.isNotEmpty)
    selectedProcessesItem = widget.allProcesses.first;
    else{
      selectedProcessesItem = Process(name: '', id: '', code: '');
    }
    print('efefefe ${selectedProcessesItem!.code}');
    actionTypes = widget.allTypes
        .where((element) => selectedProcessesItem!.code == element.divers)
        .toList();
    print('jbfkjfkf ${widget.allTypes.length}');
    print('jbfkjfkf ${actionTypes.length}');
    if(actionTypes.isNotEmpty)
    selectedTypeItem = actionTypes.first;
    if(widget.proposedStart != null){
      selectedStartTimeDate = widget.proposedStart!;
      selectedEndTimeDate = widget.proposedStart!.add(Duration(hours: 1));
    }

    // if (widget.activitiesProcesses.keys.isNotEmpty) {
    //   selectedProcessesItem = widget.activitiesProcesses.keys.toList().first;
    //   print(
    //       'fff: ${widget.activitiesProcesses[selectedProcessesItem]!.length}');
    //   if (widget.activitiesProcesses[selectedProcessesItem]!.isNotEmpty)
    //     selectedTypeItem =
    //         widget.activitiesProcesses[selectedProcessesItem]!.first;
    // }
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
              'Nouvelle activité',
              style: Theme.of(context)
                  .textTheme
                  .headline3!
                  .copyWith(color: Colors.white),
            ),
          ),
          body: ListView(
            children: [
              // ListTile(
              //   title: Text(
              //     'Filtre des équipes',
              //     style: Theme.of(context).textTheme.headline6,
              //   ),
              //   subtitle: DropdownButtonFormField<Team>(
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
              //       'Selectioner l\'équipe',
              //       style: Theme.of(context)
              //           .textTheme
              //           .headline4!
              //           .copyWith(color: Colors.grey),
              //     ),
              //     value: selectedTeam,
              //     onChanged: (newValue) async {
              //       print('ffffff');
              //       selectedTeam = newValue!;
              //       if (newValue.id != -1) {
              //         // get Collaborateurs
              //         final Map<String, String> headers = {
              //           "Accept": "application/json",
              //           "content-type": "application/json; charset=UTF-8",
              //           "Referer": "http://" +
              //               AppUrl.user.company! +
              //               ".localhost:4200/",
              //           'Authorization': 'Bearer ${AppUrl.user.token}',
              //         };
              //         String url =
              //             AppUrl.getCollaborateur + newValue.id.toString();
              //         print('url of getCollaborateurs $url');
              //         http.Response req =
              //             await http.get(Uri.parse(url), headers: headers);
              //         print("res Collaborateur code : ${req.statusCode}");
              //         print("res Collaborateur body: ${req.body}");
              //         if (req.statusCode == 200 || req.statusCode == 201) {
              //           List<dynamic> data = json.decode(req.body);
              //           //AppUrl.user.collaborator = [];
              //           print('size from api: ${data.length}');
              //           List<Collaborator> collaborators = [];
              //           data.forEach((element) {
              //             try {
              //               collaborators.add(Collaborator(
              //                 id: element['id'],
              //                 userName: element['userName'],
              //                 salCode: element['salCode'],
              //               ));
              //             } catch (e) {
              //               print('error: $e');
              //             }
              //           });
              //           selectedCollaborator = collaborators.first;
              //           collaborators.insert(
              //               0,
              //               Collaborator(
              //                 id: '-1',
              //                 userName: '${AppUrl.user.userId}',
              //               ));
              //           AppUrl.user.collaborator =
              //               List<Collaborator>.from(collaborators)
              //                   .where((element) =>
              //                       element.userName != AppUrl.user.userId)
              //                   .toList();
              //           AppUrl.filtredOpporunity.collaborateur =
              //               AppUrl.user.collaborator.first;
              //           print(
              //               'collaborators size: ${AppUrl.user.collaborator.length}');
              //         }
              //       } else {
              //         selectedCollaborator = AppUrl.user.allCollaborator.first;
              //         AppUrl.filtredOpporunity.collaborateur =
              //             AppUrl.user.collaborator.first;
              //         AppUrl.user.collaborator =
              //             List<Collaborator>.from(AppUrl.user.allCollaborator)
              //                 .where((element) =>
              //                     element.userName != AppUrl.user.userId)
              //                 .toList();
              //       }
              //       setState(() {});
              //     },
              //     items: AppUrl.user.teams
              //         .map<DropdownMenuItem<Team>>((Team value) {
              //       return DropdownMenuItem<Team>(
              //         value: value,
              //         child: Text(
              //           value.lib!,
              //           style: Theme.of(context).textTheme.headline4,
              //         ),
              //       );
              //     }).toList(),
              //   ),
              // ),
              // ListTile(
              //   title: Text(
              //     'Filtre des collaborateurs',
              //     style: Theme.of(context).textTheme.headline6,
              //   ),
              //   subtitle: DropdownButtonFormField<Collaborator>(
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
              //       'Selectioner l\'équipe',
              //       style: Theme.of(context)
              //           .textTheme
              //           .headline4!
              //           .copyWith(color: Colors.grey),
              //     ),
              //     value: selectedCollaborator,
              //     onChanged: (newValue) {
              //       setState(() {
              //         selectedCollaborator = newValue!;
              //       });
              //     },
              //     items: AppUrl.user.collaborator
              //         .map<DropdownMenuItem<Collaborator>>(
              //             (Collaborator value) {
              //       return DropdownMenuItem<Collaborator>(
              //         value: value,
              //         child: Text(
              //           value.userName!,
              //           style: Theme.of(context).textTheme.headline4,
              //         ),
              //       );
              //     }).toList(),
              //   ),
              // ),
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
                          http.Response req =
                              await http.get(Uri.parse(url), headers: headers);
                          print("res contacts code : ${req.statusCode}");
                          print("res contacts body: ${req.body}");
                          if (req.statusCode == 200 || req.statusCode == 201) {
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
                            selectedContactTierItem =
                                widget.client.contacts.first;
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
                            for (Contact contact in AppUrl.user.selectedContact)
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
              // Visibility(
              //   visible: true,
              //   child: ListTile(
              //     title: Text(
              //       'Contacts du tiers',
              //       style: Theme.of(context).textTheme.headline6,
              //     ),
              //     subtitle: DropdownButtonFormField<Contact>(
              //       decoration: InputDecoration(
              //           fillColor: Colors.white,
              //           filled: true,
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(12),
              //             borderSide: BorderSide(width: 2, color: primaryColor),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(12),
              //             borderSide: BorderSide(width: 2, color: primaryColor),
              //           )),
              //       hint: Text(
              //         'Selectioner contacts du tiers ',
              //         style: Theme.of(context)
              //             .textTheme
              //             .headline4!
              //             .copyWith(color: Colors.grey),
              //       ),
              //       value: selectedContactTierItem,
              //       onChanged: (newValue) {
              //         setState(() {
              //           selectedContactTierItem = newValue!;
              //         });
              //       },
              //       items: contactTier
              //           .map<DropdownMenuItem<Contact>>((Contact value) {
              //         return DropdownMenuItem<Contact>(
              //           value: value,
              //           child: (value != null)
              //               ? Text(
              //                   value.firstName! + ' ' + value.famillyName!,
              //                   style: Theme.of(context).textTheme.headline4,
              //                 )
              //               : Container(),
              //         );
              //       }).toList(),
              //     ),
              //   ),
              // ),
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
                    });
                  },
                  items: widget.allProcesses
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
              ListTile(
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: customTextFieldEmpty(
                  obscure: false,
                  controller: _comment,
                  hint: 'Commentaire',
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: customTextFieldEmpty(
                  obscure: false,
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
                  showDateTimeDialog(context, 'start');
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
              SizedBox(
                height: 20,
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
                    if (widget.client.name == null) {
                      showAlertDialog(
                          context, 'Le choix du tiers est obligatoire');
                      return;
                    }
                    PageNavigator(ctx: context).nextPage(
                        page: NoteListPage(
                      client: widget.client,
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onPressed: () async {
                    if (AppUrl.user.selectedCollaborator.length == 0) {
                      showAlertDialog(context,
                          'Il faut choisir les collaborateurs d\'abord');
                      return;
                    }
                    if (widget.client.name == null) {
                      showAlertDialog(
                          context, 'Le choix du tiers est obligatoire');
                      return;
                    }
                    if (DateTime.now()
                            .difference(selectedStartTimeDate)
                            .inMinutes >
                        0) {
                      showAlertDialog(context,
                          'Date début doit être supérieur à date actuelle !');
                      return;
                    }
                    if (selectedStartTimeDate
                            .difference(selectedEndTimeDate)
                            .inSeconds >=
                        0) {
                      showAlertDialog(context,
                          'Date début doit être supérieur à date fin !');
                      return;
                    }
                    if (formKey.currentState != null &&
                        formKey.currentState!.validate()) {
                      Activity activity = Activity(
                        user: AppUrl.user,
                        processes: selectedProcessesItem,
                        type: selectedTypeItem,
                        object: _object.text.trim(),
                        state: selectedStateItem,
                        priority: ratingPriority,
                        emergency: ratingEmergency,
                        typeTier: selectedTypeTierItem,
                        contact: selectedContactTierItem,
                        comment: _comment.text.trim(),
                        service: _service.text.trim(),
                        start: DateFormat('yyyy-MM-dd HH:mm:ss')
                            .format(selectedStartTimeDate),
                        end: DateFormat('yyyy-MM-dd HH:mm:ss')
                            .format(selectedEndTimeDate),
                        dateStart: selectedStartTimeDate,
                        dateEnd: selectedEndTimeDate,
                        client: widget.client,
                      );
                      print('rating;; $ratingPriority');
                      print('rating;; $ratingEmergency');
                      // final provider = Provider.of<ActivityProvider>(context,
                      //     listen: false);
                      // provider.activityList.add(activity);
                      ConfirmationDialog confirmationDialog =
                          ConfirmationDialog();
                      bool confirmed = await confirmationDialog
                          .showConfirmationDialog(context, 'confirmAct');
                      if (confirmed) {
                        // confirm
                        showLoaderDialog(context);
                        sendActivity(context, activity).then((value) {
                          if (value) {
                            HttpRequestApp().sendItinerary('ACT');
                            Navigator.pop(context);
                            showMessage(
                                message: 'Activité a été créée avec succès',
                                context: context,
                                color: primaryColor);
                            widget.callback();
                            Navigator.pop(context);
                          } else {
                            showMessage(
                                message: 'Échec de creation de l\'activité',
                                context: context,
                                color: Colors.red);
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
          )),
    );
  }

  Future<bool> sendActivity(BuildContext context, Activity activity) async {
    List<Map<String, dynamic>> users = [];
    for (Collaborator collaborator in AppUrl.user.selectedCollaborator) {
      if (collaborator.userName == '${AppUrl.user.userId}')
        collaborator.userName = AppUrl.user.userId;
      Map<String, dynamic> jsonUser = {
        "salCode": "${collaborator.salCode}",
        "ID": "${collaborator.userName}",
        "UserName": "${collaborator.userName}",
      };
      users.add(jsonUser);
    }

    List<Map<String, dynamic>> contacts = [];
    for (Contact contact in AppUrl.user.selectedContact) {
      Map<String, dynamic> jsonContacts = {
        "numero": "${contact.num}",
        "code": "${contact.code}",
        "origin": "${contact.origin}",
        "nom": "${contact.famillyName}",
        "prenom": "${contact.firstName}",
      };
      contacts.add(jsonContacts);
    }
    int etat = states.indexOf(activity.state!);
    Map<String, dynamic> jsonObject = {
      "date": activity.dateStart.toString(),
      "datech": null,
      "pcfCode": activity.client.id,
      "cctNumero": null,
      "objet": activity.object,
      "type": activity.type!.code,
      "lib": activity.comment,
      "etat": etat,
      "level": activity.priority!.toInt(),
      "rappel": true,
      "urgence": activity.emergency!.toInt(),
      "termine": false,
      "datrap": activity.dateStart.toString(),
      "datfin": activity.dateEnd.toString(),
      "pourea": null,
      "synout": null,
      "heure": null,
      "salCode": AppUrl.user.salCode,
      "desc": null,
      "file": null,
      "dtcre": activity.dateStart.toString(),
      "usrcre": null,
      "dtmaj": null,
      "usrmaj": null,
      "nummaj": 1,
      "activee": null,
      "prevenir": 1,
      "jourAvn": null,
      "typeAlerte": null,
      "lieu": null,
      "repetition": null,
      "frequence": null,
      "user": null,
      "observation": null,
      "duree": null,
      "heureRappel": "000000",
      "site": null,
      "prestation": null,
      "intervention": null,
      "tva": null,
      "color": null,
      "icon": null,
      "delete": null,
      "dtdelete": null,
      "motifAnnul": null,
      "usrdelete": null,
      "oppoCode": activity.client.idOpp,
      "contacts": contacts,
      "users": users
    };
    print('jsonObj: ${jsonObject}');
    http.Response req = await http.post(Uri.parse(AppUrl.acivitiesOpp),
        body: jsonEncode(jsonObject),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
    print("res act code : ${req.statusCode}");
    print("res act body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      var res = json.decode(req.body);
      final provider = Provider.of<NoteProvider>(context, listen: false);
      if (provider.noteList.length == 0)
        return true;
      else {
        bool addAllNote = true;
        for (int i = 0; i < provider.noteList.length; i++) {
          bool rslt =
              await sendNote(context, provider.noteList[i], res['numero']);
          if (rslt == false) addAllNote = false;
        }
        if (addAllNote)
          return true;
        else
          return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> sendNote(
      BuildContext context, Note note, String actionNum) async {
    List<Map<String, dynamic>> users = [];
    for (Collaborator collaborator in AppUrl.user.selectedCollaborator) {
      if (collaborator.userName == '${AppUrl.user.userId}')
        collaborator.userName = AppUrl.user.userId;
      Map<String, dynamic> jsonUser = {
        "salCode": "${collaborator.salCode}",
        "visible": true,
        // "ID": "${collaborator.userName}",
        // "UserName": "${collaborator.userName}",
      };
      users.add(jsonUser);
    }
    Map<String, dynamic> jsonObject = {
      "nom": note.title,
      "type": "txt",
      "path": "string",
      "pcfCode": "${widget.client.id}",
      "description": note.text,
      "actionNum": actionNum,
      "dateCreation": DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
      "userCreate": AppUrl.user.userId,
      "usersNotes": users,
      //"opportuniteId": '${widget.client!.idOpp}',
    };

    print('jsonNote: ${jsonObject}');
    http.Response req = await http.post(Uri.parse(AppUrl.NotesOpp),
        body: jsonEncode(jsonObject),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
    print("res note code : ${req.statusCode}");
    print("res note body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      var res = json.decode(req.body);
      bool addNote = false;
      for (int i = 0; i < note.files.length; i++)
        await uploadFile(res['id'].toString(), note, note.files[i].path)
            .then((value) {
          if (value)
            addNote = true;
          else
            addNote = false;
        });
      return addNote;
    } else {
      return false;
    }
  }

  Future<bool> uploadFile(String id, Note note, String path) async {
    // Replace with your API endpoint
    final String apiUrl = '${AppUrl.uploadFileNote}$id';

    // Create a new http.MultipartRequest
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(apiUrl),
    );
    request.headers['Accept'] = 'application/json';
    request.headers['content-type'] = 'application/json; charset=UTF-8';
    request.headers['Referer'] =
        "http://" + AppUrl.user.company! + ".localhost:4200/";
    // Add your file to the request
    var file = File(path);
    await file.exists().then((value) async {
      print('the file is exists ? $value');
      if (value) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
        // Send the request
        try {
          var response = await request.send();
          if (response.statusCode == 200) {
            print('File uploaded successfully');
            return true;
          } else {
            print('Failed to upload file. Status code: ${response.statusCode}');
            return false;
          }
        } catch (error) {
          print('Error uploading file: $error');
        }
      }
    });
    return true;
  }

  void reload() {
    setState(() {});
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
