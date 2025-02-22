import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/http_request.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/constants/utils.dart';
import 'package:mobilino_app/models/activity.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/concurrent.dart';
import 'package:mobilino_app/models/contact.dart';
import 'package:mobilino_app/models/lot.dart';
import 'package:mobilino_app/models/notif.dart';
import 'package:mobilino_app/models/process.dart';
import 'package:mobilino_app/models/salon.dart';
import 'package:mobilino_app/models/type_activity.dart';
import 'package:mobilino_app/providers/notif_provider.dart';
import 'package:mobilino_app/screens/home_page/activities_pages/activity_page.dart';
import 'package:mobilino_app/screens/home_page/opportunity_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/concurrent_list_page.dart';
import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:mobilino_app/widgets/text_field.dart';
import 'package:provider/provider.dart';

class NotifsListPage extends StatefulWidget {
  NotifsListPage({
    super.key,
  });

  @override
  State<NotifsListPage> createState() => _NotifsListPageState();
}

class _NotifsListPageState extends State<NotifsListPage> {
  int PageNumber = 0;
  int PageSize = 10;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    // Don't forget to dispose the scroll controller
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Check if we've reached the end of the list
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // We're at the end of the list, perform your action here
      print('Reached the end of the list!');
      showLoaderDialog(context);
      fetchDataNotif().then((value) {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        //future: fetchConcurrents(),
        future: fetchDataNotif(),
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
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              iconTheme: IconThemeData(
                color: Colors.white, // Set icon color to white
              ),
              title: ListTile(
                title: Text(
                  'Liste des notifications : ',
                  style: Theme.of(context)
                      .textTheme
                      .headline3!
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
            body: Consumer<NotifProvider>(builder: (context, provider, child) {
              return Container(
                height: AppUrl.getFullHeight(context) * 0.9,
                padding: EdgeInsets.only(top: 20, right: 10, left: 10),
                child: (provider.notifList.length > 0)
                    ? ListView.builder(
                        controller: _scrollController,
                        physics: BouncingScrollPhysics(),
                        itemCount: provider.notifList.length,
                        itemBuilder: (context, index) {
                          return NotifItem(
                            notif: provider.notifList[index],
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'Aucune notification !',
                          style:
                              Theme.of(context).textTheme.headline5!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
              );
            }),
          );
        });
  }

  Future<void> fetchDataNotif() async {
    final provider = Provider.of<NotifProvider>(context, listen: false);
    PageNumber++;
    if (PageNumber == 1) provider.notifList = [];
    String url = AppUrl.getNotif +
        '?salCode=${AppUrl.user.salCode}&PageNumber=$PageNumber&PageSize=$PageSize';
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res contacts code : ${req.statusCode}");
    print("res contacts body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      //activitiesProcesses[process] = types;
      print('efrfr : ${data.length}');
      //data.toList().forEach((element) {
      for (int i = 0; i < data.length; i++) {
        var element = data[i];
        try {
          print('elemnt : $element');
          Notif notif = Notif(
            code: element['code'],
            type: element['type'].toString().toUpperCase(),
            lib: element['libelle'],
            date: DateTime.parse(element['date']),
            seen: element['vu'],
            codeLie: element['codeLie'],
            desc: element['description'],
            sType: element['sType'],
          );
          notif.res = element;
          provider.notifList.add(notif);
        } catch (e) {
          print('errrrrr $e');
          continue;
        }
      }
      //});
    }
  }
}

class NotifItem extends StatefulWidget {
  const NotifItem({super.key, required this.notif});

  final Notif notif;

  @override
  State<NotifItem> createState() => _NotifItemState();
}

class _NotifItemState extends State<NotifItem> {
  late Icon icon;

  @override
  void initState() {
    super.initState();
    icon = Icon(
      Icons.notifications_active_outlined,
      color: primaryColor,
    );
  }

  Future<bool> changeToSeen(Notif notif) async {
    print('obj: ${notif.res}');
    notif.res['vu'] = true;
    print('obj: ${notif.res}');
    String url = AppUrl.editNotif + '${notif.code}';
    print('url: ${url}');
    http.Response req =
        await http.put(Uri.parse(url), body: jsonEncode(notif.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res actEdit code : ${req.statusCode}");
    print("res actEdit body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      widget.notif.seen = true;
      await HttpRequestApp().getNotif();
      return true;
    } else {
      return false;
    }
  }

  Future<Client?> getOppo(String code) async {
    String url = AppUrl.getOneOppo + '${code}';
    print('oneOppo $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res oneOppo code : ${req.statusCode}");
    print("res oneOppo body: ${req.body}");
    if (req.statusCode == 200) {
      var element = json.decode(req.body);
      String pcfCode = element['tiersId'];
      req = await http.get(Uri.parse(AppUrl.getOneTier + pcfCode), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
      });
      print("res tier code: ${req.statusCode}");
      print("res tier body: ${req.body}");
      if (req.statusCode == 200) {
        var res = json.decode(req.body);
        LatLng latLng;
        if (res['longitude'] == null || res['latitude'] == null)
          latLng = LatLng(1.354474457244855, 1.849465150689236);
        else {
          try {
            latLng = LatLng(res['latitude'], res['longitude']);
          } catch (e) {
            latLng = LatLng(1.354474457244855, 1.849465150689236);
          }
        }
        print('grggrrg: ${element['etape']}');
        Client client = new Client(
          idOpp: element['code'].toString(),
          id: res['code'],
          type: res['type'],
          name: res['rs'],
          name2: res['rs2'],
          phone2: res['tel2'],
          total: element['montant'].toString(),
          phone: res['tel1'],
          city: res['ville'],
          location: latLng,
          stat: element['etapeId'],
          priority: element['priorite'],
          emergency: element['urgence'],
          lib: element['libelle'],
          resOppo: element,
          dateStart: DateTime.parse(element['dateDebut']),
          dateCreation: DateTime.parse(element['dateCreation']),
        );
        return client;
      }
    }
    return null;
  }

  List<Process> allProcesses = [];
  List<TypeActivity> allTypes = [];
  List<String> states = [
    'En attente', //0
    'En cours', //1
    'Terminée', //2
    'Non réalisée', //3
    'Annulée' //4
  ];

  Future<void> _fetchData() async {
    await fetchDataMotif();
    await fetchDataProcesses().then((value) {
      allProcesses.toList().forEach((element) {
        fetchDataTypes(element);
      });
    });
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
    allTypes = [];
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

  Future<Activity?> getActivity(String code) async {
    await _fetchData();
    String url = AppUrl.getAcivities + '/${code}';
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });

    print("res oneAct code : ${req.statusCode}");
    print("res oneAct body: ${req.body}");
    if (req.statusCode == 200) {
      var element = json.decode(req.body);
      var id;
      TypeActivity? type;
      Process? processes;
      double? level;
      double? emergency;
      int etat = 0;

      if (element['users'] == null) return null;
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
      });
      List<Contact> contacts = [];
      String contactTxt = '';
      if (element['contacts'] != null) {
        List<dynamic> contactsAct = element['contacts'];
        contactsAct.forEach((contact) {
          contactTxt = contactTxt + '${contact['nom']} ${contact['prenom']} | ';
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
      if (element['etat'] != null) etat = int.parse(element['etat'].toString());
      print('tyyyyyyyype: ${element['type']}');
      if (element['type'] != null) {
        TypeActivity typeActivity = allTypes
            .where((elementType) => elementType.code == element['type'])
            .first;
        type = typeActivity;
        print(
            'processe:: ${allProcesses.where((elementProcess) => typeActivity.divers == elementProcess.code).length}');
        processes = allProcesses
            .where(
                (elementProcess) => typeActivity.divers == elementProcess.code)
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

      //emergency = null;
      DateTime? start;
      DateTime? end;
      String? timeStart;
      String? timeEnd;
      print(
          'hghghghghg } ${element['date']} ${element['datfin']} ${element['pcfCode']}');
      if (element['date'] == null || element['datfin'] == null) return null;
      if (element['date'] != null) {
        start = DateTime.parse(element['date']);
        timeStart = DateFormat('yyyy-MM-dd HH:mm:ss').format(start);
      }
      if (element['datfin'] != null) {
        end = DateTime.parse(element['datfin']);
        timeEnd = DateFormat('yyyy-MM-dd HH:mm:ss').format(end);
      }
      if (element['pcfCode'] == null) return null;
      req = await http
          .get(Uri.parse(AppUrl.getOneTier + element['pcfCode']), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
      });
      print("res tier code: ${req.statusCode}");
      print("res tier body: ${req.body}");
      if (req.statusCode == 200) {
        var res = json.decode(req.body);
        LatLng latLng;
        if (res['longitude'] == null || res['latitude'] == null)
          latLng = LatLng(1.354474457244855, 1.849465150689236);
        else {
          try {
            latLng = LatLng(res['latitude'], res['longitude']);
          } catch (_) {
            latLng = LatLng(1.354474457244855, 1.849465150689236);
          }
        }

        String typeClient = 'Client';
        if (res['type'] == 'P') typeClient = 'Prospect';
        if (res['type'] == 'F') typeClient = 'Fournisseur';
        print('fffffff: ${element['priorite']}');

        print('etat :: $etat  $id');
        Client client = new Client(
          idOpp: element['code'].toString(),
          id: res['code'],
          type: res['type'],
          name: res['rs'],
          name2: element['rs2'],
          phone2: element['tel2'],
          total: element['montant'].toString(),
          phone: res['tel1'],
          city: res['ville'],
          location: latLng,
          stat: element['etapeId'],
          // priority: element['priorite'],
          // emergency: element['urgence'],
          lib: element['libelle'],
          //dateCreation: DateTime.parse(element['dateCreation']),
        );
        Activity activity = Activity(
          user: AppUrl.user,
          client: client,
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
        return activity;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    PageNavigator page = PageNavigator(ctx: context);
    return InkWell(
      onTap: () {
        showLoaderDialog(context);
        changeToSeen(widget.notif).then((value) {
          if (value) {
            setState(() {});
            if (widget.notif.type == 'O') {
              getOppo(widget.notif.codeLie.toString()).then((client) {
                if (client != null) {
                  PageNavigator(ctx: context)
                      .nextPage(page: OpportunityPage(client: client)).then((value) => Navigator.pop(context));
                } else {
                  showAlertDialog(
                      context, 'Impossible d\'afficher cette opportunité');
                  Navigator.pop(context);
                }
              });
            } else if (widget.notif.type == 'A') {
              getActivity(widget.notif.codeLie.toString()).then((activity) {
                if (activity != null) {
                  PageNavigator(ctx: context).nextPage(
                      page: ActivityPage(
                    activity: activity,
                    callback: () {
                      setState(() {});
                    },
                    client: activity.client,
                    allProcesses: allProcesses,
                    allTypes: allTypes,
                  )).then((value) => Navigator.pop(context));
                } else {
                  showAlertDialog(
                      context, 'Impossible d\'afficher cette activité');
                  Navigator.pop(context);
                }
              });
            }
          }
        }).then((value){

        });
        // if (widget.note.type == Note.TEXT) {
        //   page.nextPage(
        //       page: TextNotePage(
        //     note: widget.note,
        //     visible: false,
        //   ));
        // }
      },
      child: Container(
        color: (!widget.notif.seen!) ? AppUrl.lighten(primaryColor, 0.9) : null,
        child: Column(
          children: [
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${widget.notif.lib}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.headline6),
                  SizedBox(
                    height: 7,
                  ),
                  Row(
                    children: [
                      Text('${widget.notif.desc}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith()),
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_month_outlined,
                          color: primaryColor, size: 20),
                      SizedBox(
                        width: 7,
                      ),
                      Text(
                          '${DateFormat('dd-MM-yyyy').format(widget.notif.date!)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith()),
                      SizedBox(
                        width: 20,
                      ),
                      Icon(Icons.access_time, color: primaryColor, size: 20),
                      SizedBox(
                        width: 7,
                      ),
                      Text('${DateFormat('HH:mm').format(widget.notif.date!)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith()),
                    ],
                  ),
                ],
              ),
              leading: icon,
            ),
            Divider(
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
    // return Column(
    //   children: [
    //     Container(
    //       height: 70,
    //       child: Row(
    //         //mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           icon,
    //           Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text('${widget.note.type}'),
    //             ],
    //           ),
    //         ],
    //       ),
    //     ),
    //     Divider(
    //       color: Colors.grey,
    //     )
    //   ],
    // );
    ;
  }
}

showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Container(
        width: 200, height: 100, child: Image.asset('assets/CRM-Loader.gif')),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
