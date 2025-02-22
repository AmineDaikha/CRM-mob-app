import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/http_request.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/constants/utils.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/command.dart';
import 'package:mobilino_app/models/product.dart';
import 'package:mobilino_app/models/step_pip.dart';
import 'package:mobilino_app/screens/home_page/notes_page/note_liste_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:mobilino_app/widgets/confirmation_opportunity_dialog.dart';
import 'package:mobilino_app/widgets/dialog_lib.dart';
import 'package:mobilino_app/widgets/dialog_opp_state.dart';
import 'package:mobilino_app/widgets/payment_page.dart';
import 'package:mobilino_app/widgets/text_field.dart';

import 'activities_pages/activity_list_page.dart';
import 'command_delivred_page.dart';
import 'command_page.dart';
import 'devis_page.dart';
import 'init_store_page.dart';

class OpportunityPage extends StatefulWidget {
  final Client client;

  const OpportunityPage({super.key, required this.client});

  @override
  State<OpportunityPage> createState() => _OpportunityPageState();
}

class _OpportunityPageState extends State<OpportunityPage> {
  Widget icon = Icon(Icons.shopping_cart_outlined);
  int respone = 200;
  double total = 0;
  LatLng? currentLocation;
  List<String> items = [
    'A visité',
    'Visité',
    'Livré',
    'Encaissé',
    'Livré & encaissé',
    'Annulée'
  ];
  List<StepPip> steps = [];

  Future<void> fetchDataSteps(Client client) async {
    steps = [];
    String url = AppUrl.getOneOppo + '${client.idOpp}';
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res oneOppo code : ${req.statusCode}");
    print("res oneOppo body: ${req.body}");
    if (req.statusCode == 200) {
      var res = json.decode(req.body);
      client.stat = res['etapeId'];
      String url =
          AppUrl.getPipelinesSteps + res['etape']['pipelineId'].toString();
      print('url of steps $url');
      req = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
      });
      print("res allSteps code : ${req.statusCode}");
      print("res allSpeps body: ${req.body}");
      if (req.statusCode == 200) {
        List<dynamic> data = json.decode(req.body);
        data.forEach((element) {
          steps.add(StepPip(
              id: element['id'],
              name: element['libelle'],
              color: element['couleur']));
        });
      }
    }
  }

  Future<void> fetchData(Client client) async {
    await fetchDataSteps(client);
    print('stat: ${client.stat}');
    String url = AppUrl.commandsOfOpportunite +
        AppUrl.user.etblssmnt!.code! +
        '/' +
        widget.client.idOpp!;
    if (client.stat == 3 || client.stat == 5) {
      url = AppUrl.deliveryOfOpportunite +
          AppUrl.user.etblssmnt!.code! +
          '/' +
          widget.client.idOpp!;
      widget.client.typeCommand = 'liv';
    }
    print('url of CmdOfOpp $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res cmdOpp code : ${req.statusCode}");
    print("res cmdOpp body: ${req.body}");
    if (req.statusCode == 200) {
      respone = 200;

      icon = Image.asset('assets/caddie_rempli.png');

      var res = json.decode(req.body);
      List<dynamic> data = res['lignes'];
      print('sizeof: ${data.length}');
      try {
        List<Product> products = [];
        Future.forEach(data.toList(), (element) async {
          print('quantité: ${element['qte'].toString()}');
          double d = element['qte'];
          int quantity = d.toInt();
          // double dStock = element['stockDep'];
          // int quantityStock = dStock.toInt();
          var artCode = element['artCode'];
          print('imghhh $artCode');
          print('url: ${AppUrl.getUrlImage + '$artCode'}');
          http.Response req = await http
              .get(Uri.parse(AppUrl.getUrlImage + '$artCode'), headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
            "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/",
          });
          print("res imgArticle code : ${req.statusCode}");
          print("res imgArticle body: ${req.body}");
          if (req.statusCode == 200) {
            List<dynamic> data = json.decode(req.body);
            if (data.length > 0) {
              var item = data.first;
              print('item: ${item['path']}');
              print('price: ${element['pPrv']} ${element['pBrut']} ');
              double total = 0;
              if (element['total'] != null)
                total = element['total'];
              else if (element['cout'] != null) total = element['cout'];
              products.add(Product(
                  quantity: quantity,
                  price: element['pBrut'],
                  total: total,
                  id: element['artCode'],
                  image: AppUrl.baseUrl + item['path'],
                  name: element['lib']));
            }
          }
        }).then((value) {
          client.command = Command(
              res: res,
              id: res['numero'],
              date: DateTime.parse(res['date']),
              total: 0,
              paid: 0,
              products: products,
              nbProduct: products.length);
        });

        // get image
      } catch (e, stackTrace) {
        print('Exception: $e');
        print('Stack trace: $stackTrace');
      }
    } else {
      url = AppUrl.devisOfOpportunite +
          AppUrl.user.etblssmnt!.code! +
          '/' +
          widget.client.idOpp!;
      print('url of devisOfOpp $url');
      req = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
      });
      print("res devisOpp code : ${req.statusCode}");
      print("res devisOpp body: ${req.body}");
      if (req.statusCode == 200) {
        respone = 200;
        icon = Icon(
          Icons.shopping_cart_checkout_sharp,
          color: Colors.orange,
        );
        print('rfrrfrfr: orange!');
        var res = json.decode(req.body);
        widget.client.res = res;
        total = res['brut'];
        List<dynamic> data = res['lignes'];
        print('sizeof: ${data.length}');
        try {
          List<Product> products = [];
          await Future.forEach(data.toList(), (element) async {
            double remise = 0;
            double tva = 0;
            if (element['natTvatx'] != null) tva = element['natTvatx'];
            if (element['remise'] != null) remise = element['remise'];
            print('quantité: ${element['qte'].toString()}');
            double d = element['qte'];
            int quantity = d.toInt();
            // double dStock = element['stockDep'];
            // int quantityStock = dStock.toInt();
            var artCode = element['artCode'];
            print('imghhh $artCode');
            print('url: ${AppUrl.getUrlImage + '$artCode'}');
            http.Response req = await http
                .get(Uri.parse(AppUrl.getUrlImage + '$artCode'), headers: {
              "Accept": "application/json",
              "content-type": "application/json; charset=UTF-8",
              "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/",
            });
            print("res imgArticle code : ${req.statusCode}");
            print("res imgArticle body: ${req.body}");
            if (req.statusCode == 200) {
              List<dynamic> data = json.decode(req.body);
              var path = null;
              if (data.length > 0) {
                var item = data.first;
                print('item: ${item['path']}');
                path = AppUrl.baseUrl + item['path'];
                print('price: ${element['pPrv']} ${element['pBrut']} ');
                double total = 0;
                if (element['total'] != null)
                  total = element['total'];
                else if (element['cout'] != null) total = element['cout'];
              }
              products.add(Product(
                  quantity: quantity,
                  price: element['pBrut'],
                  total: total,
                  remise: remise,
                  tva: tva,
                  id: element['artCode'],
                  image: path,
                  name: element['lib']));
            }
          }).then((value) {
            client.command = Command(
                res: res,
                id: res['numero'],
                date: DateTime.parse(res['date']),
                total: 0,
                paid: 0,
                products: products,
                nbProduct: products.length);
            print('size of products: ${products.length}');
            widget.client.command!.type = 'Devis';
          });

          // get image
        } catch (e, stackTrace) {
          print('Exception: $e');
          print('Stack trace: $stackTrace');
        }
      } else {
        respone = 404;
        client.command = null;
      }
    }
    print('command of ${client.name} ${client.id} is: ${client.command}');
  }

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    double priorityrating = 0;
    double emergencyrating = 0;
    if (widget.client.priority != null)
      priorityrating = widget.client.priority!.toDouble();
    if (widget.client.emergency != null)
      emergencyrating = widget.client.emergency!.toDouble();
    print('lib: ${widget.client.priority} ${(widget.client.total == null)}');
    if (widget.client.total == null || widget.client.total == 'null')
      widget.client.total = '0';
    if (double.parse(widget.client.total.toString()) > 0) {
      color = primaryColor;
    } else if (double.parse(widget.client.total.toString()) < 0) {
      color = Colors.red;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(
          color: Colors.white, // Set icon color to white
        ),
        title: ListTile(
          title: Text(
            'Opportunité de : ',
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
      body: FutureBuilder(
          future: fetchData(widget.client),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Future is still running, return a loading indicator or some placeholder.
              return Center(
                child: Row(
                  children: [
                    CircularProgressIndicator(
                      color: primaryColor,
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 15, top: 35, bottom: 35),
                        child: Text("Loading...")),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              // There was an error in the future, handle it.
              print('Error: ${snapshot.hasError}');
              return Text('Error: ${snapshot.error}');
            } else {
              String? s;
              try {
                s = AppUrl.filtredOpporunity.pipeline!.steps
                    .where((element) => element.id == widget.client.stat!)
                    .first
                    .name;
              } catch (_) {
                s = widget.client.resOppo['etape']['libelle'];
              }
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 1.0),
                          child: Container(
                            height: 600,
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (widget.client.lib != null)
                                    ? GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return LibDialog(
                                                lib: widget.client.lib,
                                              );
                                            },
                                          ).then((value) {
                                            widget.client.lib = value;
                                            setState(() {});
                                          });
                                        },
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${widget.client.lib!}',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3!
                                                    .copyWith(
                                                        color: primaryColor),
                                              ),
                                              (widget.client.stat! > 0)
                                                  ? Text(
                                                      //' (${items[widget.client.stat! - 1]})',
                                                      ' (${s})',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline3!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  Colors.red),
                                                    )
                                                  : Text(''),
                                            ],
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return LibDialog(
                                                lib: widget.client.lib,
                                              );
                                            },
                                          ).then((value) {
                                            widget.client.lib = value;
                                            setState(() {});
                                          });
                                        },
                                        child: Center(
                                          child: Text('Nom de l\'Affaire',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline2!
                                                  .copyWith(
                                                      color: Colors.black)),
                                        ),
                                      ),
                                SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      //_selectStartDate(context);
                                      showDateTimeDialog(context);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.calendar_month_outlined,
                                            color: primaryColor, size: 20),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                            '${DateFormat('dd-MM-yyyy').format(widget.client.dateStart!)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2!
                                                .copyWith(
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                        SizedBox(
                                          width: 30,
                                        ),
                                        Icon(Icons.access_time,
                                            color: primaryColor, size: 20),
                                        SizedBox(
                                          width: 7,
                                        ),
                                        Text(
                                            '${DateFormat('HH:mm').format(widget.client.dateStart!)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2!
                                                .copyWith(
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: Text(
                                    '${AppUrl.formatter.format(double.parse(widget.client.total!))} DZD',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .copyWith(
                                            color: color,
                                            fontWeight: FontWeight.normal),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Priorité: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    Align(
                                      child: RatingBar.builder(
                                        //ignoreGestures: true,
                                        initialRating: priorityrating,
                                        minRating: 1.0,
                                        maxRating: 5.0,
                                        itemCount: 5,
                                        itemSize: 35,
                                        // Number of stars
                                        itemBuilder: (context, index) => Icon(
                                          index >= priorityrating
                                              ? Icons.star_border_outlined
                                              : Icons.star,
                                          color: Colors.yellow,
                                        ),
                                        onRatingUpdate: (rating) {
                                          setState(() {
                                            widget.client.priority =
                                                rating.toInt();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Urgence: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    RatingBar.builder(
                                      //ignoreGestures: true,
                                      initialRating: emergencyrating,
                                      minRating: 1.0,
                                      maxRating: 5.0,
                                      itemCount: 5,
                                      itemSize: 35,
                                      // Number of stars
                                      itemBuilder: (context, index) => Icon(
                                        index >= emergencyrating
                                            ? Icons.star_border_outlined
                                            : Icons.star,
                                        color: Colors.yellow,
                                      ),
                                      onRatingUpdate: (rating) {
                                        setState(() {
                                          widget.client.emergency =
                                              rating.toInt();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: Text('Client: ${widget.client.name!}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline3!
                                          .copyWith(color: primaryColor)),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: Text('Ville : ${widget.client.city!}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(color: Colors.grey)),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    (widget.client.phone != null)
                                        ? Text(widget.client.phone!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline3!
                                                .copyWith(
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.normal))
                                        : Container(),
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
                                ),
                                Divider(color: Colors.grey),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Gestion de la commande ',
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        print(
                                            'client; ${widget.client.command}');
                                        if (respone == 200) {
                                          if (widget.client.command!.type ==
                                              'Devis') {
                                            PageNavigator(ctx: context)
                                                .nextPage(
                                                    page: DevisPage(
                                              client: widget.client,
                                            ));
                                          } else if (widget.client.stat == 3 ||
                                              widget.client.stat == 5)
                                            PageNavigator(ctx: context)
                                                .nextPage(
                                                    page: CommandDelivredPage(
                                              client: widget.client,
                                            ));
                                          else
                                            PageNavigator(ctx: context)
                                                .nextPage(
                                                    page: CommandPage(
                                              client: widget.client,
                                            ));
                                        } else
                                          PageNavigator(ctx: context).nextPage(
                                              page: StorePage(
                                            client: widget.client,
                                          ));
                                        //Navigator.pushNamed(context, '/home/command', arguments: client);
                                      },
                                      icon: (respone == 200)
                                          ? icon //Image.asset('assets/caddie_rempli.png')
                                          : icon,
                                      //Icon(Icons.shopping_cart_outlined),
                                      color: primaryColor,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Gestion des activités ',
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          PageNavigator(ctx: context).nextPage(
                                              page: ActivityListPage(
                                            client: widget.client,
                                          ));
                                        },
                                        icon: Icon(
                                          Icons.local_activity_outlined,
                                          color: primaryColor,
                                        )),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Gestion des notes ',
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          PageNavigator(ctx: context).nextPage(
                                              page: NoteListPage(
                                                  client: widget.client));
                                        },
                                        icon: Icon(
                                          Icons.note_outlined,
                                          color: primaryColor,
                                        )),
                                  ],
                                ),
                              ],
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
                              if (AppUrl.filtredOpporunity.pipeline!.id == 2) {
                                showMenu(
                                  context: context,
                                  position: RelativeRect.fromLTRB(
                                      100.0, 100.0, 100.0, 100.0),
                                  items: steps.map((StepPip option) {
                                    return PopupMenuItem<StepPip>(
                                      value: option,
                                      child: Text(option.name),
                                    );
                                  }).toList(),
                                ).then((value) async {
                                  if (value != null) {
                                    if (value.id == 14) {
                                      if (widget.client.command == null) {
                                        showMessage(
                                            message: 'Aucun devis pour gagné !',
                                            context: context,
                                            color: Colors.red);
                                        return;
                                      } else {
                                        print(
                                            'rgrgrg: ${widget.client.command!.res}');
                                        ConfirmationDialog confirmationDialog =
                                            ConfirmationDialog();
                                        bool confirmed =
                                            await confirmationDialog
                                                .showConfirmationDialog(
                                                    context, 'changToGan');
                                        if (confirmed) {
                                          showLoaderDialogGlobal(context);
                                          await _getCurrentLocation();
                                          await toCommand(widget.client)
                                              .then((editCommandValue) {
                                            if (editCommandValue) {
                                              // _showAlertConfirmationDialog(
                                              //     context, 'Transfert avec succès ');
                                            } else {
                                              // _showAlertDialog(context,
                                              //     'Échec de Transfert de devis !');
                                            }
                                          });
                                          changeOppState(widget.client, 14)
                                              .then((valueChng) {
                                            if (valueChng) {
                                              Navigator.pushNamedAndRemoveUntil(
                                                  context,
                                                  '/home',
                                                  (route) => false);
                                            } else {
                                              Navigator.pop(context);
                                            }
                                          });
                                        }
                                      }
                                    } else {
                                      if (value.id <=
                                          widget.client.resOppo['etapeId']) {
                                        showAlertDialog(context,
                                            "Impossible de changer l\état de cette opportunité à l\'état ${value.name} car elle est de l\'état $s");
                                        return;
                                      } else {
                                        showLoaderDialogGlobal(context);
                                        changeOppState(widget.client, value.id)
                                            .then((value) {
                                          setState(() {});
                                          showMessage(
                                              message:
                                                  'L\'état de cette opportunité a été modifiée avec succès',
                                              context: context,
                                              color: primaryColor);
                                          Navigator.pop(context);
                                        });
                                      }
                                    }
                                  }
                                });
                                return;
                              }
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ChoiceDialog();
                                },
                              ).then((value) {
                                PageNavigator page =
                                    PageNavigator(ctx: context);
                                print('value of result choice: $value');
                                if (value == 0) {
                                  //Navigator.pop(context);
                                  return;
                                }
                                if (value == 4) {
                                  page.nextPage(
                                      page: PaymentPage(
                                          client: widget.client, toStat: 4));
                                } else if (value == 5) {
                                  if (widget.client.command == null) {
                                    showMessage(
                                        message: 'Pas de commande',
                                        context: context,
                                        color: Colors.red);
                                  } else {
                                    if (widget.client.typeCommand == 'cmd') {
                                      page.nextPage(
                                          page: CommandPage(
                                              client: widget.client));
                                    } else {
                                      page.nextPage(
                                          page: PaymentPage(
                                              client: widget.client,
                                              toStat: 5));
                                    }
                                  }
                                } else if (value == 3) {
                                  if (widget.client.command == null) {
                                    showMessage(
                                        message: 'Pas de commande',
                                        context: context,
                                        color: Colors.red);
                                  } else {
                                    if (widget.client.typeCommand == 'cmd') {
                                      page.nextPage(
                                          page: CommandPage(
                                              client: widget.client));
                                    } else {
                                      showMessage(
                                          message: 'Commande déjà livré !',
                                          context: context,
                                          color: Colors.red);
                                    }
                                  }
                                } else
                                  confirmationAndChangeState(
                                      context, widget.client, value);
                              });
                            },
                            child: Text(
                              "Modifier l'état",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
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
                            onPressed: () async {
                              ConfirmationOppDialog confirmationOppDialog =
                                  ConfirmationOppDialog();
                              bool confirmed = await confirmationOppDialog
                                  .showConfirmationDialog(context, 'editOpp');
                              if (confirmed) {
                                showLoaderDialog(context);
                                editOpp(widget.client).then((value) {
                                  if (value) {
                                    showMessage(
                                        message:
                                            'L\'opportunité a été modifiée avec succès',
                                        context: context,
                                        color: primaryColor);
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/home',
                                        (route) =>
                                            false).then((value) =>
                                        PageNavigator(ctx: context).nextPage(
                                            page: OpportunityPage(
                                                client: widget.client)));
                                  } else {
                                    Navigator.pop(context);
                                    showMessage(
                                        message:
                                            'Échec de modification de l\'opportunité',
                                        context: context,
                                        color: Colors.red);
                                  }
                                });
                              } else {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            },
                            child: Text(
                              "Modifier l'opportunité",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }

  Future<bool> toCommand(Client client) async {
    await sendDocument().then((value) async {
      if (value == true) {
        print('res:: ${widget.client.res}');
        String url = AppUrl.editDevis +
            '${widget.client.res['numero']}/${AppUrl.user.etblssmnt!.code}';
        print('res url $url');
        widget.client.res['etat'] = 'S';
        print('res:: ${widget.client.res['lignes']}');
        widget.client.res['produitDtos'] = widget.client.res['lignes'];
        print('res:: ${widget.client.res['produitDtos']}');
        http.Response req = await http
            .put(Uri.parse(url), body: jsonEncode(widget.client.res), headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
        print("res toCmd code : ${req.statusCode} ");
        print("res toCmd body: ${req.body}");
        if (req.statusCode == 200 || req.statusCode == 201) {
          //Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          return true;
        } else {
          print('Failed to load data');
          return false;
        }
      } else {
        return false;
      }
    });
    return false;
  }

  Future<bool> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('latLng: ${position.latitude} ${position.longitude}');
      currentLocation = LatLng(position.latitude, position.longitude);
      return true;
    } catch (e) {
      print('Error getting current location: $e');
    }
    return false;
  }

  Future<bool> sendDocument() async {
    print('salcode is: ${AppUrl.user.salCode}');
    List<Map<String, dynamic>> products = [];
    List<Map<String, dynamic>> produitDtos = [];
    for (Product product in widget.client.command!.products) {
      Map<String, dynamic> jsonProduct = {
        "artCode": product.id,
        "lib": product.name,
        "artCbar": product.codeBar,
        "qte": product.quantity,
        "pBrut": product.price,
        "Qcmde": product.quantity,
        "PNet": product.priceNet,
        "repCode": AppUrl.user.repCode,
        "remise": product.remise,
        "NatTvaTx": product.tva,
      };
      products.add(jsonProduct);
      Map<String, dynamic> jsonProduct2 = {
        "codeProduit": product.id,
        "lib": product.name,
        "cBar": product.codeBar,
        "tva": product.tva,
        "prixVente": product.price,
        "prixVenteRemise": product.priceNet,
        "remise": product.remise,
        "qts": product.quantity,
        "DepStock": product.quantityStock,
      };
      produitDtos.add(jsonProduct2);
    }
    // Map<String, dynamic> jsonObject = {
    //   "numero": null,
    //   "etbCode": AppUrl.user.etblssmnt!.code,
    //   "piece": null,
    //   "rpiece": null,
    //   "type": null,
    //   "stype": null,
    //   "etat": null,
    //   "factra": true,
    //   "date": DateTime.now().toString(),
    //   "trtcre": null,
    //   "dtPrv": DateTime.now().toString(),
    //   "dtinv": DateTime.now().toString(),
    //   "tpinv": null,
    //   "enTtc": true,
    //   "refpcf": null,
    //   "memo": null,
    //   "pcfCode": widget.client.id, // tier
    //   "pcfPayeur": null,
    //   "pcfRemval": 0,
    //   "pcfRemmin": 0,
    //   "cctNumero": null,
    //   "fTitl": null,
    //   "fRs": null,
    //   "fRs2": null,
    //   "fRue": null,
    //   "fComp": null,
    //   "fEtat": null,
    //   "fReg": null,
    //   "fCp": null,
    //   "fVill": null,
    //   "payCode": null,
    //   "fCbar": null,
    //   "pcfliv": null,
    //   "fpyeur": true,
    //   "livcli": true,
    //   "lTitl": null,
    //   "lRs": null,
    //   "lRs2": null,
    //   "lRue": null,
    //   "lComp": null,
    //   "lEtat": null,
    //   "lReg": null,
    //   "lCp": null,
    //   "lVill": null,
    //   "lPays": null,
    //   "lCbar": null,
    //   "origin": null,
    //   "refus": null,
    //   "trpCode": null,
    //   "tarCode": null,
    //   "devCode": null,
    //   "langue": null,
    //   "regCode": null,
    //   "natCode": null,
    //   "srvCode": null,
    //   "repCode": AppUrl.user.repCode,
    //   "salCode": AppUrl.user.salCode,
    //   "depCode": AppUrl.user.localDepot!.id!,
    //   "tdepot": null,
    //   "prjCode": null,
    //   "ccedix": true,
    //   "fedix": true,
    //   "cbarsu": null,
    //   "cbaremet": null,
    //   "refoxt": null,
    //   "contrme": 0,
    //   "txDev": 0,
    //   "hausse": 0,
    //   "poidsb": 0,
    //   "poidsn": 0,
    //   "ncolis": 0,
    //   "volume": 0,
    //   "remlig": 0,
    //   "brut": 0,
    //   "remcli": 0,
    //   "txrfac": 0,
    //   "remfac": 0,
    //   "cport": null,
    //   "pport": null,
    //   "port": 0,
    //   "cfrais": null,
    //   "pfrais": null,
    //   "frais": 0,
    //   "csuppl": null,
    //   "psuppl": null,
    //   "suppl": 0,
    //   "cfrapp": 0,
    //   "tvaT1": 0,
    //   "tvaC1": null,
    //   "tvaB1": 0,
    //   "tvaT2": 0,
    //   "tvaC2": null,
    //   "tvaB2": 0,
    //   "tvaT3": 0,
    //   "tvaC3": null,
    //   "tvaB3": 0,
    //   "tvaT4": 0,
    //   "tvaC4": null,
    //   "tvaB4": 0,
    //   "tvaT5": 0,
    //   "tvaC5": null,
    //   "tvaB5": 0,
    //   "mtHt": 0,
    //   "mtTva": 0,
    //   "mtTtc": 0,
    //   "acpte": 0,
    //   "acpant": true,
    //   "txEsc": 0,
    //   "mtEsc": 0,
    //   "txRg": 0,
    //   "mtRg": 0,
    //   "mtNet": 0,
    //   "cout": 0,
    //   "marge": 0,
    //   "prvech": 0,
    //   "tcDa": null,
    //   "tcEmp": null,
    //   "ddtass": DateTime.now().toString(),
    //   "etaass": null,
    //   "dtcre": DateTime.now().toString(),
    //   "usrcre": null,
    //   "dtmaj": DateTime.now().toString(),
    //   "usrmaj": null,
    //   "nummaj": 0,
    //   "caisseCode": null,
    //   "points": 0,
    //   "cloture": null,
    //   "valider": true,
    //   "isfCode": null,
    //   "bnqCode": null,
    //   "bqcCode": null,
    //   "dosImpCode": null,
    //   "fraAppCode": null,
    //   "order": 0,
    //   "regType": null,
    //   "delLaivraison": 0,
    //   "cgvPrix": null,
    //   "moyenTransport": null,
    //   "dateValiditeDoc": DateTime.now().toString(),
    //   "conditionsDeVente": null,
    //   "nbPalettesLivrees": 0,
    //   "nbPalettesRestituees": 0,
    //   "ecartPalettes": 0,
    //   "codeVehicule": AppUrl.user.localDepot!.id,
    //   "codeChauffeur": AppUrl.user.userId,
    //   "demandeAnalyse": null,
    //   "textePresentation": null,
    //   "texteFin": null,
    //   "affectCdeCliStock": null,
    //   "srvDestinataire": null,
    //   "heureSortieDepot": DateTime.now().toString(),
    //   "heureArriveDestin": DateTime.now().toString(),
    //   "heureSortieClient": DateTime.now().toString(),
    //   "revueCmd": null,
    //   "heureDechargement": DateTime.now().toString(),
    //   "numReservation": null,
    //   "creneauHorair": null,
    //   "originMarch": null,
    //   "lieuCharge": null,
    //   "lieuDecharg": null,
    //   "codePlannPrev": null,
    //   "bonsRegroupemnt": null,
    //   "etbTcode": AppUrl.user.etblssmnt!.code,
    //   "comptabilise": true,
    //   "coutCode": null,
    //   "segCode": null,
    //   "totRemLig": 0,
    //   "motifRejet": null,
    //   "pieceDa": null,
    //   "pieceDp": null,
    //   "pieceFp": null,
    //   "pieceBc": null,
    //   "pieceEx": null,
    //   "pieceBr": null,
    //   "pieceFa": null,
    //   "delRepense": 0,
    //   "dirCode": null,
    //   "dprCode": null,
    //   "fraiApprochAff": true,
    //   "fraiApproche": true,
    //   "heureRetourDep": null,
    //   "zone": null,
    //   "totalTa": 0,
    //   "aPreparer": null,
    //   "aLivrer": null,
    //   "vehCodeDms": null,
    //   "priorite": null,
    //   "motifAnnul": null,
    //   "prjCodeD": null,
    //   "excluDoc": true,
    //   "imprDoc": true,
    //   "salCodeDis": null,
    //   "echPeriodique": true,
    //   "typeEchelon": null,
    //   "nbreEchea": 0,
    //   "dt1Ech": DateTime.now().toString(),
    //   "sStype": null,
    //   "codeContrat": null,
    //   "budCode": null,
    //   "lbdStructure": null,
    //   "aIntegrer": true,
    //   "statutFicheMandat": null,
    //   "codeOrdo": null,
    //   "codeProvisoireManda": null,
    //   "usrcon": null,
    //   "batCode": null,
    //   "salleCode": AppUrl.user.salCode,
    //   "etageCode": null,
    //   "espaceCode": null,
    //   "salCodeAffect": null,
    //   "restoPriorite": 0,
    //   "idTable": null,
    //   "nbCouverts": 0,
    //   "segne": true,
    //   "fapproche": true,
    //   "docId": 0,
    //   "vehCode": AppUrl.user.localDepot!.id!,
    //   "isPrestation": true,
    //   "cntReception": true,
    //   "remNet": 0,
    //   "pieceDf": null,
    //   "longitude": currentLocation!.longitude,
    //   "latitude": currentLocation!.latitude,
    //   "oppoCode": widget.client.idOpp,
    //   "signature": null,
    //   "lignes": products,
    //   "produitDtos": products
    // };
    Map<String, dynamic> jsonObject = {
      "etbCode": AppUrl.user.etblssmnt!.code,
      "date": DateTime.now().toString(),
      "pcfCode": widget.client.id, // tier
      "repCode": AppUrl.user.repCode,
      "salCode": AppUrl.user.salCode,
      "depCode": AppUrl.user.localDepot!.id!,
      "oppoCode": widget.client.idOpp,
      "longitude": currentLocation!.longitude,
      "latitude": currentLocation!.latitude,
      "signature": null,
      "lignes": products,
      "produitDtos": produitDtos
    };
    String url = '';
    url = AppUrl.commands;
    print('url : $url');
    http.Response req =
        await http.post(Uri.parse(url), body: jsonEncode(jsonObject), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res cmd code : ${req.statusCode}");
    print("res cmd body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      widget.client.command!.type = 'Commande';
      HttpRequestApp httpRequestApp = HttpRequestApp();
      await httpRequestApp.sendItinerary('COM');
      var res = json.decode(req.body);
      if (widget.client.email != null)
        await httpRequestApp.sendEmail(res['numero'],
            widget.client.command!.type!, '${widget.client.email}');
      return true;
    } else {
      return false;
    }
  }

  Future<void> showDateTimeDialog(BuildContext context) async {
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
        },
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
        widget.client.dateStart = selectedDateTime;
        setState(() {});
      }
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

  showLoaderDialogGlobal(BuildContext context) {
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
              message: 'Échec de modification de l\'état d\'opportunité',
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

  Future<bool> editOpp(Client client) async {
    String url = AppUrl.editOpportunities + '${client.idOpp}';
    print('res url $url');
    client.resOppo['libelle'] = client.lib;
    client.resOppo['dateDebut'] =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(client.dateStart!);
    client.resOppo['priorite'] = client.priority;
    client.resOppo['urgence'] = client.emergency;

    http.Response req = await http
        .put(Uri.parse(url), body: jsonEncode(client.resOppo), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res editOpp code : ${req.statusCode} ");
    print("res editOpp body: ${req.body}");
    if (req.statusCode == 200) {
      return true;
    } else {
      print('Failed to load data');
      return false;
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
