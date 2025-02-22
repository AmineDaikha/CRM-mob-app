import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/http_request.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/command.dart';
import 'package:mobilino_app/models/product.dart';
import 'package:mobilino_app/providers/command_provider.dart';
import 'package:mobilino_app/providers/product_provider.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/add_payment_dialog.dart';
import 'package:mobilino_app/widgets/command_dialog.dart';
import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:provider/provider.dart';

class NewCommandPage extends StatefulWidget {
  final Client client;
  //final VoidCallback callback;

  const NewCommandPage({
    super.key,
    required this.client,
    //required this.callback,
  });

  //static const String routeName = '/home/command';

  // static Route route() {
  //   return MaterialPageRoute(
  //     settings: RouteSettings(name: routeName),
  //     builder: (_) {
  //       return CommandPage();
  //     },
  //   );
  // }

  @override
  State<NewCommandPage> createState() => _NewCommandPageState();
}

class _NewCommandPageState extends State<NewCommandPage> {
  double total = 0;
  late DateTime selectedDate = DateTime.now();
  LatLng? currentLocation;

  //late IconButton validateIcon;
  //late Command oldCommand;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Access BuildContext or dependent widgets here

    });
    super.initState();
    total = widget.client.command!.total;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoaderDialog(context);
      fetchData().then((value){
        Navigator.pop(context);
        reload();
      });

    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
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
    if (picked != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: primaryColor,
                // change the text color
                onSurface: grey,
              ),
              indicatorColor: primaryColor,
              primaryColor: primaryColor,
              backgroundColor: primaryColor,
              buttonTheme: ButtonTheme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  background: primaryColor,
                  secondary: primaryColor,
                ),
              ),
            ),
            child: child!,
          );
        },
      );
      print('time is: ${selectedTime!.hour}');
      if (selectedTime != null) {
        setState(() {
          selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  void reload() {
    setState(() {
      widget.client.command!.calculateTotal();
      total = widget.client.command!.total;
      //widget.callback();
      print('total is: ${total}');
    });
  }

  Future<bool?> fetchData() async {
    String url = AppUrl.getOneDoc +
        widget.client.command!.id! +
        '/' +
        AppUrl.user.etblssmnt!.code!;
    print('url of getOneDoc ${url}');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res cmdOpp code : ${req.statusCode}");
    print("res cmdOpp body: ${req.body}");
    if (req.statusCode == 200) {
      var res = json.decode(req.body);
      List<dynamic> data = res['lignes'];
      print('sizeof: ${data.length}');
      print('lignes: ${res['lignes']}');
      //try {
      List<Product> products = [];
      for (int i = 0; i < data.toList().length; i++) {
        var element = data.toList()[i];
        if (element['qte'] == null) continue;
        try {
          print('quantité: ${element['qte'].toString()}');
          double remise = 0;
          if(element['remise'] != null) remise = element['remise'];
          double d = element['qte'];
          int quantity = d.toInt();
          double dStock;
          if (element['stockDep'] != null) dStock = element['stockDep'];
          int quantityStock = d.toInt();
          var artCode = element['artCode'];
          double total = 0;
          if (element['total'] != null) total = element['total'];
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
              products.add(Product(
                  quantity: quantity,
                  quantityStock: quantityStock,
                  price: element['pBrut'],
                  total: total,
                  tva: element['natTvatx'],
                  remise: remise,
                  id: element['artCode'],
                  image: AppUrl.baseUrl + item['path'],
                  name: element['lib']));
            }
          }
        } catch (e, stackTrace) {
          print('Exception: $e');
          print('Stack trace: $stackTrace');
        }
      }
      widget.client.command = Command(
          id: res['numero'],
          date: DateTime.parse(res['date']),
          total: 0,
          paid: 0,
          products: products,
          nbProduct: products.length);
      return true;
      // get image
      // } catch (e, stackTrace) {
      //   print('Exception: $e');
      //   print('Stack trace: $stackTrace');
      // }
    } else {}

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //     future: fetchData(),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         // Future is still running, return a loading indicator or some placeholder.
    //         return AlertDialog(
    //           content: Row(
    //             //mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               CircularProgressIndicator(
    //                 color: primaryColor,
    //               ),
    //               SizedBox(
    //                 width: 30,
    //               ),
    //               Text("Loading..."),
    //             ],
    //           ),
    //         );
    //       } else if (snapshot.hasError) {
    //         // There was an error in the future, handle it.
    //         print('Error: ${snapshot.hasError} ${snapshot.error} ');
    //         return AlertDialog(
    //           content: Row(
    //             //mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               Icon(
    //                 Icons.error_outline,
    //                 color: Colors.red,
    //               ),
    //               SizedBox(
    //                 width: 30,
    //               ),
    //               // Text('Error: ${snapshot.error}')
    //               Text('Nous sommes désolé, la qualité de votre connexion ne vous permet pas de vous connecter à votre serveur.'
                      //' Veuillez réessayer ultérieurement. Merci'),
    //             ],
    //           ),
    //         );
    //       }
          return Consumer<ProductProvider>(
              builder: (context, products, snapshot) {
            return Scaffold(
              appBar: AppBar(
                iconTheme: IconThemeData(
                  color: Colors.white, // Set icon color to white
                ),
                backgroundColor: Theme.of(context).primaryColor,
                title: ListTile(
                  title: Text(
                    "Bon de retour pour : ",
                    style: Theme.of(context)
                        .textTheme
                        .headline3!
                        .copyWith(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${widget.client.name}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: Colors.white),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () async {
                      ConfirmationDialog confirmationDialog =
                          ConfirmationDialog();
                      bool confirmed = await confirmationDialog
                          .showConfirmationDialog(context, 'confirmReturn');
                      if (confirmed) {
                        // confirm
                        _getCurrentLocation().then((value) {
                          if (value) {
                            sendDocument(context);
                          }
                        });
                      }
                    },
                    icon: Icon(
                      Icons.check_box_outlined,
                      color: Colors.white,
                    ),
                  ),
                  // IconButton(
                  //     onPressed: () {},
                  //     icon: Icon(
                  //       Icons.check_box_outlined,
                  //       color: Colors.white,
                  //     )),,
                ],
              ),
              body: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              // Shadow color
                              offset: Offset(0, 5), // Offset from the object
                            ),
                          ],
                        ),
                        margin: EdgeInsets.all(8),
                        height: 50,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                  onPressed: () {
                                    _selectDate(context);
                                  },
                                  icon: Icon(
                                    Icons.calendar_month_outlined,
                                    color: primaryColor,
                                  )),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                // todo must change
                                '${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            )
                          ],
                        ),
                      ),
                      Consumer<CommandProvider>(
                          builder: (context, commands, snapshot) {
                        return Container(
                          height: 550,
                          child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                //print('nullable ??? ${widget.client.command!.products}');
                                final provider = Provider.of<ProductProvider>(
                                    context,
                                    listen: false);
                                provider.products =
                                    widget.client.command!.products;
                                return CommandItem(
                                  //product: widget.client.command!.products![index],
                                  product: provider.products![index],
                                  command: widget.client.command!,
                                  callback: reload,
                                );
                              },
                              itemCount:
                                  widget.client.command?.products!.length),
                        );
                      }),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      color: primaryColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.client.command!.nbProduct!}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Articles',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(
                                      color: Colors.white,
                                    ),
                              )
                            ],
                          ),
                          Container(
                            width: 2,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date : ${DateFormat('dd-MM-yyyy HH:mm:ss').format(selectedDate)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal),
                              ),
                              Text(
                                'Total : ${AppUrl.formatter.format(widget.client.command!.totalWitoutTaxes)} DZD',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                    ),
                              ),
                              Text(
                                'TVA : ${AppUrl.formatter.format(widget.client.command!.totalTVA)} DZD',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                    ),
                              ),
                              Text(
                                'TTC : ${AppUrl.formatter.format(total)} DZD',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Visibility(
                            visible: false,
                            child: IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AddPaymentDialog(
                                        client: widget.client,
                                      );
                                    });
                              },
                              icon: Ink(
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.add_shopping_cart_outlined,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        //});
  }

  // Function to fetch JSON data from an API
  Future<void> sendDocument(BuildContext context) async {
    List<Map<String, dynamic>> products = [];
    for (Product product in widget.client.command!.products) {
      Map<String, dynamic> jsonProduct = {
        "codeProduit": product.id,
        "pcfCode": null,
        "lib": product.name,
        "type": null,
        "cBar": product.codeBar,
        "tva": null,
        "prixVente": product.price,
        "prixVenteRemise": null,
        "remise": null,
        "qts": product.quantity,
        "qtLivred": null
      };
      products.add(jsonProduct);
    }
    Map<String, dynamic> jsonObject = {
      "numero": null,
      "etbCode": AppUrl.user.etblssmnt!.code,
      "piece": null,
      "rpiece": null,
      "type": null,
      "stype": null,
      "etat": null,
      "factra": true,
      "date": DateTime.now().toString(),
      "trtcre": null,
      "dtPrv": DateTime.now().toString(),
      "dtinv": DateTime.now().toString(),
      "tpinv": null,
      "enTtc": true,
      "refpcf": null,
      "memo": null,
      "pcfCode": widget.client.id, // tier
      "pcfPayeur": null,
      "pcfRemval": 0,
      "pcfRemmin": 0,
      "cctNumero": null,
      "fTitl": null,
      "fRs": null,
      "fRs2": null,
      "fRue": null,
      "fComp": null,
      "fEtat": null,
      "fReg": null,
      "fCp": null,
      "fVill": null,
      "payCode": null,
      "fCbar": null,
      "pcfliv": null,
      "fpyeur": true,
      "livcli": true,
      "lTitl": null,
      "lRs": null,
      "lRs2": null,
      "lRue": null,
      "lComp": null,
      "lEtat": null,
      "lReg": null,
      "lCp": null,
      "lVill": null,
      "lPays": null,
      "lCbar": null,
      "origin": null,
      "refus": null,
      "trpCode": null,
      "tarCode": null,
      "devCode": null,
      "langue": null,
      "regCode": null,
      "natCode": null,
      "srvCode": null,
      "repCode": null,
      "salCode": AppUrl.user.salCode,
      "depCode": AppUrl.user.localDepot!.id!,
      "tdepot": null,
      "prjCode": null,
      "ccedix": true,
      "fedix": true,
      "cbarsu": null,
      "cbaremet": null,
      "refoxt": null,
      "contrme": 0,
      "txDev": 0,
      "hausse": 0,
      "poidsb": 0,
      "poidsn": 0,
      "ncolis": 0,
      "volume": 0,
      "remlig": 0,
      "brut": 0,
      "remcli": 0,
      "txrfac": 0,
      "remfac": 0,
      "cport": null,
      "pport": null,
      "port": 0,
      "cfrais": null,
      "pfrais": null,
      "frais": 0,
      "csuppl": null,
      "psuppl": null,
      "suppl": 0,
      "cfrapp": 0,
      "tvaT1": 0,
      "tvaC1": null,
      "tvaB1": 0,
      "tvaT2": 0,
      "tvaC2": null,
      "tvaB2": 0,
      "tvaT3": 0,
      "tvaC3": null,
      "tvaB3": 0,
      "tvaT4": 0,
      "tvaC4": null,
      "tvaB4": 0,
      "tvaT5": 0,
      "tvaC5": null,
      "tvaB5": 0,
      "mtHt": 0,
      "mtTva": 0,
      "mtTtc": 0,
      "acpte": 0,
      "acpant": true,
      "txEsc": 0,
      "mtEsc": 0,
      "txRg": 0,
      "mtRg": 0,
      "mtNet": 0,
      "cout": 0,
      "marge": 0,
      "prvech": 0,
      "tcDa": null,
      "tcEmp": null,
      "ddtass": DateTime.now().toString(),
      "etaass": null,
      "dtcre": DateTime.now().toString(),
      "usrcre": null,
      "dtmaj": DateTime.now().toString(),
      "usrmaj": null,
      "nummaj": 0,
      "caisseCode": null,
      "points": 0,
      "cloture": null,
      "valider": true,
      "isfCode": null,
      "bnqCode": null,
      "bqcCode": null,
      "dosImpCode": null,
      "fraAppCode": null,
      "order": 0,
      "regType": null,
      "delLaivraison": 0,
      "cgvPrix": null,
      "moyenTransport": null,
      "dateValiditeDoc": DateTime.now().toString(),
      "conditionsDeVente": null,
      "nbPalettesLivrees": 0,
      "nbPalettesRestituees": 0,
      "ecartPalettes": 0,
      "codeVehicule": AppUrl.user.localDepot!.id,
      "codeChauffeur": AppUrl.user.userId,
      "demandeAnalyse": null,
      "textePresentation": null,
      "texteFin": null,
      "affectCdeCliStock": null,
      "srvDestinataire": null,
      "heureSortieDepot": DateTime.now().toString(),
      "heureArriveDestin": DateTime.now().toString(),
      "heureSortieClient": DateTime.now().toString(),
      "revueCmd": null,
      "heureDechargement": DateTime.now().toString(),
      "numReservation": null,
      "creneauHorair": null,
      "originMarch": null,
      "lieuCharge": null,
      "lieuDecharg": null,
      "codePlannPrev": null,
      "bonsRegroupemnt": null,
      "etbTcode": AppUrl.user.etblssmnt!.code,
      "comptabilise": true,
      "coutCode": null,
      "segCode": null,
      "totRemLig": 0,
      "motifRejet": null,
      "pieceDa": null,
      "pieceDp": null,
      "pieceFp": null,
      "pieceBc": null,
      "pieceEx": null,
      "pieceBr": null,
      "pieceFa": null,
      "delRepense": 0,
      "dirCode": null,
      "dprCode": null,
      "fraiApprochAff": true,
      "fraiApproche": true,
      "heureRetourDep": null,
      "zone": null,
      "totalTa": 0,
      "aPreparer": null,
      "aLivrer": null,
      "vehCodeDms": null,
      "priorite": null,
      "motifAnnul": null,
      "prjCodeD": null,
      "excluDoc": true,
      "imprDoc": true,
      "salCodeDis": null,
      "echPeriodique": true,
      "typeEchelon": null,
      "nbreEchea": 0,
      "dt1Ech": DateTime.now().toString(),
      "sStype": null,
      "codeContrat": null,
      "budCode": null,
      "lbdStructure": null,
      "aIntegrer": true,
      "statutFicheMandat": null,
      "codeOrdo": null,
      "codeProvisoireManda": null,
      "usrcon": null,
      "batCode": null,
      "salleCode": AppUrl.user.salCode,
      "etageCode": null,
      "espaceCode": null,
      "salCodeAffect": null,
      "restoPriorite": 0,
      "idTable": null,
      "nbCouverts": 0,
      "segne": true,
      "fapproche": true,
      "docId": 0,
      "vehCode": AppUrl.user.localDepot!.id!,
      "isPrestation": true,
      "cntReception": true,
      "remNet": 0,
      "pieceDf": null,
      "longitude": currentLocation!.longitude,
      "latitude": currentLocation!.latitude,
      "oppoCode": widget.client.idOpp,
      "signature": null,
      "lignes": products,
      "produitDtos": products
    };

    http.Response req = await http.post(Uri.parse(AppUrl.retours),
        body: jsonEncode(jsonObject),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
    print("res return code: ${req.statusCode}");
    print("res return body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      widget.client.command!.type = 'Retour';
      HttpRequestApp httpRequestApp = HttpRequestApp();
      await httpRequestApp.sendItinerary('RET');
      var res = json.decode(req.body);
      if (widget.client.email != null)
        await httpRequestApp.sendEmail(res['numero'],
            widget.client.command!.type!, '${widget.client.email}');
      showMessage(
          message: 'Bon de retour créé avec succès',
          context: context,
          color: primaryColor);
      Navigator.pushNamedAndRemoveUntil(context, '/return', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de creation de bon de retour '),
        ),
      );
    }
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
}

class CommandItem extends StatefulWidget {
  final Product product;
  final Command command;
  final VoidCallback callback;

  const CommandItem(
      {super.key,
      required this.product,
      required this.command,
      required this.callback});

  @override
  State<CommandItem> createState() => _CommandItemState();
}

class _CommandItemState extends State<CommandItem> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    ConfirmationDialog confirmationDialog = ConfirmationDialog();
    return GestureDetector(
      onTap: () {
        setState(() {
          isVisible = !isVisible;
        });
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Slidable(
              startActionPane: ActionPane(motion: ScrollMotion(), children: [
                SlidableAction(
                  flex: 5,
                  onPressed: (_) async {
                    bool confirmed = await confirmationDialog
                        .showConfirmationDialog(context, 'deleteProduct');
                    if (confirmed) {
                      setState(() {
                        final provider = Provider.of<ProductProvider>(context,
                            listen: false);
                        provider.removeProduct(widget.product, widget.command);
                        widget.callback();
                      });
                    }
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                  label: 'Supprimer',
                ),
              ]),
              child: Container(
                width: double.infinity,
                height: 115,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        height: 60,
                        width: 70,
                        child: (widget.product.image == null)
                            ? Icon(
                                Icons.image_not_supported_outlined,
                              )
                            : Image.network(
                                '${widget.product.image}',
                                // Replace with your image URL
                                fit: BoxFit
                                    .cover, // Adjust the fit as needed (cover, contain, etc.)
                              )),
                    // Text('(${widget.product.quantity})',
                    //     style: Theme.of(context)
                    //         .textTheme
                    //         .headline4!
                    //         .copyWith(color: primaryColor)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          child: Text(
                            '${widget.product.name}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: primaryColor),
                          ),
                        ),
                        Text('${widget.product.category} ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(color: Colors.grey)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Prix unitaire :',
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(),
                        ),
                        Text(
                          '${AppUrl.formatter.format(widget.product.price)} DZD',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: primaryColor),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total ${AppUrl.formatter.format(widget.product.totalWitoutTaxes)} DZD ',
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    color: primaryColor,
                                  ),
                        ),
                        Text(
                          'TVA ${AppUrl.formatter.format(widget.product.priceTVA)} DZD ',
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    color: primaryColor,
                                  ),
                        ),
                        Text(
                          'TTC ${AppUrl.formatter.format(widget.product.total)} DZD',
                          style:
                              Theme.of(context).textTheme.headline5!.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          // to increment
                          onPressed: () {
                            setState(() {
                              final provider = Provider.of<ProductProvider>(
                                  context,
                                  listen: false);
                              provider.incrementQuantity(
                                  widget.product, widget.command);
                              widget.callback();
                            });
                          },
                          icon: Container(
                            height: 23,
                            width: 23,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        Text(
                          '${widget.product.quantity}',
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        IconButton(
                          // to decrement
                          onPressed: () {
                            setState(() async {
                              final provider = Provider.of<ProductProvider>(
                                  context,
                                  listen: false);
                              bool confirmed;
                              if (widget.product.quantity == 1) {
                                if (widget.command.nbProduct == 1) {
                                  // remove command
                                  confirmed = await confirmationDialog
                                      .showConfirmationDialog(
                                          context, 'deleteCommand');
                                } else {
                                  // remove product
                                  confirmed = await confirmationDialog
                                      .showConfirmationDialog(
                                          context, 'deleteProduct');
                                  if (confirmed) {
                                    provider.removeProduct(
                                        widget.product, widget.command);
                                    widget.callback();
                                  }
                                }
                              } else {
                                provider.decrementQuantity(
                                    widget.product, widget.command);
                                widget.callback();
                              }
                            });
                          },
                          icon: Container(
                            height: 23,
                            width: 23,
                            decoration: BoxDecoration(
                              border: Border.all(color: grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Icon(
                              Icons.remove_outlined,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: isVisible,
            child: Container(
              margin: EdgeInsets.all(8),
              width: double.infinity,
              height: 180,
              color: backgroundColor,
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    child: (widget.product.image == null)
                        ? Icon(Icons.image_not_supported_outlined)
                        : Image.network(
                            '${widget.product.image}', // Replace with your image URL
                            fit: BoxFit
                                .cover, // Adjust the fit as needed (cover, contain, etc.)
                          ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    padding:
                        EdgeInsets.only(left: 8, right: 0, top: 8, bottom: 8),
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          child: Text(
                            '${widget.product.name}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor),
                          ),
                        ),
                        Text('${widget.product.category} ',
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.grey)),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: primaryColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Quantité stock',
                                  style: Theme.of(context).textTheme.bodyText1),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CommandDialog(widget.product);
                                    },
                                  ).then((value) {
                                    setState(() {
                                      widget.product.calculateTotal();
                                      widget.callback();
                                    });
                                  });
                                },
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 4),
                                    child: Center(
                                        child: Text(
                                      '${widget.product.quantityStock}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor),
                                    )),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CommandDialog(widget.product);
                              },
                            ).then((value) {
                              setState(() {
                                widget.product.calculateTotal();
                                widget.callback();
                              });
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: primaryColor,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Remise',
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 4),
                                    child: Center(
                                        child: Text(
                                      '${widget.product.remise} %',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor),
                                    )),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CommandDialog(widget.product);
                              },
                            ).then((value) {
                              setState(() {
                                widget.product.calculateTotal();
                                widget.callback();
                              });
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: primaryColor,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('TVA',
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 4),
                                    child: Center(
                                        child: Text(
                                      '${widget.product.tva} %',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor),
                                    )),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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