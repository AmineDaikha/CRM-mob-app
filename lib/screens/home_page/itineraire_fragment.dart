import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/constants/utils.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/providers/clients_map_provider.dart';
import 'package:mobilino_app/screens/home_page/opportunity_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/widgets/dialog_opp_state.dart';
import 'package:mobilino_app/screens/notes_page/title_note_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'GoogleMapPage.dart';

class ItineraireFragment extends StatefulWidget {
  const ItineraireFragment({
    Key? key,
  }) : super(key: key);

  @override
  State<ItineraireFragment> createState() => _ItineraireFragmentState();
}

class _ItineraireFragmentState extends State<ItineraireFragment> {
  bool isVisible = false;
  double posCircle = 90;
  double posNavBar = -280;
  double layoutValue = 280;
  Icon? icon;
  bool isVisited = false;
  Widget? visitedPage;
  LatLng? currentLocation;
  final List<LatLng> routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    icon = Icon(
      Icons.keyboard_arrow_up_rounded,
      color: Colors.white,
      size: 35,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      visitedPage = ToVisit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //visitedPage!,
        visitedPage == null
            ? ToVisit() //Container(width: double.infinity, height: double.infinity, color: Colors.white,) // Display Widget1 if visitedPage is null
            : visitedPage!, // Display Widget2 otherwise
        Positioned(
          bottom: posNavBar,
          left: 0,
          right: 0,
          child: Stack(
            children: [
              Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: 25, bottom: 25, left: 20, right: 20),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Client A \n Visiter',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3!
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Switch(
                                  value: isVisited,
                                  onChanged: (_) {
                                    manageVisit();
                                  },
                                  activeColor: Colors.white,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    List<Client> clients = [];
                                    final provider =
                                        Provider.of<ClientsMapProvider>(context,
                                            listen: false);
                                    if (isVisited == false) {
                                      clients = provider.toVisitedClients;
                                    } else {
                                      clients = provider.visitedClients;
                                    }
                                    print(
                                        'provider list size: ${clients.length}');
                                    String url = '';
                                    showLoaderDialog(context);
                                    _getCurrentLocation().then((value) {
                                      Navigator.pop(context);
                                      if (currentLocation == null) {
                                      } else {
                                        url =
                                            'https://www.google.com/maps/dir/?api=1&origin=${currentLocation!.latitude},${currentLocation!.longitude}&destination=${clients.last.location!.latitude},${clients.last.location!.longitude}';
                                        String url1 =
                                            'https://www.google.com/maps/dir/?api=1&origin=36.7675962,3.7029002&destination=36.7343859,4.3667907&waypoints=36.752887,3.042048|36.7675962,3.7029002';
                                        if (clients.length > 1) {
                                          url = url + '&waypoints=';
                                          for (int i = 0;
                                              i < clients.length - 1;
                                              i++) {
                                            url = url +
                                                '${clients[i].location!.latitude},${clients[i].location!.longitude}';
                                            if (i != clients.length - 1)
                                              url = url + '|';
                                          }
                                        }

                                        print('urlIS: ${url}');
                                        PageNavigator(ctx: context).nextPage(
                                            page: GoogleMapPage(url: url));
                                      }
                                    });
                                  },
                                  child: Text(
                                    'Passer au Google Map',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // CustomSwitch(width: 100, value: false,  onChanged: (newValue) {
                          //   newValue = ! newValue;
                          // },),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Client Déjà \n Visités',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3!
                                  .copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          )
                        ],
                      ),
                    ),
                    //clientItem()
                    Expanded(
                        child: SizedBox(
                            child: Container(
                      color: Colors.white,
                      margin: EdgeInsets.only(top: 30),
                      height: 400,
                      child: Consumer<ClientsMapProvider>(
                          builder: (context, clients, child) {
                        if (isVisited) {
                          // visited list
                          if (clients.visitedClients.length == 0) {
                            return Center(
                              child: Text(
                                "pas de client !",
                                style: Theme.of(context).textTheme.headline2,
                              ),
                            );
                          }
                          return ListView.separated(
                              itemBuilder: (context, index) {
                                return clientItem(
                                    client: clients.visitedClients[index]);
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) => Divider(
                                        color: Colors.grey,
                                      ),
                              itemCount: clients.visitedClients.length);
                        } else {
                          if (clients.toVisitedClients.length == 0) {
                            return Center(
                              child: Text(
                                "pas de client !",
                                style: Theme.of(context).textTheme.headline2,
                              ),
                            );
                          }
                          return ListView.separated(
                              itemBuilder: (context, index) {
                                return clientItem(
                                    client: clients.toVisitedClients[index]);
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) => Divider(
                                        color: Colors.grey,
                                      ),
                              itemCount: clients.toVisitedClients.length);
                        }
                        ;
                      }),
                    )))
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
            bottom: posCircle,
            left: 0,
            right: 0,
            child: Align(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white, // Border color
                      width: 4.0, // Border width
                    ),
                  ),
                  height: 65,
                  width: 65,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                        onPressed: () {
                          setListVisibility();
                        },
                        icon: icon!),
                  ),
                ))),
      ],
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentLocation = LatLng(position.latitude, position.longitude);
      routeCoordinates.insert(0, currentLocation!);
      print('latLng: ${position.latitude} ${position.longitude}');
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void manageVisit() {
    setState(() {
      if (!isVisited) {
        isVisited = true;
        visitedPage = AlreadyVisited();
      } else {
        isVisited = false;
        visitedPage = ToVisit();
      }
    });
  }

  void setListVisibility() {
    //
    setState(() {
      if (!isVisible) {
        isVisible = true;
        posNavBar += layoutValue;
        posCircle += layoutValue;
        icon = Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.white,
          size: 35,
        );
      } else {
        isVisible = false;
        posNavBar -= layoutValue;
        posCircle -= layoutValue;
        icon = Icon(
          Icons.keyboard_arrow_up_rounded,
          color: Colors.white,
          size: 35,
        );
      }
    });
  }
}

class ToVisit extends StatefulWidget {
  const ToVisit({
    Key? key,
  }) : super(key: key);

  @override
  State<ToVisit> createState() => _ToVisitState();
}

class _ToVisitState extends State<ToVisit> {
  LatLng? currentLocation;
  final List<LatLng> routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    //provider.updateList();
    print('provider list size: ${provider.toVisitedClients.length}');
    for (Client client in provider.toVisitedClients) {
      routeCoordinates.add(client.location!);
    }
    print('routeCoordinates list size: ${routeCoordinates.length}');
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        routeCoordinates.insert(0, currentLocation!);
        print('latLng: ${position.latitude} ${position.longitude}');
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    final status = Permission.location.request();
    if (status.isGranted == false)
      return Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: Text(
          'Pas de permission pour utiliser la location',
          style: Theme.of(context).textTheme.bodyText1,
        )),
      );
    try {
      return Container(
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(
                (routeCoordinates.first.latitude +
                        routeCoordinates.last.latitude) /
                    2,
                (routeCoordinates.first.longitude +
                        routeCoordinates.last.longitude) /
                    2),
            zoom: 5.0,
          ),
          children: [
            TileLayer(
              tileProvider: NetworkTileProvider(),
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routeCoordinates,
                  strokeWidth: 4.0,
                  color: Colors.blue,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: routeCoordinates.first,
                  child: Icon(Icons.place, color: Colors.red),
                ),
                // Markers for waypoints
                for (int i = 1; i < routeCoordinates.length; i++)
                  Marker(
                    point: routeCoordinates[i],
                    child: GestureDetector(
                        onTap: () {
                          PageNavigator(ctx: context).nextPage(
                              page: OpportunityPage(
                                  client: provider.toVisitedClients[i - 1]));
                        },
                        child: Icon(Icons.place, color: Colors.orange)),
                  ),
                // Marker(
                //   point: routeCoordinates.last,
                //   child: Icon(
                //     Icons.place,
                //     color: Colors.orange,
                //   ),
                // ),
              ],
            ),
          ],
        ),
        // child: FlutterMap(
        //     options: MapOptions(
        //       center: routeCoordinates.last, // Center of San Francisco
        //       //center: LatLng(1.354474457244855, 1.849465150689236),
        //       zoom: 13.0, // Initial zoom level
        //     ),
        //     layers: [
        //   TileLayerOptions(
        //     urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        //     // OSM tile URL
        //     subdomains: ['a', 'b', 'c'], // Subdomains for load balancing
        //   ),
        //   PolylineLayerOptions(
        //     polylines: [
        //       Polyline(
        //         points: routeCoordinates,
        //         color: Colors.blue,
        //         strokeWidth: 3.0,
        //       ),
        //     ],
        //   ),
        //   MarkerLayerOptions(
        //     markers: routeCoordinates.asMap().entries.map((entry) {
        //       final index = entry.key;
        //       final latLng = entry.value;
        //       if (index == 0) {
        //         return Marker(
        //           width: 100.0,
        //           height: 40.0,
        //           point: latLng,
        //           builder: (context) => Column(
        //             children: [
        //               Text(
        //                 'Ma position',
        //                 style: Theme.of(context).textTheme.bodyText2,
        //               ),
        //               Icon(
        //                 Icons.location_on_outlined,
        //                 color: Colors.red, // Custom marker color
        //               ),
        //             ],
        //           ),
        //         );
        //       }
        //       String data = provider.toVisitedClients[index - 1].name!;
        //       print('index - 1 ${index - 1}');
        //       return Marker(
        //         width: 100.0,
        //         height: 40.0,
        //         point: latLng,
        //         builder: (context) => SingleChildScrollView(
        //           child: Column(
        //             children: [
        //               Text(
        //                 data!,
        //                 style: Theme.of(context).textTheme.bodyText2,
        //               ),
        //               Icon(
        //                 Icons.location_on_outlined,
        //                 color: primaryColor, // Custom marker color
        //               ),
        //             ],
        //           ),
        //         ),
        //       );
        //     }).toList(),
        //     // Marker(
        //     //   width: 40.0,
        //     //   height: 40.0,
        //     //   point: routeCoordinates.last,
        //     //   builder: (ctx) => Icon(
        //     //     Icons.location_on,
        //     //     color: Colors.green,
        //     //   ),
        //     // ),
        //   ),
        // ])
      );
    } catch (e) {
      print(e);
      // Future.delayed(Duration(seconds: 4), () {
      //   setState(() {});
      // });
    }
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      ),
    );
  }
}

class AlreadyVisited extends StatefulWidget {
  const AlreadyVisited({
    Key? key,
  }) : super(key: key);

  @override
  State<AlreadyVisited> createState() => _AlreadyVisitedState();
}

class _AlreadyVisitedState extends State<AlreadyVisited> {
  LatLng? currentLocation;
  final List<LatLng> routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    for (Client client in provider.visitedClients) {
      routeCoordinates.add(client.location!);
    }
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        routeCoordinates.insert(0, currentLocation!);
        print('latLng: ${position.latitude} ${position.longitude}');
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    final status = Permission.location.request();
    if (status.isGranted == false)
      return Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: Text(
          'Pas de permission pour utiliser la location',
          style: Theme.of(context).textTheme.bodyText1,
        )),
      );
    try {
      return Container(
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(
                (routeCoordinates.first.latitude +
                        routeCoordinates.last.latitude) /
                    2,
                (routeCoordinates.first.longitude +
                        routeCoordinates.last.longitude) /
                    2),
            zoom: 5.0,
          ),
          children: [
            TileLayer(
              tileProvider: NetworkTileProvider(),
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routeCoordinates,
                  strokeWidth: 4.0,
                  color: Colors.grey,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: routeCoordinates.first,
                  child: Icon(Icons.place, color: Colors.red),
                ),
                // Markers for waypoints
                for (int i = 1; i < routeCoordinates.length; i++)
                  Marker(
                    point: routeCoordinates[i],
                    child: GestureDetector(
                        onTap: () {
                          PageNavigator(ctx: context).nextPage(
                              page: OpportunityPage(
                                  client: provider.visitedClients[i - 1]));
                        },
                        child: Icon(Icons.place, color: Colors.blue)),
                  ),
                // Marker(
                //   point: routeCoordinates.last,
                //   child: Icon(
                //     Icons.place,
                //     color: Colors.red,
                //   ),
                // ),
              ],
            ),
          ],
        ),
        // child: FlutterMap(
        //     options: MapOptions(
        //       center: routeCoordinates.first, // Center of San Francisco
        //       //center: LatLng(1.354474457244855, 1.849465150689236),
        //       zoom: 13.0, // Initial zoom level
        //     ),
        //     layers: [
        //   TileLayerOptions(
        //     urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        //     // OSM tile URL
        //     subdomains: ['a', 'b', 'c'], // Subdomains for load balancing
        //   ),
        //   PolylineLayerOptions(
        //     polylines: [
        //       Polyline(
        //         points: routeCoordinates,
        //         color: Colors.grey,
        //         strokeWidth: 3.0,
        //       ),
        //     ],
        //   ),
        //   MarkerLayerOptions(
        //     markers: routeCoordinates.asMap().entries.map((entry) {
        //       final index = entry.key;
        //       final latLng = entry.value;
        //       if (index == 0) {
        //         return Marker(
        //           width: 100.0,
        //           height: 40.0,
        //           point: latLng,
        //           builder: (context) => Column(
        //             children: [
        //               Text(
        //                 'Ma position',
        //                 style: Theme.of(context).textTheme.bodyText2,
        //               ),
        //               Icon(
        //                 Icons.location_on_outlined,
        //                 color: Colors.red, // Custom marker color
        //               ),
        //             ],
        //           ),
        //         );
        //       }
        //       String data = provider.visitedClients[index - 1].name!;
        //       return Marker(
        //         width: 100.0,
        //         height: 40.0,
        //         point: latLng,
        //         builder: (context) => SingleChildScrollView(
        //           child: Column(
        //             children: [
        //               Text(
        //                 data!,
        //                 style: Theme.of(context).textTheme.bodyText2,
        //               ),
        //               Icon(
        //                 Icons.pin_drop_outlined,
        //                 color: primaryColor, // Custom marker color
        //               ),
        //             ],
        //           ),
        //         ),
        //       );
        //     }).toList(),
        //     // Marker(
        //     //   width: 40.0,
        //     //   height: 40.0,
        //     //   point: routeCoordinates.last,
        //     //   builder: (ctx) => Icon(
        //     //     Icons.location_on,
        //     //     color: Colors.green,
        //     //   ),
        //     // ),
        //   ),
        // ]
        // )
      );
    } catch (e) {
      print(e);
      Future.delayed(Duration(seconds: 3), () {
        setState(() {});
      });
    }

    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: Center(
          child: CircularProgressIndicator(
        color: primaryColor,
      )),
    );
  }
}

class clientItem extends StatelessWidget {
  final Client client;
  bool visibleMore = false;

  clientItem({
    super.key,
    required this.client,
  }) {
    //if (client.stat == 1) visibleMore = true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => PageNavigator(ctx: context)
          .nextPage(page: OpportunityPage(client: client)),
      child: ListTile(
        leading: Icon(Icons.location_on_outlined),
        title: Text(
          client.name!,
          style: Theme.of(context)
              .textTheme
              .headline4!
              .copyWith(color: Theme.of(context).primaryColor),
        ),
        subtitle: Text(
          client.city!,
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                onPressed: () {
                  if (client.phone != null)
                    PhoneUtils().makePhoneCall(client.phone!);
                  else
                    _showAlertDialog(
                        context, 'Aucun numéro de téléphone pour ce client');
                },
                icon: Icon(
                  Icons.call_outlined,
                  color: Colors.grey,
                )),
            IconButton(
                onPressed: () {
                  if (client.phone != null)
                    PhoneUtils().makeSms(client.phone!);
                  else
                    _showAlertDialog(
                        context, 'Aucun numéro de téléphone pour ce client');
                },
                icon: Icon(
                  Icons.mail_outline,
                  color: Colors.grey,
                )),
            Visibility(
              visible: visibleMore,
              child: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ChoiceDialog();
                      },
                    ).then((value) {
                      print('value of result choice: $value');
                      confirmationAndChangeState(context, value);
                    });
                  },
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                  )),
            )
          ],
        ),
      ),
    );
  }

  void confirmationAndChangeState(BuildContext context, int value) {
    showLoaderDialog(context);
    try {
      changeOppState(client, value).then((value) {
        Navigator.pop(context);
        if (value) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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
