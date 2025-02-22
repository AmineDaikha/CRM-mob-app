import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/constants/utils.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/providers/clients_map_provider.dart';
import 'package:mobilino_app/screens/clients_page/add_client_page1.dart';
import 'package:mobilino_app/screens/clients_page/client_history_page.dart';
import 'package:mobilino_app/screens/clients_page/edit_client_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/drawers/clients_drawer.dart';
import 'package:provider/provider.dart';

import 'client_page.dart';
import 'dialog_filtred_clients.dart';

class ClientsListPage extends StatefulWidget {
  const ClientsListPage({super.key});

  static const String routeName = '/clients';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => ClientsListPage(),
    );
  }

  @override
  State<ClientsListPage> createState() => _ClientsListPageState();
}

class _ClientsListPageState extends State<ClientsListPage> {
  bool isMap = false;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   try {
    //     showLoaderDialog(context);
    //     fetchData(context).then((value) {
    //       Navigator.pop(context);
    //     });
    //   } on SocketException catch (_) {
    //     _showAlertDialog(context, 'Pas de connecxion !');
    //   }
    // });
  }

  // Function to fetch JSON data from an API

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: null,
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
                      ' Veuillez réessayer ultérieurement. Merci'),
                ],
              ),
            );
          } else {
            final provider =
                Provider.of<ClientsMapProvider>(context, listen: false);
            provider.clientsList.sort((a, b) => a.name!.compareTo(b.name!));
            print('size is : ${provider.clientsList.length}');
            List<String> clients = [
              'John',
              'Alice',
              'Bob',
              // Add more clients as needed
            ];
            // Sorting clients by name in ascending order
            clients.sort((a, b) => a.compareTo(b));

            // Print the sorted list
            print(clients.map((client) => client).toList());
            return DefaultTabController(
              length: 3,
              child: Scaffold(
                  floatingActionButton: FloatingActionButton(
                    backgroundColor: primaryColor,
                    onPressed: () {
                      Navigator.pushNamed(context, AddClientPage1.routeName);
                    },
                    child: Icon(
                      Icons.person_add_alt,
                      color: Colors.white,
                    ),
                  ),
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(100),
                    child: AppBar(
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(20.0),
                        // Adjust this as needed
                        child: Container(
                          color: Colors.white,
                          child: TabBar(
                              //isScrollable: true,
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Theme.of(context).primaryColor),
                              labelColor: Theme.of(context).primaryColor,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Theme.of(context).primaryColor,
                              indicator: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                width: 2.5,
                                color: Theme.of(context).primaryColor,
                              ))),
                              tabs: [
                                Tab(
                                  text: 'Prospects',
                                ),
                                Tab(
                                  text: 'Clients',
                                ),
                                Tab(
                                  text: 'Fournisseurs',
                                ),
                              ]),
                        ),
                      ),
                      iconTheme: IconThemeData(
                        color: Colors.white, // Set icon color to white
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      title: Text(
                        'Prospects / Clients',
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      actions: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                isMap = !isMap;
                              });
                            },
                            icon: (isMap)
                                ? Icon(
                                    Icons.list_alt_outlined,
                                    color: Colors.white,
                                  )
                                : Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.white,
                                  )),
                        IconButton(
                          icon: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            showSearch(
                                context: context,
                                delegate: ClientSearchDelegate(),
                                query: '');
                          },
                        ),
                        IconButton(
                            onPressed: () {
                              //_showDatePicker(context);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return FiltredClientDialog();
                                },
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            icon: Icon(
                              Icons.sort,
                              color: Colors.white,
                            ))
                      ],
                    ),
                  ),
                  drawer: DrawerClientsListPage(),
                  body: (isMap)
                      ? ViewMap()
                      : TabBarView(
                          children: [
                            ViewList(type: 'P'),
                            ViewList(type: 'C'),
                            ViewList(type: 'F'),
                          ],
                        )),
            );
          }
        });
  }
}

class ViewMap extends StatelessWidget {
  const ViewMap({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientsMapProvider>(builder: (context, clients, child) {
      return FlutterMap(
        options: MapOptions(
          center: (clients.clientsList.length > 0)
              ? LatLng(clients.clientsList.first.location!.latitude,
                  clients.clientsList.first.location!.longitude)
              : LatLng(1.354474457244855, 1.849465150689236),
          zoom: 5.0,
        ),
        children: [
          TileLayer(
            tileProvider: NetworkTileProvider(),
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(
            markers: [
              // Markers for waypoints
              for (int i = 0; i < clients.clientsList.length; i++)
                Marker(
                  point: clients.clientsList[i].location!,
                  child: (clients.clientsList[i].type == 'P')
                      ? Stack(
                        children: [
                          Text('${clients.clientsList[i].name}'),
                          IconButton(
                              onPressed: () {
                                PageNavigator(ctx: context).nextPage(
                                    page: ClientHistoryPage(
                                  client: clients.clientsList[i],
                                ));
                              },
                              icon: Icon(Icons.place_outlined,
                                  color: primaryColor)),
                        ],
                      )
                      : (clients.clientsList[i].type == 'C')
                          ? Stack(
                            children: [
                              Text('${clients.clientsList[i].name}'),
                              IconButton(
                                  onPressed: () {
                                    PageNavigator(ctx: context).nextPage(
                                        page: ClientHistoryPage(
                                      client: clients.clientsList[i],
                                    ));
                                  },
                                  icon: Icon(Icons.place_outlined,
                                      color: Colors.blue)),
                            ],
                          )
                          : Stack(
                            children: [
                              Text('${clients.clientsList[i].name}'),
                              IconButton(
                                  onPressed: () {
                                    PageNavigator(ctx: context).nextPage(
                                        page: ClientHistoryPage(
                                      client: clients.clientsList[i],
                                    ));
                                  },
                                  icon: Icon(Icons.place_outlined,
                                      color: Colors.red)),
                            ],
                          ),
                ),
            ],
          ),
        ],
      );
    });
  }
}

class ViewList extends StatefulWidget {
  final String type;

  const ViewList({super.key, required this.type});

  @override
  State<ViewList> createState() => _ViewListState();
}

class _ViewListState extends State<ViewList> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Attach the scroll controller to the ListView
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
      AppUrl.filtredClient.first = true;
      showLoaderDialog(context);
      fetchData(context, widget.type).then((value) {
        Navigator.pop(context);
      });
    }
  }

  int PageNumber = 0;

  Future<void> fetchData(BuildContext context, String type) async {
    PageNumber++;
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    if (PageNumber == 1) provider.clientsList = [];
    String url = '';
    url =
        '${AppUrl.tiersPage}?etbCode=${AppUrl.user.etblssmnt!.code}&PageNumber=$PageNumber&PageSize=10&type=$type';
    if (AppUrl.filtredClient.selectedSFamilly != null) {
      if (AppUrl.filtredClient.selectedSFamilly!.code != '-1') {
        url =
            '${AppUrl.tiersPage}?etbCode=${AppUrl.user.etblssmnt!.code}&PageNumber=$PageNumber&PageSize=10&type=$type&famille=${AppUrl.filtredClient.selectedFamilly!.code}&sFamille=${AppUrl.filtredClient.selectedSFamilly!.code}';
      } else {
        if (AppUrl.filtredClient.selectedFamilly != null) {
          if (AppUrl.filtredClient.selectedFamilly!.code != '-1') {
            url =
                '${AppUrl.tiersPage}?etbCode=${AppUrl.user.etblssmnt!.code}&PageNumber=$PageNumber&PageSize=10&type=$type&famille=${AppUrl.filtredClient.selectedFamilly!.code}';
          }
        }
      }
    } else {
      if (AppUrl.filtredClient.selectedFamilly != null) {
        if (AppUrl.filtredClient.selectedFamilly!.code != '-1') {
          url =
              '${AppUrl.tiersPage}?etbCode=${AppUrl.user.etblssmnt!.code}&PageNumber=$PageNumber&PageSize=10&type=$type&famille=${AppUrl.filtredClient.selectedFamilly!.code}';
        }
      }
    }
    print('url getClients: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res client code : ${req.statusCode}");
    print("res client body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      print('length ${data.length}');
      for (int i = 0; i < data.toList().length; i++) {
        var element = data.toList()[i];
        print('code client:  ${element['code']} ${element['etbCode']}');
        req = await http.get(
            Uri.parse(AppUrl.tiersEcheance +
                '${AppUrl.user.etblssmnt!.code}/${element['code']}'),
            headers: {
              "Accept": "application/json",
              "content-type": "application/json; charset=UTF-8",
              "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
            });
        print("res total code : ${req.statusCode}");
        print("res total body: ${req.body}");
        if (req.statusCode == 200) {
          double total = 0;
          List<dynamic> echeances = json.decode(req.body);
          echeances.toList().forEach((ech) {
            if (ech['echArecev'] != null && ech['echRecu'] != null) {
              total = total + ech['echArecev'] - ech['echRecu'];
            }
          });
          LatLng? latLng;
          if (element['longitude'] == null || element['latitude'] == null) {
            latLng = LatLng(1.354474457244855, 1.849465150689236);
          } else {
            try {
              latLng = LatLng(element['latitude'], element['longitude']);
            } catch (e) {
              print('latlong err: $e');
              latLng = LatLng(1.354474457244855, 1.849465150689236);
            }
          }
          String? familleId = element['familleId'];
          String? sFamilleId = element['sFamilleId'];
          print('TiersFams: ${element['familleId']} ${element['sFamilleId']}');
          if (familleId != null) {
            req = await http
                .get(Uri.parse(AppUrl.getFamilly + '$familleId'), headers: {
              "Accept": "application/json",
              "content-type": "application/json; charset=UTF-8",
              "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
            });
            print("res familleId code : ${req.statusCode}");
            print("res familleId body: ${req.body}");
            if (req.statusCode == 200) {
              print('ddd: ${json.decode(req.body)['lib']}');
              familleId = json.decode(req.body)['lib'];
            }
          }

          if (sFamilleId != null) {
            req = await http
                .get(Uri.parse(AppUrl.getSFamilly + '$sFamilleId'), headers: {
              "Accept": "application/json",
              "content-type": "application/json; charset=UTF-8",
              "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
            });
            print("res sfamilleId code : ${req.statusCode}");
            print("res sfamilleId body: ${req.body}");
            if (req.statusCode == 200) {
              sFamilleId = json.decode(req.body)['lib'];
            }
          }
          print('TiersFams!!: $familleId $sFamilleId');
          provider.clientsList.add(Client(
              name: element['rs'],
              res: element,
              totalPay: total,
              location: latLng,
              familleId: familleId,
              sFamilleId: sFamilleId,
              type: element['type'],
              email: element['email'],
              name2: element['rs2'],
              phone: element['tel1'],
              phone2: element['tel2'],
              city: element['ville'],
              id: element['code']));
        }
        provider.notifyListeners();
      }
    }
    print('size is : ${provider.clientsList.length}');
    provider.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchData(context, widget.type),
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
                      ' Veuillez réessayer ultérieurement. Merci'),
                ],
              ),
            );
          }
          return Consumer<ClientsMapProvider>(
              builder: (context, clients, child) {
            String tiers = '';
            if (widget.type == 'P')
              tiers = 'prospect';
            else if (widget.type == 'C')
              tiers = 'client';
            else if (widget.type == 'F') tiers = 'fournisseur';
            List<Client> clientList = clients.clientsList
                .where((element) => element.type == widget.type)
                .toList();
            return (clientList.isEmpty)
                ? Center(
                    child: Text(
                      'Aucun $tiers !',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(12),
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) => ClientItem(
                          client: clientList[index],
                        ),
                    // separatorBuilder: (BuildContext context, int index) {
                    //   return Divider(
                    //     color: Colors.grey,
                    //   );
                    // },
                    itemCount: clientList.length);
          });
        });
  }
}

class ClientItem extends StatelessWidget {
  final Client client;

  const ClientItem({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    Color txtColor = primaryColor;
    if (client.type == 'C') txtColor = Colors.blue;
    if (client.type == 'F') txtColor = Colors.red;
    if (client.totalPay! > 0) {
      color = primaryColor;
    } else if (client.totalPay! < 0) {
      color = Colors.red;
    }
    return InkWell(
      onLongPress: () {
        PageNavigator(ctx: context).nextPage(
            page: EditClientPage(
          client: client,
        ));
      },
      onTap: () {
        PageNavigator(ctx: context).nextPage(
            page: ClientPage(
          client: client,
        ));
      },
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.person_pin_rounded,
                  color: primaryColor,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        '${client.name}',
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(color: txtColor),
                      ),
                    ),
                    Text('${client.city}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(color: Colors.grey)),
                  ],
                ),
                Text(
                  '${AppUrl.formatter.format(client.totalPay)} DZD',
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(color: color, fontWeight: FontWeight.normal),
                ),
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          onPressed: () {
                            if (client.phone != null)
                              PhoneUtils().makePhoneCall(client.phone!);
                            else
                              showAlertDialog(context,
                                  'Aucun numéro de téléphone pour ce client');
                          },
                          icon: Icon(
                            Icons.call_outlined,
                            color: Colors.grey,
                            size: 20,
                          )),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: IconButton(
                          onPressed: () {
                            if (client.phone != null)
                              PhoneUtils().makeSms(client.phone!);
                            else
                              showAlertDialog(context,
                                  'Aucun numéro de téléphone pour ce client');
                          },
                          icon: Icon(
                            Icons.mail_outline,
                            color: Colors.grey,
                            size: 20,
                          )),
                    )
                  ],
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey,
          )
        ],
      ),
    );
  }
}

class ClientSearchDelegate extends SearchDelegate {
  // final Client client;
  // final VoidCallback callback;

  ClientSearchDelegate();

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
            onPressed: () {
              if (query.isNotEmpty)
                query = '';
              else
                close(context, null);
            },
            icon: Icon(Icons.clear))
      ];

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.filtredClients = [];
    return FutureBuilder(
      future: fetchData(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Future is still running, return a loading indicator or some placeholder.
          return AlertDialog(
            content: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircularProgressIndicator(
                  color: primaryColor,
                ),
                SizedBox(
                  width: 30,
                ),
                Text("Loading..."),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          // There was an error in the future, handle it.
          print('Error: ${snapshot.hasError} ${snapshot.error} ');
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
                    ' Veuillez réessayer ultérieurement. Merci'),
              ],
            ),
          );
        } else {
          List<Client> list = [];
          for (Client client in provider.filtredClients) {
            try {
              if (client.name!.toLowerCase().contains(query.toLowerCase()) ||
                  client.phone!.toLowerCase().contains(query.toLowerCase()) ||
                  client.total!.toLowerCase().contains(query.toLowerCase()) ||
                  client.city!.toLowerCase().contains(query.toLowerCase())) {
                list.add(client);
              }
            } catch (_) {
              continue;
            }
          }
          Set<Client> uniqueClientSet = list.toSet();
          List<Client> uniqueClientList = uniqueClientSet.toList();
          if (uniqueClientList.isEmpty)
            return Center(
              child: Text(
                'Aucune résultat !',
                style: Theme.of(context).textTheme.headline2,
              ),
            );
          else
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) => ClientItem(
                        client: uniqueClientList[index],
                      ),
                  itemCount: uniqueClientList.length),
            );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.filtredClients = [];
    return FutureBuilder(
      future: fetchData(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Future is still running, return a loading indicator or some placeholder.
          return AlertDialog(
            content: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircularProgressIndicator(
                  color: primaryColor,
                ),
                SizedBox(
                  width: 30,
                ),
                Text("Loading..."),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          // There was an error in the future, handle it.
          print('Error: ${snapshot.hasError} ${snapshot.error} ');
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
                    ' Veuillez réessayer ultérieurement. Merci'),
              ],
            ),
          );
        } else {
          List<Client> list = [];
          for (Client client in provider.filtredClients) {
            try {
              if (client.name!.toLowerCase().contains(query.toLowerCase()) ||
                  client.phone!.toLowerCase().contains(query.toLowerCase()) ||
                  client.total!.toLowerCase().contains(query.toLowerCase()) ||
                  client.city!.toLowerCase().contains(query.toLowerCase())) {
                list.add(client);
              }
            } catch (_) {
              continue;
            }
          }
          // provider.filtredClients.toList().forEach((client) {
          //
          // });
          // list = provider.filtredClients
          //     .toList()
          //     .where((client) =>
          //         client.name!.toLowerCase().contains(query.toLowerCase()) ||
          //         client.phone!.toLowerCase().contains(query.toLowerCase()) ||
          //         client.total!.toLowerCase().contains(query.toLowerCase()) ||
          //         client.city!.toLowerCase().contains(query.toLowerCase()))
          //     .toList();
          Set<Client> uniqueClientSet = list.toSet();
          List<Client> uniqueClientList = uniqueClientSet.toList();
          print('set: ${uniqueClientList.length}');
          if (uniqueClientList.isEmpty)
            return Center(
              child: Text(
                'Aucune résultat !',
                style: Theme.of(context).textTheme.headline2,
              ),
            );
          else
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) => ClientItem(
                        client: uniqueClientList[index],
                      ),
                  itemCount: uniqueClientList.length),
            );
        }
      },
    );
  }

  // Function to fetch JSON data from an API
  Future<void> fetchData(BuildContext context) async {
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.filtredClients = [];
    http.Response req = await http.get(
        Uri.parse(AppUrl.tiersPage + '?PageNumber=1&rs=$query&PageSize=10'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
    print("res tiers code : ${req.statusCode}");
    print("res tiers body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      for (int i = 0; i < data.toList().length; i++) {
        var element = data.toList()[i];
        print('code client:  ${element['code']}');
        req = await http.get(
            Uri.parse(AppUrl.tiersEcheance +
                '${AppUrl.user.etblssmnt!.code}/${element['code']}'),
            headers: {
              "Accept": "application/json",
              "content-type": "application/json; charset=UTF-8",
              "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
            });
        print("res total code : ${req.statusCode}");
        print("res total body: ${req.body}");
        if (req.statusCode == 200) {
          double total = 0;
          List<dynamic> echeances = json.decode(req.body);
          echeances.toList().forEach((ech) {
            total = total + ech['echArecev'] - ech['echRecu'];
            print('ech: ${ech['echArecev']}');
          });
          LatLng? latLng;
          if (element['longitude'] == null || element['latitude'] == null) {
            latLng = LatLng(1.354474457244855, 1.849465150689236);
          } else {
            try {
              latLng = LatLng(element['latitude'], element['longitude']);
            } catch (_) {
              latLng = LatLng(1.354474457244855, 1.849465150689236);
            }
          }

          String? familleId = element['familleId'];
          String? sFamilleId = element['sFamilleId'];
          print('TiersFams: ${element['familleId']} ${element['sFamilleId']}');
          if (familleId != null) {
            req = await http
                .get(Uri.parse(AppUrl.getFamilly + '$familleId'), headers: {
              "Accept": "application/json",
              "content-type": "application/json; charset=UTF-8",
              "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
            });
            print("res familleId code : ${req.statusCode}");
            print("res familleId body: ${req.body}");
            if (req.statusCode == 200) {
              print('ddd: ${json.decode(req.body)['lib']}');
              familleId = json.decode(req.body)['lib'];
            }
          }

          if (sFamilleId != null) {
            req = await http
                .get(Uri.parse(AppUrl.getSFamilly + '$sFamilleId'), headers: {
              "Accept": "application/json",
              "content-type": "application/json; charset=UTF-8",
              "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
            });
            print("res sfamilleId code : ${req.statusCode}");
            print("res sfamilleId body: ${req.body}");
            if (req.statusCode == 200) {
              sFamilleId = json.decode(req.body)['lib'];
            }
          }
          print('TiersFams!!: $familleId $sFamilleId');
          provider.filtredClients.add(Client(
              name: element['rs'],
              res: element,
              totalPay: total,
              location: latLng,
              familleId: familleId,
              sFamilleId: sFamilleId,
              type: element['type'],
              email: element['email'],
              name2: element['rs2'],
              phone: element['tel1'],
              phone2: element['tel2'],
              city: element['ville'],
              id: element['code']));
          //provider.notifyListeners();
        }
      }
    }
    provider.notifyListeners();
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
