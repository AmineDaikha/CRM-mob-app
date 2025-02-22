import 'dart:convert';
import 'dart:io';
import 'package:dart_dev/dart_dev.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/http_request.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/product.dart';
import 'package:mobilino_app/screens/home_page/home_page.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/payment_page.dart';
import 'package:provider/provider.dart';
import 'package:mobilino_app/widgets/text_field.dart';

import 'confirmation_dialog.dart';

class AddPaymentDialog extends StatefulWidget {
  final Client client;

  const AddPaymentDialog({super.key, required this.client});

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _payment = TextEditingController();
  String title = '';
  String description = '';
  LatLng? currentLocation;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(20), // Adjust the radius value
      )),
      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      content: Container(
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20), // Adjust the radius value
                    )),
                height: 60,
                child: Center(
                    child: Text(
                  'Versement',
                  style: Theme.of(context)
                      .textTheme
                      .headline3!
                      .copyWith(color: Colors.white),
                )),
              ),
              Container(
                height: 100,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.client.command!.nbProduct}', // nb article
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Articles',
                          style:
                              Theme.of(context).textTheme.headline4!.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                        )
                      ],
                    ),
                    Container(
                      width: 2,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total : ${AppUrl.formatter.format(widget.client.command!.total)} DZD',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Date :${DateFormat('yyyy-MM-ddTHH:mm:ss').format(widget.client.command!.date)}',
                          style: Theme.of(context)
                              .textTheme
                              .headline5!
                              .copyWith(fontWeight: FontWeight.normal),
                        ),
                        Text(
                          '',
                          style:
                              Theme.of(context).textTheme.headline5!.copyWith(
                                    fontWeight: FontWeight.normal,
                                  ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey,
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  'Vous déclarez avoir reçu la somme de : ',
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(fontWeight: FontWeight.normal),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              customTextField(
                obscure: false,
                controller: _payment,
                hint: 'DZD',
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  'Comptez votre argent, puis validez.',
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontStyle: FontStyle.italic),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(30))),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Retour",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      onPressed: () async {
                        ConfirmationDialog confirmationDialog =
                            ConfirmationDialog();
                        bool confirmed = await confirmationDialog
                            .showConfirmationDialog(context, 'confirmDelivr');
                        if (confirmed) {
                          _getCurrentLocation().then((value) {
                            if (value) {
                              sendDocument(context).then((valDeliver) {
                                if (valDeliver) {
                                  int state = 0;
                                  if (_payment.text.trim() == '0' ||
                                      _payment.text.trim().isEmpty) {
                                    state = 3;
                                    changeOppState(widget.client, state)
                                        .then((value) {
                                      if (value) {
                                        HttpRequestApp().sendItinerary('LIV');
                                        Navigator.pushNamedAndRemoveUntil(
                                            context, '/home', (route) => false);
                                      }
                                    });
                                  } else {
                                    state = 3;
                                    changeOppState(widget.client, state)
                                        .then((value) {
                                      if (value) {
                                        state = 5;

                                        // Navigator.pushNamedAndRemoveUntil(
                                        //     context, '/home', (route) => false)
                                        PageNavigator(ctx: context)
                                            .nextPageOnly(page: HomePage());

                                        PageNavigator(ctx: context).nextPage(
                                            page: PaymentPage(
                                          client: widget.client,
                                          toStat: 5,
                                          initalValue: _payment.text.trim(),
                                        ));
                                      }
                                    });

                                    // to payment page
                                  }
                                } else {
                                  showMessage(
                                      message:
                                          'Échec de creation de bon de livraison',
                                      context: context,
                                      color: Colors.red);
                                }
                              });
                            }
                          });
                        }
                      },
                      child: const Text(
                        "Valider",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> changeOppState(Client client, int state) async {
    var body = jsonEncode({
      "id": client.idOpp,
      "equipe": state,
    });
    String url = AppUrl.opportunitiesChangeState + '${client.idOpp}/$state';
    print('res url $url');
    http.Response req = await http.put(Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
    print("res state code : ${req.statusCode} ");
    print("res state body: ${req.body}");
    if (req.statusCode == 200) {
      //Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      return true;
    } else {
      print('Failed to load data');
      return false;
    }
  }

  // Function to fetch JSON data from an API
  Future<bool> sendDocument(BuildContext context) async {
    List<Map<String, dynamic>> products = [];
    List<Map<String, dynamic>> produitDtos = [];
    for (Product product in widget.client.command!.products) {
      Map<String, dynamic> jsonProduct = {
        "codeProduit": product.id,
        "pcfCode": widget.client.id,
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
      Map<String, dynamic> jsonProduct2 = {
        "codeProduit": product.id,
        "lib": product.name,
        "cBar": product.codeBar,
        "tva": product.tva,
        "prixVente": product.price,
        "prixVenteRemise": product.priceNet,
        "remise": product.remise,
        "qts": product.quantity,
        "DepStock": AppUrl.user.localDepot!.id,
      };
      produitDtos.add(jsonProduct2);
    }

    Map<String, dynamic> jsonObject = {
      "numero": null,
      "etbCode": AppUrl.user.etblssmnt!.code,
      "piece": null,
      "rpiece": widget.client.command!.id,
      "type": "C",
      "stype": "L",
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
      "pcfCode": widget.client.id,
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
      "depCode": AppUrl.user.localDepot!.id!, // source
      "tdepot": null, // destination
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
      "codeVehicule": null,
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
      "etbTcode": null,
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
      "salleCode": null,
      "etageCode": null,
      "espaceCode": null,
      "salCodeAffect": null,
      "restoPriorite": 0,
      "idTable": null,
      "nbCouverts": 0,
      "segne": true,
      "fapproche": true,
      "docId": 0,
      "vehCode": null,
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
    String url = AppUrl.livraisons;
    print('urlis: $url');
    widget.client.command!.res!['rpiece'] = widget.client.command!.id;
    widget.client.command!.res!['produitDtos'] = produitDtos;
    widget.client.command!.res!['depCode'] = AppUrl.user.localDepot!.id;
    widget.client.command!.res!['salCode'] = AppUrl.user.salCode;

    Map<String, dynamic> jsonDelevery = widget.client.command!.res!;
    //var res = jsonEncode(widget.client.command!.res.toString());
    http.Response req = await http.post(Uri.parse(url),
        body: jsonEncode(jsonDelevery),
        //body: jsonDelevery,
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
    print("res docDelivred code : ${req.statusCode}");
    print("res docDelivred body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      widget.client.command!.type = 'Livraison';
      HttpRequestApp httpRequestApp = HttpRequestApp();
      var res = json.decode(req.body);
      if (widget.client.email != null)
        await httpRequestApp.sendEmail(res['numero'],
            widget.client.command!.type!, '${widget.client.email}');
      return true;
    } else {
      return false;
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

  void addTodo() {
    final isValid = _formkey.currentState!.validate();
    if (!isValid) {
      return;
    } else {
      // final todo = Todo(
      //   id: DateTime.now().toString(),
      //   title: title,
      //   description: description,
      //   createdTime: DateTime.now(),
      // );
      // final provider = Provider.of<TodoProvider>(context, listen: false);
      // provider.addTodo(todo);
      Navigator.of(context).pop();
    }
  }
}
