import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/database/db_provider.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/depot.dart';
import 'package:mobilino_app/models/familly.dart';
import 'package:mobilino_app/models/sfamilly.dart';
import 'package:mobilino_app/providers/clients_map_provider.dart';
import 'package:mobilino_app/screens/home_page/itineraire_fragment.dart';
import 'package:mobilino_app/screens/home_page/pipline_fragment.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/widgets/appbars/tournees_appbar.dart';
import 'package:mobilino_app/widgets/drawers/home_drawer.dart';
import 'package:mobilino_app/widgets/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'calander_fragment.dart';
import 'calander_fragment.dart';
import 'clients_list_fragment.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String routeName = '/home';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => HomePage(),
    );
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    try {
      print('equipe size: ${AppUrl.user.teams.length}');
      print('salCode: ${AppUrl.user.salCode}');
      print('collaborators size: ${AppUrl.user.collaborator.length}');
      if (AppUrl.user.collaborator.length > 0)
        print('coll salCode : ${AppUrl.user.collaborator.last.salCode}');
      print('dateSelected: ${AppUrl.filtredOpporunity.date}');
        print('etbl: ${AppUrl.user.etblssmnt!.code}');
      print('startEnd ! ${AppUrl.startTime} ');
      if (AppUrl.user.localDepot != null) {
        print('depStock: ${AppUrl.user.localDepot!.id}');
      } else {
        AppUrl.user.localDepot = Depot(id: '001', name: 'name');
      }

      print('company: ${AppUrl.user.company}');
      print('salCode: ${AppUrl.user.salCode}');
      print('repCode: ${AppUrl.user.repCode}');
      print('image: ${AppUrl.user.image}');
      print('equipeId: ${AppUrl.user.equipeId}');
      print('image: ${AppUrl.baseUrl}');
      // WidgetsBinding.instance.addPostFrameCallback((_) async {
      //   try{
      //   showLoaderDialog(context);
      //   await fetchData().then((value) {
      //     final provider =
      //         Provider.of<ClientsMapProvider>(context, listen: false);
      //     print('size of list: ${provider.mapClientsWithCommands}');
      //     Navigator.pop(context);
      //   });} on SocketException catch (_) {
      //     _showAlertDialog(context,
      //         'Pas de connecxion !');
      //   }
      // });
    } catch (_) {}
  }

  // Function to fetch JSON data from an API
  Future<void> fetchData() async {
    print('debuginggg');
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.mapClientsWithCommands = [];
    int? equipe;
    String collaborator = AppUrl.user.userId!;
    print('ffff: ${AppUrl.user.userId}');
    print('ss: ${AppUrl.filtredOpporunity.collaborateur!.id}');
    if (AppUrl.filtredOpporunity.collaborateur!.id != null) {
      if (AppUrl.filtredOpporunity.collaborateur!.id! != -1) {
        collaborator = AppUrl.filtredOpporunity.collaborateur!.userName!;
      }
    } else {
      collaborator = AppUrl.filtredOpporunity.collaborateur!.userName!;
    }

    if (AppUrl.filtredOpporunity.team!.id! != -1)
      equipe = AppUrl.filtredOpporunity.team!.id!;

    if (collaborator == '${AppUrl.user.userId}') collaborator = AppUrl.user.userId!;
    print('debuginggg222 $collaborator');
    var body = jsonEncode({
      "filter": null,
      "equipe": equipe,
      "tiers": null,
      "priorite": null,
      "urgence": null,
      "collaborateur": collaborator,
      "collaborateurs": [],
      "dateDebut": DateFormat('yyyy-MM-ddT00:00:00')
          .format(AppUrl.filtredOpporunity.date),
      "dateFin": DateFormat('yyyy-MM-ddT23:59:59')
          .format(AppUrl.filtredOpporunity.dateEnd)
    });
    http.Response req = await http
        .post(Uri.parse(AppUrl.opportunitiesFiltred), body: body, headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res opp code : ${req.statusCode}");
    print("res opp body: ${req.body}");
    if (req.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      List<dynamic> data = json.decode(req.body);
      print('size of opportunities : ${data.toList().length}');
      //addOppurtonities(data);
      //data.toList().forEach((element) async {
      for (var element in data.toList()) {
        print('element:  ${element}');
        print('id client:  ${element['tiersId']}');
        print('id opp:  ${element['code']}');
        print('etapeId: ${element['etapeId']}');
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
          //if(element['etapeId'] == 1 || element['etapeId'] == 2)
          provider.mapClientsWithCommands.add(client);
          print('size of opp: ${provider.mapClientsWithCommands.length}');
        }
      }
      provider.mapClientsWithCommands
          .sort((a, b) => b.dateStart!.compareTo(a.dateStart!));
    } else {
      print('Failed to load data');
    }
    provider.updateList();
  }


  Future<void> getTounee({
    BuildContext? context,
  }) async {
    String url = AppUrl.tounee;

    try {
      http.Response req = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
      });

      print("res code is : ${req.statusCode}");
      print("res body: ${req.body}");
    } on SocketException catch (_) {
      print('no connection');
    } catch (e) {
      print("hmm:::: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchData(),
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
            print('Error: ${snapshot.hasError} ${snapshot.error} ');
            return AlertDialog(
              content: Container(
                height: 100,
                child: Column(
                  children: [
                    Row(
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
                        Column(
                          children: [
                            // Text(
                            //     textAlign: TextAlign.center,
                            //     'Nous sommes désolé, la qualité de '
                            //     'votre connexion ne vous permet pas'
                            //     ' de vous connecter à votre serveur. '
                            //     'Veuillez réessayer ultérieurement. Merci'),
                            Text(
                                textAlign: TextAlign.center,
                                'Pas de connexion'),
                          ],
                        ),
                        ],
                    ),
                  ],
                ),
              ),
              actions: [
                Container(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (route) => false);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mettre à jour',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(color: Colors.white),
                        ),
                        Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
            // return AlertDialog(
            //   content: Row(
            //     //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Icon(
            //         Icons.error_outline,
            //         color: Colors.red,
            //       ),
            //       SizedBox(
            //         width: 30,
            //       ),
            //       // Text('Error: ${snapshot.error}')
            //       Text('Nous sommes désolé, la qualité de votre connexion ne vous permet pas de vous connecter à votre serveur.'
            //           ' Veuillez réessayer ultérieurement. Merci'),
            //     ],
            //   ),
            // );
          } else
            return DefaultTabController(
              length: 4,
              child: Scaffold(
                  appBar: TourneesAppBar(),
                  drawer: DrawerHomePage(),
                  body: TabBarView(
                    children: [
                      PiplineFragment(),
                      ClientListFragment(),
                      ItineraireFragment(),
                      CalanderFragment(),
                    ],
                  )),
            );
        });
  }

  void addOppurtonities(List<dynamic> data) {
    if (data.toList().length == 0) {
      Map<String, dynamic> jsonObject = {
        "code": 0,
        "libelle": "string",
        "proprio": "string",
        "statut": "string",
        "montant": 0,
        "contact": "string",
        "dateCreation": "2023-09-15T19:00:29.434Z",
        "dateDebut": "2023-09-15T19:00:29.434Z",
        "priorite": 0,
        "urgence": 0,
        "description": "string",
        "motifSupp": "string",
        "userSupp": "string",
        "deleted": true,
        "dateSupp": "2023-09-15T19:00:29.434Z",
        "dateMaj": "2023-09-15T19:00:29.434Z",
        "userCreat": "string",
        "userMaj": "string",
        "etapeId": 1,
        "tiersId": "aaa001",
      };

      List<Map<String, dynamic>> jsonArray = [jsonObject];
      String jsonString = jsonEncode(jsonArray);
      print(' the array is: $jsonString');
      data = json.decode(jsonString);
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
              Navigator.of(context).pop();
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
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
