import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/models/process.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/constants/utils.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/type_activity.dart';
import 'package:mobilino_app/screens/activities_pages/add_activity_page.dart';
import 'package:mobilino_app/screens/home_page/GoogleMapPage.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/dialog_opp_state.dart';
import 'package:mobilino_app/widgets/payment_page.dart';

import '../new_command_page/store_page.dart';
import 'add_contact_page.dart';
import 'client_history_page.dart';
import 'contacts_page.dart';
import 'edit_client_page.dart';

class ClientPage extends StatefulWidget {
  final Client client;

  const ClientPage({super.key, required this.client});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  Widget icon = Icon(Icons.shopping_cart_outlined);
  int respone = 200;
  LatLng? currentLocation;
  List<Process> allProcesses = [];
  List<TypeActivity> allTypes = [];
  List<String> items = [
    'A visité',
    'Visité',
    'Livré',
    'Encaissé',
    'Livré & encaissé',
    'Annulée'
  ];

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    print('lib: ${widget.client.phone2}');
    print('lib: ${widget.client.priority}');
    if (widget.client.totalPay! > 0) {
      color = primaryColor;
    } else if (widget.client.totalPay! < 0) {
      color = Colors.red;
    }
    String type = '';
    if (widget.client.type == 'C')
      type = 'Client';
    else if (widget.client.type == 'P')
      type = 'Prospect';
    else if (widget.client.type == 'F') type = 'Fournisseur';
    Color txtColor = primaryColor;
    if (widget.client.type == 'C') txtColor = Colors.blue;
    if (widget.client.type == 'F') txtColor = Colors.red;
    return FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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
                    '$type : ',
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
                ),
              ),
              floatingActionButton: SpeedDial(
                animatedIcon: AnimatedIcons.menu_close,
                backgroundColor: primaryColor,
                children: [
                  SpeedDialChild(
                    backgroundColor: primaryColor,
                    child: Icon(
                      Icons.payment_outlined,
                      color: Colors.white,
                    ),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return PaymentPage(
                                client:
                                    widget.client); // client: widget.client,
                          });
                    },
                    label: 'Nouveau versement',
                  ),
                  SpeedDialChild(
                    backgroundColor: primaryColor,
                    child: Icon(
                      Icons.delivery_dining_outlined,
                      color: Colors.white,
                    ),
                    onTap: () {
                      PageNavigator(ctx: context).nextPage(
                          page: StorePage(
                        client: widget.client,
                      ));
                    },
                    label: 'Nouvelle livraison',
                  ),
                  SpeedDialChild(
                    backgroundColor: primaryColor,
                    child: Icon(
                      Icons.file_open_outlined,
                      color: Colors.white,
                    ),
                    onTap: () {
                      PageNavigator(ctx: context).nextPage(
                          page: StorePage(
                        client: widget.client,
                      ));
                    },
                    label: 'Nouveau devis / commande',
                  ),
                  SpeedDialChild(
                    backgroundColor: primaryColor,
                    child: Icon(
                      Icons.contact_phone_sharp,
                      color: Colors.white,
                    ),
                    onTap: () {
                      PageNavigator(ctx: context).nextPage(
                          page: AddNewContactPage(
                            client: widget.client,
                          )).then((value){
                        setState(() {

                        });
                      });
                    },
                    label: 'Nouveau contact',
                  ),
                  SpeedDialChild(
                    backgroundColor: primaryColor,
                    child: Icon(
                      Icons.local_activity_outlined,
                      color: Colors.white,
                    ),
                    onTap: () async {
                      await fetchDataProcesses();
                      await fetchDataTypes();
                      PageNavigator(ctx: context).nextPage(
                          page: AddActivityPage(
                        client: widget.client,
                        callback: () {
                          setState(() {});
                        },
                        allTypes: allTypes,
                        allProcesses: allProcesses,
                      ));
                    },
                    label: 'Nouvelle activité',
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                '${widget.client.name!}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3!
                                    .copyWith(color: txtColor),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Center(
                              child: Text('Ville : ${widget.client.city}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .copyWith(color: Colors.grey)),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Center(
                              child: Text(
                                '${AppUrl.formatter.format(widget.client.totalPay)} DZD',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .copyWith(
                                    color: color,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),

                            SizedBox(
                              height: 15,
                            ),
                            (widget.client.phone != null)
                            ?
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [

                                    Text(widget.client.phone!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3!
                                            .copyWith(
                                                fontStyle: FontStyle.italic,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.normal)),
                                IconButton(
                                    onPressed: () {
                                      if (widget.client.phone != null)
                                        PhoneUtils().makePhoneCall(
                                            widget.client.phone!);
                                      else
                                        _showAlertDialog(context,
                                            'Aucun numéro de téléphone pour ce client');
                                    },
                                    icon: Icon(
                                      Icons.call,
                                      color: primaryColor,
                                    )),
                                IconButton(
                                    onPressed: () {
                                      if (widget.client.phone != null)
                                        PhoneUtils()
                                            .makeSms(widget.client.phone!);
                                      else
                                        _showAlertDialog(context,
                                            'Aucun numéro de téléphone pour ce client');
                                    },
                                    icon: Icon(
                                      Icons.mail_outline,
                                      color: Colors.lightBlue,
                                    )),
                              ],
                            ) : Container(),
                            SizedBox(
                              height: 15,
                            ),
                            (widget.client.phone2 != null && widget.client.phone2 != '' )
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                          Text(widget.client.phone2!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline3!
                                                  .copyWith(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                      IconButton(
                                          onPressed: () {
                                            if (widget.client.phone2 != null)
                                              PhoneUtils().makePhoneCall(
                                                  widget.client.phone2!);
                                            else
                                              _showAlertDialog(context,
                                                  'Aucun numéro de téléphone pour ce client');
                                          },
                                          icon: Icon(
                                            Icons.call,
                                            color: primaryColor,
                                          )),
                                      IconButton(
                                          onPressed: () {
                                            if (widget.client.phone2 != null)
                                              PhoneUtils().makeSms(
                                                  widget.client.phone2!);
                                            else
                                              _showAlertDialog(context,
                                                  'Aucun numéro de téléphone pour ce client');
                                          },
                                          icon: Icon(
                                            Icons.mail_outline,
                                            color: Colors.lightBlue,
                                          )),
                                    ],
                                  )
                                : Container(),
                            Divider(color: grey),
                            SizedBox(
                              height: 15,
                            ),
                            Center(
                              child: Row(
                                children: [
                                  Text(
                                    'Famille : ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(
                                            fontWeight: FontWeight.normal),
                                  ),
                                  (widget.client.familleId != null)
                                      ? Text(
                                          '${widget.client.familleId}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4!
                                              .copyWith(
                                                  fontWeight:
                                                      FontWeight.normal),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            Center(
                              child: Row(
                                children: [
                                  Text(
                                    'Sous Famille : ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(
                                            fontWeight: FontWeight.normal),
                                  ),
                                  (widget.client.sFamilleId != null)
                                      ? Text(
                                          '${widget.client.sFamilleId}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4!
                                              .copyWith(
                                                  fontWeight:
                                                      FontWeight.normal),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Center(
                              child: Row(
                                children: [
                                  Text(
                                    'Région : ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(
                                            fontWeight: FontWeight.normal),
                                  ),
                                  (widget.client.region != null)
                                      ? Text(
                                          '${widget.client.region}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4!
                                              .copyWith(
                                                  fontWeight:
                                                      FontWeight.normal),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            Center(
                              child: Row(
                                children: [
                                  Text(
                                    'Secteur : ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(
                                            fontWeight: FontWeight.normal),
                                  ),
                                  (widget.client.sector != null)
                                      ? Text(
                                          '${widget.client.sector}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4!
                                              .copyWith(
                                                  fontWeight:
                                                      FontWeight.normal),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            Center(
                              child: Row(
                                children: [
                                  Text(
                                    'Rue : ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(
                                            fontWeight: FontWeight.normal),
                                  ),
                                  (widget.client.road != null)
                                      ? Text(
                                          '${widget.client.road}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4!
                                              .copyWith(
                                                  fontWeight:
                                                      FontWeight.normal),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Localisation: ',
                              style: TextStyle(fontSize: 15),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                (widget.client.location != null)
                                    ? Text(
                                        '${widget.client.location!.latitude.toStringAsFixed(4)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3!
                                            .copyWith(
                                                fontWeight: FontWeight.normal),
                                      )
                                    : Container(),
                                (widget.client.location != null)
                                    ? Text(
                                        '${widget.client.location!.longitude.toStringAsFixed(4)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3!
                                            .copyWith(
                                                fontWeight: FontWeight.normal),
                                      )
                                    : Container(),
                                IconButton(
                                    onPressed: () {
                                      if (widget.client.location != null &&
                                          currentLocation != null) {
                                        // 36.784705, 3.058636
                                        //widget.client.location = LatLng(36.784705,  3.058636);
                                        String url =
                                            'https://www.google.com/maps/dir/?api=1&origin=${currentLocation!.latitude},${currentLocation!.longitude}&destination=${widget.client.location!.latitude},${widget.client.location!.longitude}';
                                        print('urlIS: ${url}');
                                        PageNavigator(ctx: context).nextPage(
                                            page: GoogleMapPage(url: url));
                                      } else {
                                        showAlertDialog(context,
                                            ('Pas de localisation pour ce tier'));
                                      }
                                    },
                                    icon: Icon(
                                      Icons.location_on_outlined,
                                      color: primaryColor,
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Divider(color: grey),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Liste des contacts',
                                  style:
                                  Theme
                                      .of(context)
                                      .textTheme
                                      .headline4,
                                ),
                                IconButton(
                                  onPressed: (){
                                    PageNavigator(ctx: context).nextPage(
                                        page: ContactsPage(client: widget.client));
                                  },
                                  icon: Icon(Icons.contact_phone_outlined) ,
                                  //Icon(Icons.shopping_cart_outlined),
                                  color: primaryColor,
                                ),
                              ],
                            ),
                            Divider(color: grey),
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
                            primary: Colors.orange,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                        onPressed: () {
                          PageNavigator(ctx: context).nextPage(
                              page: EditClientPage(client: widget.client));
                        },
                        child: Text(
                          "Modifier",
                          style: TextStyle(color: Colors.white, fontSize: 18),
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
                          PageNavigator(ctx: context).nextPage(
                              page: ClientHistoryPage(client: widget.client));
                        },
                        child: Text(
                          "Afficher l'historique",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
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

  Future<void> fetchDataTypes() async {
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

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: primaryColor,
          ),
          Container(
              margin: EdgeInsets.only(left: 15), child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentLocation = LatLng(position.latitude, position.longitude);
      print('latLng: ${position.latitude} ${position.longitude}');
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void confirmationAndChangeState(
      BuildContext context, Client client, int value) {
    showLoaderDialog(context);
    try {
      changeOppState(client, value).then((value) {
        Navigator.pop(context);
        if (value) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else {
          showMessage(
              message: 'Échec de creation de l\'opportunité',
              context: context,
              color: Colors.red);
        }
      });
    } on SocketException catch (_) {
      print(":::: Internet connection is not available ");
      _showAlertDialog(context, 'Pas de connecxion !');
    }
  }

  Future<bool> changeOppState(Client client, int state) async {
    String url = AppUrl.opportunitiesChangeState + '${client.idOpp}/$state';
    print('res url $url');
    http.Response req = await http.put(Uri.parse(url),
        //body: body,
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
    print("res state code : ${req.statusCode} ");
    print("res state body: ${req.body}");
    if (req.statusCode == 200) {
      return true;
    } else {
      print('Failed to load data');
      return false;
    }
  }

  Future<void> fetchData() async {
    await _getCurrentLocation();
    String url = AppUrl.getRegion + '${widget.client.res['region']}';
    print('urlReg: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res region code : ${req.statusCode}");
    print("res region body: ${req.body}");
    if (req.statusCode == 200) {
      widget.client.region = json.decode(req.body)['nom'];
    }
    List<dynamic> data = widget.client.res['adress'];
    print('adresses : $data');
    if (data.length > 0) {
      var element = data.first;
      widget.client.road = element['rue'];
      req = await http.get(
          Uri.parse(AppUrl.getSecteur + '${element['secteur']}'),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
            "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
          });
      print("res sector code : ${req.statusCode}");
      print("res sector body: ${req.body}");
      if (req.statusCode == 200) {
        widget.client.sector = json.decode(req.body)['nom'];
      }
    }
  }
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
