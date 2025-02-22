import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/constants/utils.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/salon.dart';
import 'package:mobilino_app/models/step_pip.dart';

import 'package:mobilino_app/models/type_activity.dart';
import 'package:mobilino_app/providers/salon_provider.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/drawers/marketing_drawer.dart';
import 'package:provider/provider.dart';
import 'dialog_filtred_salons.dart';
import 'salon_page.dart';

class SalonListPage extends StatefulWidget {
  const SalonListPage({super.key});

  static const String routeName = '/salon';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => SalonListPage(),
    );
  }

  @override
  State<SalonListPage> createState() => _SalonListPageState();
}

class _SalonListPageState extends State<SalonListPage> {
  @override
  initState() {
    super.initState();
    AppUrl.filtredCommandsClient.clients = [Client(id: '-1', name: 'Tout')];
    AppUrl.filtredCommandsClient.client =
        AppUrl.filtredCommandsClient.clients.first;
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   showLoaderDialog(context);
    //   _fetchData(context).then((value) {
    //     Navigator.pop(context);
    //   });
    // });
  }

  Future<bool> getSalonSteps() async {
    // for rights
    try {
      AppUrl.filtredCommandsClient.salonSteps.clear();
      String url = AppUrl.getPipelinesSteps + '5';
      http.Response req = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/",
        'Authorization': 'Bearer ${AppUrl.user.token}',
      });
      print("res salonSteps code is : ${req.statusCode}");
      print("res salonSteps body: ${req.body}");
      List<dynamic> steps = json.decode(req.body);
      steps.forEach((step) {
        AppUrl.filtredCommandsClient.salonSteps.add(StepPip(
          id: step['id'],
          name: step['libelle'],
          color: '',
        ));
      });
      // AppUrl.filtredCommandsClient.stepPipSalon =
      //     AppUrl.filtredCommandsClient.salonSteps.first;
    } catch (e) {
      print(e);
    }
    return true;
  }

  Future<void> fetchDataTypeProject() async {
    String url = AppUrl.getTypesProject;
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res typeProject code : ${req.statusCode}");
    print("res typeProject body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      //activitiesProcesses[process] = types;
      data.toList().forEach((element) {
        AppUrl.user.typeProject.add(TypeActivity(
          id: element['id'],
          code: element['code'],
          name: element['lib'],
        ));
      });
      //activitiesProcesses[process] = types;
    }
  }

  Future<void> fetchData() async {
    //print('image: ${AppUrl.baseUrl}${AppUrl.user.image}');
    //await fetchDataTypeProject();
    await getSalonSteps();
    final provider = Provider.of<SalonProvider>(context, listen: false);
    provider.salonList.clear();
    String url = '';
    try {
      if (AppUrl.filtredCommandsClient.stepPipSalon!.id == -1)
        url = AppUrl.getAllSalon +
            '?dateDebut=${DateFormat('yyyy-MM-ddT00:00:00').format(AppUrl.filtredCommandsClient.date)}&dateFin=${DateFormat('yyyy-MM-ddT23:59:59').format(AppUrl.filtredCommandsClient.dateEnd)}&salCode=${AppUrl.user.salCode}&etbCode=${AppUrl.user.etblssmnt!.code}';
      else
        url = AppUrl.getAllSalon +
            '?dateDebut=${DateFormat('yyyy-MM-ddT00:00:00').format(AppUrl.filtredCommandsClient.date)}&dateFin=${DateFormat('yyyy-MM-ddT23:59:59').format(AppUrl.filtredCommandsClient.dateEnd)}&salCode=${AppUrl.user.salCode}&etbCode=${AppUrl.user.etblssmnt!.code}&etape=${AppUrl.filtredCommandsClient.stepPipSalon!.id}';
    } catch (e) {
      url = AppUrl.getAllSalon +
          '?dateDebut=${DateFormat('yyyy-MM-ddT00:00:00').format(AppUrl.filtredCommandsClient.date)}&dateFin=${DateFormat('yyyy-MM-ddT23:59:59').format(AppUrl.filtredCommandsClient.dateEnd)}&salCode=${AppUrl.user.salCode}&etbCode=${AppUrl.user.etblssmnt!.code}';
    }
    print('url : $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res allSalons code : ${req.statusCode}");
    print("res allSalons body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      List<dynamic> data = json.decode(req.body);
      print('nbSalon: ${data.length}');
      //data.forEach((element) {
      for (int i = 0; i < data.length; i++) {
        var element = data[i];
        var elementClient = data[i]['tiers'];
        print('état : ${element['etat']}');
        Client client =
            Client(id: elementClient['pcfCode'], name: elementClient['rs']);
        int idStep = element['etat'];
        print('état222 : ${AppUrl.filtredCommandsClient.salonSteps.length}');
        String status = element['etape']['libelle'];
        // String status = AppUrl.filtredCommandsClient.salonSteps
        //     .where((element) {
        //       print('étatPip  : ${element.id}');
        //       return element.id == idStep;
        //     })
        //     .first
        //     .name;
        Salon salon = Salon(
            res: element,
            object: element['libelle'],
            client: client,
            code: element['code'],
            stat: element['etat'],
            status: status,
            endDate: DateTime.parse(element['dateFin']),
            startDate: DateTime.parse(element['dateDebut']));
        provider.salonList.add(salon);

        //});}
      }
      print('sizeIS: ${provider.salonList.length}');
      provider.notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    PageNavigator page = PageNavigator(ctx: context);
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
          }
          // else if (snapshot.hasError) {
          //   // There was an error in the future, handle it.
          //   print('Error: ${snapshot.hasError} ${snapshot.error} ');
          //   return AlertDialog(
          //     content: Row(
          //       //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Icon(
          //           Icons.error_outline,
          //           color: Colors.red,
          //         ),
          //         SizedBox(
          //           width: 30,
          //         ),
          //         // Text('Error: ${snapshot.error}')
          //         Expanded(
          //           child: Text(
          //               'Nous sommes désolé, la qualité de votre connexion ne vous permet pas de vous connecter à votre serveur.'
          //               ' Veuillez réessayer ultérieurement. Merci'),
          //         ),
          //       ],
          //     ),
          //   );
          // }
          else
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                  drawer: DrawerMarketingPage(
                    selectedItemIndex: 0,
                  ),
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(100),
                    child: AppBar(
                      iconTheme: IconThemeData(
                        color: Colors.white, // Set icon color to white
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Foires et Salons',
                            style: Theme.of(context)
                                .textTheme
                                .headline3!
                                .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Du : ${DateFormat('dd-MM-yyyy').format(AppUrl.filtredCommandsClient.date)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Au : ${DateFormat('dd-MM-yyyy').format(AppUrl.filtredCommandsClient.dateEnd)}, de : ${AppUrl.filtredCommandsClient.collaborateur!.userName}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Pipeline : Salons & Foires',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(20.0),
                        // Adjust this as needed
                        child: Container(
                          color: Colors.white,
                          child: TabBar(
                              //isScrollable: true,
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
                                  text: 'Pipeline',
                                  //icon: Icon(Icons.bar_chart),
                                ),
                                Tab(
                                  text: 'Liste',
                                  //icon: Icon(Icons.list),
                                ),
                              ]),
                        ),
                      ),
                      backgroundColor: primaryColor,
                      actions: [
                        IconButton(
                            onPressed: () {
                              //_showDatePicker(context);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return FiltredSalonsDialog();
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
                  body: TabBarView(
                    children: [
                      PipelineSalonFragment(),
                      ListSalonFragment(),
                    ],
                  )),
            );
        });
  }
}

class PipelineSalonFragment extends StatefulWidget {
  const PipelineSalonFragment({
    super.key,
  });

  @override
  State<PipelineSalonFragment> createState() => _PipelineSalonFragmentState();
}

class _PipelineSalonFragmentState extends State<PipelineSalonFragment> {
  int selectedItemIndex = 0; // Index of the selected item

  @override
  Widget build(BuildContext context) {
    print('fffff: $selectedItemIndex');
    return Column(
      children: [
        Container(
          height: 50.0, // Adjust the height of the container
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppUrl.filtredCommandsClient.salonSteps.length,
            // Number of items
            itemBuilder: (context, index) {
              return Consumer<SalonProvider>(
                  builder: (context, provider, snapshot) {
                List<Salon> salonList = [];
                if (provider.salonList.length > 0) {
                  print(
                      'zzzzzzz: ${provider.salonList.first.stat} index: ${index + 1}');
                }
                salonList = provider.getSalonByStat(
                    index + AppUrl.filtredCommandsClient.salonSteps.first.id);
                return GestureDetector(
                  onTap: () {
                    // Handle item tap
                    setState(() {
                      selectedItemIndex = index;
                    });
                  },
                  child: Container(
                    width: 120.0,
                    // Adjust the width of each item
                    margin: EdgeInsets.all(8.0),
                    decoration: selectedItemIndex == index
                        ? BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                            width: 2.5,
                            color: Theme.of(context).primaryColor,
                          )))
                        : BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                            width: 2.5,
                            color: Colors.transparent,
                          ))),
                    // color: selectedItemIndex == index
                    //     ? Colors.blue // Color when item is selected
                    //     : Colors.grey,
                    // Default color
                    child: Center(
                      child: Text(
                        '${AppUrl.filtredCommandsClient.salonSteps[index].name} (${salonList.length})',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
        SizedBox(height: 20.0),
        selectedItemIndex != -1
            ? Consumer<SalonProvider>(
                builder: (context, salonProvider, snapshot) {
                if (salonProvider.salonList.length == 0)
                  return Expanded(
                    child: Center(
                        child: Text(
                      'Aucun salon / foire !',
                      style: Theme.of(context).textTheme.headline3,
                    )),
                  );
                else {
                  List<Salon> salonList = salonProvider.getSalonByStat(
                      selectedItemIndex +
                          AppUrl.filtredCommandsClient.salonSteps.first.id);
                  print(
                      'sizePro : ${salonList.length}  ${AppUrl.filtredCommandsClient.salonSteps.length}  ${AppUrl.filtredCommandsClient.salonSteps.first.id}  ${selectedItemIndex}');
                  return Expanded(
                    child: (salonList.isEmpty)
                        ? Center(
                            child: Text(
                            'Aucun foire / salon !',
                            style: Theme.of(context).textTheme.headline3,
                          ))
                        : ListView.builder(
                            padding: EdgeInsets.all(12),
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) =>
                                SalonItem(salon: salonList[index]),
                            // separatorBuilder: (BuildContext context, int index) {
                            //   return Divider(
                            //     color: Colors.grey,
                            //   );
                            // },
                            itemCount: salonProvider.salonList.length),
                  );
                }
              })
            : Container(),
      ],
    );
  }
}

class ListSalonFragment extends StatefulWidget {
  const ListSalonFragment({
    super.key,
  });

  @override
  State<ListSalonFragment> createState() => _ListSalonFragmentState();
}

class _ListSalonFragmentState extends State<ListSalonFragment> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<SalonProvider>(builder: (context, salonProvider, snapshot) {
          if (salonProvider.salonList.length == 0)
            return Expanded(
              child: Center(
                  child: Text(
                'Aucun salon / foire !',
                style: Theme.of(context).textTheme.headline3,
              )),
            );
          else {
            return Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.all(12),
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) =>
                      SalonItem(salon: salonProvider.salonList[index]),
                  // separatorBuilder: (BuildContext context, int index) {
                  //   return Divider(
                  //     color: Colors.grey,
                  //   );
                  // },
                  itemCount: salonProvider.salonList.length),
            );
          }
        }),
      ],
    );
  }
}

class SalonItem extends StatefulWidget {
  final Salon salon;

  const SalonItem({super.key, required this.salon});

  @override
  State<SalonItem> createState() => _SalonItemState();
}

class _SalonItemState extends State<SalonItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      String? category;
      try {
        category = widget.salon.res['type']['lib'];
      } catch (_) {
        category = null;
      }
      return GestureDetector(
        onTap: () {
          PageNavigator(ctx: context).nextPage(
              page: SalonPage(
            salon: widget.salon,
          ));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: primaryColor,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.salon.code!,
                          style: Theme.of(context).textTheme.headline4!),
                      (widget.salon.object != null)
                          ? Text(
                              widget.salon.object!,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor),
                            )
                          : Text('Nom de l\'Affaire',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(color: Colors.black)),
                      Container(
                        width: 200,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Statut: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith()),
                            Text(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                '(${widget.salon.status})',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(color: Colors.red)),
                          ],
                        ),
                      ),
                      Text('Tier: ${widget.salon.client!.name}',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(color: Colors.grey)),
                      (category != null)
                          ? Text(
                              'Catégorie: ${widget.salon.res['type']['lib']}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(color: Colors.blue))
                          : Text('Catégorie: -- ',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(color: Colors.blue)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.date_range, color: primaryColor),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                              'Date début : ${DateFormat('dd-MM-yyyy').format(widget.salon.startDate!)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith()),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.date_range,
                            color: primaryColor,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                              'Date fin : ${DateFormat('dd-MM-yyyy').format(widget.salon.endDate!)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith()),
                        ],
                      ),
                      (widget.salon.delivryDate != null)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fire_truck_outlined,
                                  color: primaryColor,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                    'Date livraison : ${DateFormat('yyyy-MM-dd').format(widget.salon.delivryDate!)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith())
                              ],
                            )
                          : Container(),
                    ],
                  ),
                  Visibility(
                    visible: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                            onPressed: () {
                              if (widget.salon.client!.phone != null)
                                PhoneUtils()
                                    .makePhoneCall(widget.salon.client!.phone!);
                              else
                                showAlertDialog(context,
                                    'Aucun numéro de téléphone pour ce client');
                            },
                            icon: Icon(
                              Icons.call,
                              color: primaryColor,
                            )),
                      ],
                    ),
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
