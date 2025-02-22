import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/activity.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/contact.dart';
import 'package:mobilino_app/models/filtred_activities.dart';
import 'package:mobilino_app/models/process.dart';
import 'package:mobilino_app/models/type_activity.dart';
import 'package:mobilino_app/providers/activity_provider.dart';
import 'package:mobilino_app/screens/activities_pages/dialog_cancel_activities.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/dialog_filtred_activities.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'activity_page.dart';
import 'add_activity_page.dart';
import 'duplicate_activity_page.dart';

class ActivityListPage extends StatefulWidget {
  final Client client;

  const ActivityListPage({super.key, required this.client});

  @override
  State<ActivityListPage> createState() => _ActivityListPageState();
}

class _ActivityListPageState extends State<ActivityListPage> {
  final FiltredActivities filtred = FiltredActivities(
      collborator: AppUrl.user.allCollaborator.first,
      team: AppUrl.user.teams.first,
      start: DateTime.now(),
      end: DateTime.now(),
      state: 'Tout',
      type: TypeActivity(id: '-1', code: '-1', name: 'Tout'));

  //Map<Process, List<TypeActivity>> activitiesProcesses = {};
  List<Process> allProcesses = [];
  List<TypeActivity> allTypes = [];
  List<String> states = [
    'En attente',
    'En cours',
    'Terminée',
    'Non réalisée',
    'Annulée'
  ];
  bool isCalander = false;
  Icon _icon = Icon(
    Icons.calendar_month_outlined,
    color: Colors.white,
  );
  List<Appointment> meetings = <Appointment>[];

  void reload() {
    setState(() {});
  }

  // Function to fetch JSON data from an API
  Future<void> fetchData(BuildContext context) async {
    await fetchDataMotif();
    await _fetchData();
    final provider = Provider.of<ActivityProvider>(context, listen: false);
    provider.activityList = [];
    String url = AppUrl.getAcivities + '?opportuniteId=${widget.client.idOpp!}';
    print('urlActOpp: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res activities code : ${req.statusCode}");
    print("res activities body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      try {
        //data.toList().forEach((element) {
        for (int i = 0; i < data.length; i++) {
          var element = data.toList()[i];
          var id;
          TypeActivity? type;
          Process? processes;
          double? level;
          double? emergency;
          int etat = 0;
          print('usersss: ${element['users']}');
          if (element['users'] == null) continue;
          List<Collaborator> collaborators = [];
          List<dynamic> users = element['users'];
          bool notExist = false;
          String collaboratorsTxt = '';
          users.forEach((user) {
            collaboratorsTxt = collaboratorsTxt + '${user['userName']} | ';
            collaborators.add(Collaborator(
              salCode: user['salCode'],
              userName: user['userName'],
              id: element['id'],
              repCode: element['repCode'],
              equipeId: element['equipeId'],
            ));
            print(
                'salCodeISS ${user['salCode']} ${filtred.collborator.userName}');
            if (user['salCode'] == filtred.collborator.salCode) notExist = true;
          });
          if (notExist == false) continue;
          // String? collaborator = filtred.collborator.salCode;
          // if (collaborator == null) collaborator = AppUrl.user.salCode!;
          // print('salcodeisss: $collaborator');
          // if (element['salCode'] != collaborator) continue;
          //if(element['contacts'] == null || element['users'] == null) continue;
          List<Contact> contacts = [];
          String contactTxt = '';
          if (element['contacts'] != null) {
            List<dynamic> contactsAct = element['contacts'];
            contactsAct.forEach((contact) {
              contactTxt =
                  contactTxt + '${contact['nom']} ${contact['prenom']} | ';
              contacts.add(Contact(
                num: contact['numero'],
                code: contact['code'],
                origin: contact['origin'],
                firstName: contact['nom'],
                famillyName: contact['prenom'],
              ));
            });
          }
          print('salCode is:  ${element['salCode']}');
          if (element['numero'] != null) id = element['numero'];
          if (element['etat'] != null)
            etat = int.parse(element['etat'].toString());
          if (element['type'] != null) {
            TypeActivity typeActivity = allTypes
                .where((elementType) => elementType.code == element['type'])
                .first;
            type = typeActivity;
            processes = allProcesses
                .where((elementProcess) =>
                    typeActivity.divers == elementProcess.code)
                .first;
            // activitiesProcesses.forEach((key, value) {
            //   value.forEach((typeDB) {
            //     if (typeDB.code == element['type']) {
            //       type = typeDB;
            //       processes = key;
            //     }
            //   });
            // });
          }
          if (element['level'] != null) level = double.parse(element['level']);
          if (element['urgence'] != null)
            emergency = double.parse(element['urgence']);
          DateTime? start;
          DateTime? end;
          String? timeStart;
          String? timeEnd;
          if (element['date'] == null || element['datfin'] == null) continue;
          if (element['date'] != null) {
            start = DateTime.parse(element['date']);
            timeStart = DateFormat('yyyy-MM-dd HH:mm:ss').format(start);
          }
          if (element['datfin'] != null) {
            end = DateTime.parse(element['datfin']);
            timeEnd = DateFormat('yyyy-MM-dd HH:mm:ss').format(end);
          }
          String typeClient = 'Client';
          if (widget.client.type == 'P') typeClient = 'Prospect';
          if (widget.client.type == 'F') typeClient = 'Fournisseur';
          Activity activity = Activity(
            user: AppUrl.user,
            client: widget.client,
            id: id,
            object: element['objet'],
            comment: element['desc'],
            type: type!,
            typeTier: typeClient,
            contact: null,
            state: states[etat],
            priority: level,
            emergency: emergency,
            dateStart: start,
            dateEnd: end,
            start: timeStart,
            end: timeEnd,
            processes: processes,
            collaboratorsTxt: collaboratorsTxt,
            contactTxt: contactTxt,
          );
          activity.contacts = contacts;
          activity.collaborators = collaborators;
          activity.res = element;
          Duration duration = DateTime.now().difference(activity.dateEnd!);
          if (activity.state == states[0] &&
              duration.inDays > AppUrl.dayDepasAct &&
              AppUrl.dayDepasAct > 0) {
            activity.state = states[3];
            await unterminedActivity(activity);
          }
          if (activity.state == states[1] &&
              duration.inDays > AppUrl.dayDepasCoursAct &&
              AppUrl.dayDepasCoursAct > 0) {
            activity.state = states[3];
            await unterminedActivity(activity);
          }
          provider.activityList.add(activity);
          provider.notifyListeners();
        }
        //});
      } catch (_) {}
    }
    print('size is : ${provider.activityList.length}');
    provider.notifyListeners();
  }

  Future<void> fetchDataProcesses() async {
    allProcesses = [];
    //activitiesProcesses = {};
    print('urlPro ${Uri.parse(AppUrl.getProcess)}');
    print('urlPro http://"+AppUrl.user.company!+".my-crm.net:5188/api/Process');
    http.Response req = await http.get(Uri.parse(AppUrl.getProcess), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res processes code : ${req.statusCode}");
    print("res processes body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.toList().forEach((element) {
        allProcesses.add(Process(
            id: element['id'],
            name: element['lib'],
            code: element['code'],
            divers: element['divers']));
      });
    }
  }

  Future<void> fetchDataTypes(Process process) async {
    print('url: ${AppUrl.getActionTypes}');
    http.Response req =
        await http.get(Uri.parse(AppUrl.getActionTypes), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res typeAct code : ${req.statusCode}");
    print("res typeAct body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      List<TypeActivity> types = [];
      //activitiesProcesses[process] = types;
      data.toList().forEach((element) {
        types.add(TypeActivity(
            id: element['id'],
            code: element['code'],
            name: element['lib'],
            divers: element['divers']));
        allTypes.add(TypeActivity(
            id: element['id'],
            code: element['code'],
            name: element['lib'],
            divers: element['divers']));
      });
      //activitiesProcesses[process] = types;
    }
  }

  Future<void> fetchDataMotif() async {
    String url = AppUrl.getMotif;
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res motif code : ${req.statusCode}");
    print("res motif body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      //activitiesProcesses[process] = types;
      data.toList().forEach((element) {
        AppUrl.user.motifs.add(TypeActivity(
          id: element['id'],
          code: element['code'],
          name: element['lib'],
        ));
      });
      //activitiesProcesses[process] = types;
    }
  }

  Future<void> _fetchData() async {
    // Use this method to orchestrate the execution of multiple asynchronous methods
    await fetchDataProcesses().then((value) {
      allProcesses.toList().forEach((element) {
        fetchDataTypes(element);
      });
    });
    // if (activitiesProcesses.keys.isNotEmpty) {
    //   selectedProcessesItem = activitiesProcesses.keys.toList().first;
    //   if (activitiesProcesses[selectedProcessesItem]!.isNotEmpty)
    //     selectedTypeItem = activitiesProcesses[selectedProcessesItem]!.first;
    //   print('first: ${selectedProcessesItem}');
    // }
  }

  @override
  Widget build(BuildContext context) {
    allTypes = [];
    allTypes.add(TypeActivity(id: '-1', code: '-1', name: 'Tout'));
    return FutureBuilder(
        future: fetchData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Future is still running, return a loading indicator or some placeholder.
            return AlertDialog(
              content: Container(
                  width: 200,
                  height: 100,
                  child: Image.asset('assets/CRM-Loader.gif')),
            );
          } else if (snapshot.hasError) {
            // There was an error in the future, handle it.
            print('Error: ${snapshot.hasError}');
            return AlertDialog(
              content: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  // Text('Error: ${snapshot.error}')
                  Text(
                      'Nous sommes désolé, la qualité de votre connexion ne vous permet pas de vous connecter à votre serveur.'
                      ' Veuillez réessayer ultérieurement. Merci')
                ],
              ),
            );
          } else
            return Scaffold(
              appBar: AppBar(
                actions: [
                  Visibility(
                    visible: false,
                    child: IconButton(
                        onPressed: () {
                          if (isCalander) {
                            _icon = Icon(
                              Icons.calendar_month_outlined,
                              color: Colors.white,
                            );
                          } else {
                            _icon = Icon(
                              Icons.list_alt_outlined,
                              color: Colors.white,
                            );
                          }
                          isCalander = !isCalander;
                          setState(() {});
                        },
                        icon: _icon),
                  ),
                  IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return FiltredActivitiesDialog(
                              filtred: filtred,
                              allTypes: allTypes,
                            );
                          },
                        ).then((value) {
                          setState(() {});
                        });
                      },
                      icon: Icon(
                        Icons.sort,
                        color: Colors.white,
                      )),
                ],
                iconTheme: IconThemeData(
                  color: Colors.white, // Set icon color to white
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activités de :',
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.client.lib}, ${widget.client.name}',
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: Colors.white),
                    ),
                    Text(
                      'Collaborateur: ${filtred.collborator.userName}',
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: Colors.white),
                    ),
                  ],
                ),
                backgroundColor: primaryColor,
              ),
              floatingActionButton: FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(50.0), // Set FAB shape to circle
                ),
                backgroundColor: primaryColor,
                onPressed: () {
                  PageNavigator(ctx: context).nextPage(
                      page: AddActivityPage(
                    callback: reload,
                    client: widget.client,
                    allProcesses: allProcesses,
                    allTypes: allTypes,
                    //activitiesProcesses: activitiesProcesses,
                  ));
                },
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
              body: Consumer<ActivityProvider>(
                builder: (context, activities, child) {
                  if (isCalander)
                    return buildFormatCalendar(context);
                  else
                    return buildFormatList();
                },
              ),
            );
        });
  }

  SfCalendar buildFormatCalendar(BuildContext context) {
    return SfCalendar(
      view: CalendarView.week,
      firstDayOfWeek: DateTime.sunday,
      dataSource: MeetingDataSource(getAppointments()),
      todayHighlightColor: primaryColor,
      selectionDecoration: BoxDecoration(
        border: Border.all(
          // Change the border color here
          color: Colors.red, // Change this color to your desired color
          width: 2.0, // Adjust the border width as needed
        ),
      ),
      onTap: (details) => calendarTapped(context, details),
      // initialDisplayDate: DateTime(2021),
      // initialSelectedDate: DateTime.now(),
    );
  }

  void calendarTapped(BuildContext context, CalendarTapDetails details) {
    if (details.appointments != null && details.appointments!.isNotEmpty) {
      Activity activity = details.appointments![0].id;
      PageNavigator(ctx: context).nextPage(
          page: ActivityPage(
        callback: reload,
        client: activity.client,
        activity: activity,
        allProcesses: allProcesses,
        allTypes: allTypes,
        //activitiesProcesses: activitiesProcesses
      ));
    }
    // String date = calendarTapDetails.date.toString().split(' ')[0];
    // for (int i = 0; i < meetings.length; i++) {
    //   if (date == meetings[0].startTime.toString().split(' ')[0]) {
    //     _showDialog(context, date);
    //     break;
    //   }
    // }
  }

  void _showDialog(BuildContext context, String date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: double.infinity,
            child: Text('date'),
          ),
        );
      },
    );
  }

  List<Appointment> getAppointments() {
    final provider = Provider.of<ActivityProvider>(context, listen: false);
    meetings = <Appointment>[];
    List<Activity> list = provider.filtredListActivity(filtred);
    for (Activity activity in list) {
      final DateTime today = DateTime.now();
      final DateTime startTime = activity.dateStart!;
      final DateTime endTime = activity.dateStart!;

      meetings.add(Appointment(
          startTime: startTime,
          endTime: endTime,
          subject: 'Board Meeting',
          color: primaryColor,
          //recurrenceRule: 'FREQ=DAILY;COUNT=10',
          isAllDay: false));

      // meetings.add(Appointment(
      //     startTime: startTime,
      //     endTime: endTime,
      //     subject: 'Board Meeting',
      //     color: Colors.blue,
      //     //recurrenceRule: 'FREQ=DAILY;COUNT=10',
      //     isAllDay: false));
    }
    return meetings;
  }

  SingleChildScrollView buildFormatList() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
            child: DataTable(
                dividerThickness: 1.0,
                columns: _buildTableColumns(),
                rows: _buildTableRows())));
  }

  List<DataColumn> _buildTableColumns() {
    if (AppUrl.columns.isNotEmpty && AppUrl.columns[0].length > 0) {
      return List.generate(
        AppUrl.columns.length,
        (index) => DataColumn(
          label: Text('${AppUrl.columns[index]}'),
        ),
      );
    }
    return [];
  }

  List<DataRow> _buildTableRows() {
    final provider = Provider.of<ActivityProvider>(context, listen: false);
    List<Activity> list = provider.filtredListActivity(filtred);
    //provider.notifyListeners();
    print('sizeOfActivityList ${list.length}');
    return list
        .map((dataItem) => DataRow(
              onLongPress: () => showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100.0, 100.0, 100.0, 100.0),
                items: [
                  PopupMenuItem(
                    value: 1,
                    child: Text('Afficher'),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text('Modifier'),
                  ),
                  PopupMenuItem(
                    value: 3,
                    child: Text('Dupliquer'),
                  ),
                  PopupMenuItem(
                    value: 4,
                    child: Text('Annuler'),
                  ),
                ],
              ).then((value) {
                switch (value) {
                  case 1:
                    PageNavigator(ctx: context).nextPage(
                        page: ActivityPage(
                      activity: dataItem,
                      client: dataItem.client,
                      callback: reload,
                      allProcesses: allProcesses,
                      allTypes: allTypes,
                      //activitiesProcesses: activitiesProcesses,
                    ));
                    break;
                  case 2:
                    PageNavigator(ctx: context).nextPage(
                        page: ActivityPage(
                      activity: dataItem,
                      client: dataItem.client,
                      callback: reload,
                      allProcesses: allProcesses,
                      allTypes: allTypes,
                      //activitiesProcesses: activitiesProcesses,
                    ));
                    break;
                  case 3:
                    PageNavigator(ctx: context).nextPage(
                        page: DuplicateActivityPage(
                      activity: dataItem,
                      client: dataItem.client,
                      callback: reload,
                      allProcesses: allProcesses,
                      allTypes: allTypes,
                      //activitiesProcesses: activitiesProcesses,
                    ));
                    break;
                  case 4:
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CancelActivitiesDialog(
                          activity: dataItem,
                        );
                      },
                    ).then((valueAct) {
                      if (valueAct == null || valueAct == 'null') {
                      } else {
                        Activity act = valueAct;
                        print('gggggg:: ${act.motif}');
                        showLoaderDialog(context);
                        dataItem.state = states[4];
                        cancelActivity(context, dataItem).then((value) {
                          if (value) {
                            showMessage(
                                message: 'Activité a été annulée avec succès',
                                context: context,
                                color: primaryColor);
                            Navigator.pop(context);
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
                    break;
                }
              }),
              //PageNavigator(ctx: context).nextPage(page: ActivityPage(activity: dataItem, callback: reload,));
              cells: [
                DataCell((dataItem.object! != null)
                    ? Text(dataItem.object!)
                    : Text('')),
                DataCell((dataItem.state != null)
                    ? Text(dataItem.state!)
                    : Text('')),
                DataCell(Text('${dataItem.client.name}')),
                DataCell((dataItem.typeTier != null)
                    ? Text(dataItem.typeTier!)
                    : Text('')),
                DataCell(Text(dataItem.contactTxt!)),
                DataCell(Text('${dataItem.collaboratorsTxt}')),
                DataCell((dataItem.dateStart != null)
                    ? Text(dataItem.start!)
                    : Text('')),
                DataCell((dataItem.dateEnd != null)
                    ? Text(dataItem.end!)
                    : Text('')),
                //Text('${AppUrl.user.firstName!} ${AppUrl.user.lastName!}')),
                DataCell((dataItem.processes!.name! != null)
                    ? Text(dataItem.processes!.name!)
                    : Text('')),
                DataCell((dataItem.type!.name! != null)
                    ? Text(dataItem.type!.name!)
                    : Text('')),

                DataCell((dataItem.priority.toString() != null)
                    ? Text(dataItem.priority.toString())
                    : Text('')),
                DataCell((dataItem.emergency.toString() != null)
                    ? Text(dataItem.emergency.toString())
                    : Text('')),
                DataCell((dataItem.comment != null)
                    ? Text('${dataItem.comment}')
                    : Text('')),
              ],
            ))
        .toList();
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

  Future<bool> unterminedActivity(Activity activity) async {
    //int etat = states.indexOf(activity.state!);

    activity.res['users'].forEach((element) {
      element['ID'] = element['userName'];
    });
    activity.res['etat'] = states.indexOf(activity.state!);

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
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
// [
// DataColumn(
// label: Text('ID'),
// //onSort: (columnIndex, ascending) => sortData(columnIndex, ascending), // Sort callback for ID column
// ),
// DataColumn(
// label: Text('Name'),
// //onSort: (columnIndex, ascending) => sortData(columnIndex, ascending), // Sort callback for Name column
// ),
// DataColumn(
// label: Text('Category'),
// //onSort: (columnIndex, ascending) => sortData(columnIndex, ascending), // Sort callback for Category column
// ),
// DataColumn(
// label: Text('Value'),
// //onSort: (columnIndex, ascending) => sortData(columnIndex, ascending), // Sort callback for Value column
// ),DataColumn(
// label: Text('Value'),
// //onSort: (columnIndex, ascending) => sortData(columnIndex, ascending), // Sort callback for Value column
// ),DataColumn(
// label: Text('Value'),
// //onSort: (columnIndex, ascending) => sortData(columnIndex, ascending), // Sort callback for Value column
// ),
// ]
// list view
// ListView.builder(
// padding: EdgeInsets.all(12),
// physics: BouncingScrollPhysics(),
// itemBuilder: (context, index) => InkWell(
// onTap: () {
// // Navigator.pushNamed(
// //     context, ClientPage.routeName);
// },
// child: ActivityItem(
// activity: activities.activityList.toList()[index])),
// itemCount: activities.activityList.length)

// class ActivityItem extends StatefulWidget {
//   final Activity activity;
//
//   const ActivityItem({super.key, required this.activity});
//
//   @override
//   State<ActivityItem> createState() => _ActivityItemState();
// }
//
// class _ActivityItemState extends State<ActivityItem> {
//   Widget icon = Icon(Icons.shopping_cart_outlined);
//   int respone = 200;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   showLoaderDialog(context);
//     //   fetchData().then((value) {
//     //     Navigator.pop(context);
//     //   });
//     // });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           height: 98,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Icon(
//                 Icons.local_activity_outlined,
//                 color: primaryColor,
//               ),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.activity.processes!,
//                     style: Theme.of(context)
//                         .textTheme
//                         .headline5!
//                         .copyWith(color: primaryColor),
//                   ),
//                   Text(widget.activity.processes!,
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyText1!
//                           .copyWith(color: Colors.grey)),
//                 ],
//               ),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   IconButton(
//                     onPressed: () {},
//                     icon: Icon(Icons.shopping_cart_outlined),
//                     color: primaryColor,
//                   ),
//                   IconButton(
//                       onPressed: () {},
//                       icon: Icon(
//                         Icons.local_activity_outlined,
//                         color: primaryColor,
//                       ))
//                 ],
//               ),
//             ],
//           ),
//         ),
//         Divider(
//           color: Colors.grey,
//         )
//       ],
//     );
//   }
// }
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
