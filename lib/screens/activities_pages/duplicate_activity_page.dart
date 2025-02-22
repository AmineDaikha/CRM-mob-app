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
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/contact.dart';
import 'package:mobilino_app/models/process.dart';
import 'package:mobilino_app/models/type_activity.dart';
import 'package:mobilino_app/providers/activity_provider.dart';
import 'package:mobilino_app/screens/home_page/clients_list_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/collaborator_page.dart';
import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:mobilino_app/widgets/contacts_page.dart';
import 'package:mobilino_app/widgets/text_field.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'camera_page.dart';
import 'notes_page/note_liste_page.dart';

class DuplicateActivityPage extends StatefulWidget {
  final VoidCallback callback;
  final Client client;
  final Activity activity;
  final List<Process> allProcesses;
  final List<TypeActivity> allTypes;
  //final Map<Process, List<TypeActivity>> activitiesProcesses = {};

  DuplicateActivityPage(
      {super.key,
      required this.callback,
      required this.client,
      required this.activity,
        required this.allTypes,
        required this.allProcesses
      //required this.activitiesProcesses
      });

  @override
  State<DuplicateActivityPage> createState() => _DuplicateActivityPageState();
}

class _DuplicateActivityPageState extends State<DuplicateActivityPage> {
  late Activity oldActivity;
  late Opacity validateButton;
  late DateTime selectedStartTimeDate = DateTime.now();
  late DateTime selectedEndTimeDate = DateTime.now();
  late Process? selectedProcessesItem;
  late TypeActivity? selectedTypeItem = TypeActivity();
  String selectedStateItem = '';

  String selectedTypeTierItem = '';
  Contact? selectedContactTierItem;

  //String selectedContactTierItem = '';
  String selectedServiceItem = '';
  double ratingPriority = 0.0;
  double ratingEmergency = 0.0;
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
    'En cours',
    'Terminée',
    'Non réalisée',
    'Annulée'
  ];
  List<String> typesTier = [
    'Prospect',
    'Client',
    'Client Export',
    'Fournisseur Local',
    'Fournisseur Etranger'
  ];

  // List<String> contactTier = [
  //   'Prospect',
  //   'Client',
  //   'Client Export',
  //   'Fournisseur Local',
  //   'Fournisseur Etranger'
  // ];
  List<Contact> contactTier = [];
  List<TypeActivity> actionTypes = [];
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
    print(
        'oppoCodeIs : ${widget.activity.client.idOpp} ${widget.activity.emergency}');
    _client.text = widget.client.name!;
    if (widget.activity.comment != null)
      _comment.text = widget.activity.comment!;
    oldActivity = widget.activity.cloneActivity();
    selectedStateItem = widget.activity.state!;
    selectedTypeTierItem = typesTier.first;
    //selectedContactTierItem = contactTier.first;
    if (widget.activity.service != null)
      selectedServiceItem = widget.activity.service!;
    else
      selectedServiceItem = services.first;
    selectedProcessesItem = widget.activity.processes!;
    selectedTypeItem = widget.activity.type!;
    actionTypes = widget.allTypes.where((element) => selectedProcessesItem!.code == element.divers).toList();
    selectedStartTimeDate = widget.activity.dateStart!;
    selectedEndTimeDate = widget.activity.dateEnd!;
    if (widget.activity.emergency != null)
      ratingEmergency = widget.activity.emergency!;
    else
      ratingEmergency = 0.0;
    if (widget.activity.priority != null)
      ratingPriority = widget.activity.priority!;
    else
      ratingPriority = 0.0;
    //ratingPriority = widget.activity.priority!;
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
  }

  @override
  Widget build(BuildContext context) {
    validateButton = Opacity(
      opacity: 1,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: Theme.of(context).primaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        onPressed: () async {
          if (formKey.currentState != null &&
              formKey.currentState!.validate()) {
            Activity activity = Activity(
              id: widget.activity.id,
              user: AppUrl.user,
              processes: selectedProcessesItem,
              type: selectedTypeItem,
              object: _object.text.trim(),
              state: selectedStateItem,
              priority: ratingPriority,
              emergency: ratingEmergency,
              typeTier: selectedTypeTierItem,
              contact: null,
              comment: _comment.text.trim(),
              service: selectedServiceItem,
              start: DateFormat('yyyy-MM-dd HH:mm:ss')
                  .format(selectedStartTimeDate),
              end:
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedEndTimeDate),
              dateStart: selectedStartTimeDate,
              dateEnd: selectedEndTimeDate,
              client: widget.client,
            );
            print('rating;; $ratingPriority');
            print('rating;; $ratingEmergency');
            // final provider = Provider.of<ActivityProvider>(context,
            //     listen: false);
            // provider.activityList.add(activity);
            ConfirmationDialog confirmationDialog = ConfirmationDialog();
            bool confirmed = await confirmationDialog.showConfirmationDialog(
                context, 'confirmDupAct');
            if (confirmed) {
              // confirm
              showLoaderDialog(context);
              sendActivity(context, activity).then((value) {
                if (value) {
                  showMessage(
                      message: 'Activité dupliqué avec succès',
                      context: context,
                      color: primaryColor);
                  widget.callback();
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context);
                  showMessage(
                      message: 'Échec de dupliquation de l\'activité',
                      context: context,
                      color: Colors.red);
                }
              });
            }
          }
        },
        child: const Text(
          "Dupliquer",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
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
                      actionTypes = widget.allTypes.where((element) => selectedProcessesItem!.code == element.divers).toList();
                      selectedTypeItem = widget.allTypes.where((element) => selectedProcessesItem!.code == element.divers).toList().first;
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
                  items: actionTypes
                      .map<DropdownMenuItem<TypeActivity>>(
                          (TypeActivity value) {
                    return DropdownMenuItem<TypeActivity>(
                      value: value,
                      child: Text(
                        value.name!,
                        style: Theme.of(context).textTheme.headline4,
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
              // Visibility(
              //   visible: false,
              //   child: ListTile(
              //     title: Text(
              //       'Contacts du tiers',
              //       style: Theme.of(context).textTheme.headline6,
              //     ),
              //     subtitle: DropdownButtonFormField<String>(
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
              //         reload();
              //       },
              //       items: contactTier
              //           .map<DropdownMenuItem<String>>((String value) {
              //         return DropdownMenuItem<String>(
              //           value: value,
              //           child: Text(
              //             value,
              //             style: Theme.of(context).textTheme.headline4,
              //           ),
              //         );
              //       }).toList(),
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: customTextFieldEmpty(
                  obscure: false,
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
              // SizedBox(
              //   height: 30,
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.orange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onPressed: (){
                    PageNavigator(ctx:  context).nextPage(page: NoteListPage(client: widget.client, activity: widget.activity,));
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
    Map<String, dynamic> jsonObject;
    print('fffggg: ${activity.client.idOpp}');
    print('isNull: ${activity.client.idOpp == null}');
    if (activity.client.idOpp == null || activity.client.idOpp == 'null') {
      print('fffggg: ${activity.client.idOpp}');
      jsonObject = {
        "numero": null,
        "date": activity.dateStart.toString(),
        "datech": activity.dateStart.toString(),
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
        //"oppoCode": activity.client.idOpp,
        "contacts": contacts,
        "users": users
      };
    } else {
      jsonObject = {
        "numero": null,
        "date": DateTime.now().toString(),
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
    }

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
      return true;
    } else {
      return false;
    }
  }

  void reload() {
    setState(() {
      validateButton = Opacity(
        opacity: 1,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: Theme.of(context).primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          onPressed: () async {
            if (formKey.currentState != null &&
                formKey.currentState!.validate()) {
              Activity activity = Activity(
                id: widget.activity.id,
                user: AppUrl.user,
                processes: selectedProcessesItem,
                type: selectedTypeItem,
                object: _object.text.trim(),
                state: selectedStateItem,
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
              print('rating;; $ratingPriority');
              print('rating;; $ratingEmergency');
              // final provider = Provider.of<ActivityProvider>(context,
              //     listen: false);
              // provider.activityList.add(activity);
              ConfirmationDialog confirmationDialog = ConfirmationDialog();
              bool confirmed = await confirmationDialog.showConfirmationDialog(
                  context, 'confirmEditAct');
              if (confirmed) {
                // confirm
                showLoaderDialog(context);
                sendActivity(context, activity).then((value) {
                  if (value) {
                    showMessage(
                        message: 'Activité dupliquée avec succès',
                        context: context,
                        color: primaryColor);
                    widget.callback();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                    showMessage(
                        message: 'Échec de dupliquation de l\'activité',
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
