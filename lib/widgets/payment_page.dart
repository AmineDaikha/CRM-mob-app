import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/http_request.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/constants/utils.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/payment.dart';
import 'package:mobilino_app/providers/payment_provider.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/text_field.dart';
import 'package:provider/provider.dart';

import 'confirmation_dialog.dart';

class PaymentPage extends StatefulWidget {
  final Client client;
  String? initalValue;
  final int? toStat;

  PaymentPage({super.key, required this.client, this.initalValue, this.toStat});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool cash = true;
  bool chec = false;
  final TextEditingController _numberController = TextEditingController();
  String? enterValue;
  final formKey = GlobalKey<FormState>();
  final GlobalKey<_CurrentPaymentWidgetState> currentPaymentWidgetKey =
  GlobalKey<_CurrentPaymentWidgetState>();
  final GlobalKey<_AffectedPaymentWidgetState> affectedPaymentWidgetKey =
  GlobalKey<_AffectedPaymentWidgetState>();

  @override
  void initState() {
    super.initState();
    if (widget.initalValue != null)
      _numberController.text = widget.initalValue!;
    print('stat : ${widget.toStat}');
  }

  void handleCheckbox1(bool? value) {
    setState(() {
      final provider = Provider.of<PaymentProvider>(context, listen: false);
      provider.paymentList.clear();
      provider.paymentListSelected.clear();
      cash = value!;
      chec = !value;
    });
  }

  void handleCheckbox2(bool? value) {
    setState(() {
      final provider = Provider.of<PaymentProvider>(context, listen: false);
      provider.paymentList.clear();
      provider.paymentListSelected.clear();
      chec = value!;
      cash = !value;
    });
  }

  Future<void> fetchData() async {
    String url = AppUrl.echeances +
        AppUrl.user.etblssmnt!.code! +
        '/' +
        widget.client.id!;
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res pay code : ${req.statusCode}");
    print("res pay body: ${req.body}");
    final provider = Provider.of<PaymentProvider>(context, listen: false);
    if (req.statusCode == 200) {
      provider.paymentList = [];
      List<dynamic> data = json.decode(req.body);
      data.toList().forEach((element) {
        try {
          print('reçu: ${element['echRecu']}');
          var s = element['echArecev'];
          provider.paymentList.add(Payment(
              currentPaid: 0,
              date: DateTime.parse(element['echDate']),
              code: element['echNumero'],
              total: element['echArecev'],
              paid: element['echRecu']));
        } catch (e, stackTrace) {
          print('Exception: $e');
          print('Stack trace: $stackTrace');
        }
      });
      provider.notifyListeners();
      print('sizeof: ${provider.paymentList.length}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initalValue == null) widget.initalValue = '';
    final payments = Provider.of<PaymentProvider>(context, listen: false);
    print(
        'etabl: ${AppUrl.user.etblssmnt!.code} and pcf code: ${widget.client
            .id}');
    return FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Future is still running, return a loading indicator or some placeholder.
            return Center(
              child: Row(
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                  ),
                  Center(
                    child: Container(
                      color: Colors.white,
                      margin: EdgeInsets.only(left: 15),
                      child: Text(
                        'Loading...',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // There was an error in the future, handle it.
            return Text('Error: ${snapshot.error}');
          }
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.white, // Set icon color to white
              ),
              backgroundColor: Theme
                  .of(context)
                  .primaryColor,
              title: ListTile(
                title: Text(
                  'Pour : ${widget.client.name}',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline4!
                      .copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${AppUrl.formatter.format(widget.client.totalPay)} DZD',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline5!
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
            body: Form(
              key: formKey,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                activeColor: primaryColor,
                                value: cash,
                                onChanged: handleCheckbox1,
                              ),
                              Text(
                                'Espèces',
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .headline5,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                activeColor: primaryColor,
                                value: chec,
                                onChanged: handleCheckbox2,
                              ),
                              Text(
                                'Chèque',
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .headline5,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          onChanged: (value) {
                            payments.restPayment(_numberController.text.trim());
                            //payments.notifyListeners();
                            currentPaymentWidgetKey.currentState
                                ?.setState(() {});
                            affectedPaymentWidgetKey.currentState
                                ?.setState(() {});
                          },
                          decoration: txtInputDecoration.copyWith(
                              labelText: 'valeur', hintText: 'DZD'),
                          controller: _numberController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            try {
                              double d = double.parse(value!);
                            } catch (_) {
                              return 'Svp, entrer la somme valide';
                            }
                            if (value!.isEmpty) {
                              return 'Svp, entrer la somme';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CurrentPaymentWidget(
                          key: currentPaymentWidgetKey,
                          payments: payments,
                          numberController: _numberController),
                      SizedBox(
                        height: 20,
                      ),
                      AffectedPaymentWidget(
                          key: affectedPaymentWidgetKey,
                          payments: payments,
                          numberController: _numberController),
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: (payments.paymentList.length == 0)
                                ? Center(
                              child: Text(
                                'Aucune echeance!',
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .headline3,
                              ),
                            )
                                : ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) =>
                                    EchItem(
                                      client: widget.client,
                                      payment: payments.paymentList[index],
                                      currentPaymentWidgetKey:
                                      currentPaymentWidgetKey,
                                      affectedPaymentWidgetKey:
                                      affectedPaymentWidgetKey,
                                      numberController: _numberController,
                                    ),
                                itemCount: payments.paymentList.length),
                          ))
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 70,
                      margin: EdgeInsets.only(bottom: 10),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  primaryColor), // Change the color here
                            ),
                            onPressed: () async {
                              if (formKey.currentState != null &&
                                  formKey.currentState!.validate()) {
                                if (payments.paymentListSelected.isEmpty) {
                                  showMessage(
                                      message: 'Choisir en ns une échéances',
                                      context: context,
                                      color: Colors.red);
                                } else if (payments.restPayment(
                                    _numberController.text.trim()) >
                                    0) {
                                  showMessage(
                                      message: 'Choisir des autres échéances',
                                      context: context,
                                      color: Colors.red);
                                } else {
                                  ConfirmationDialog confirmationDialog =
                                  ConfirmationDialog();
                                  bool confirmed = await confirmationDialog
                                      .showConfirmationDialog(
                                      context, 'confirmPayment');
                                  if (confirmed) {
                                    sendPayment(context);
                                  }
                                }
                              }
                            },
                            child: Text(
                              'Confirmer',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> sendPayment(BuildContext context) async {
    final provider = Provider.of<PaymentProvider>(context, listen: false);
    List<Map<String, dynamic>> exheances = [];
    //String url = AppUrl.encaisser + AppUrl.user.salCode!;
    String url = AppUrl.encaisser;
    String txtCharg = '';
    String type;
    if (cash) {
      type = 'E';
    } else {
      type = 'C';
    }

    Map<String, dynamic> jsonEcheance = {};
    double montant = double.parse(_numberController.text.trim());
    for (int i = 0; i < provider.paymentListSelected.length; i++) {
      double itemMonant;
      if (montant > provider.paymentListSelected[i].currrentRest) {
        itemMonant = provider.paymentListSelected[i].currrentRest;
        montant = montant - itemMonant;
      } else
        itemMonant = montant;
      String item = '${provider.paymentListSelected[i].code}';
      jsonEcheance[item] = itemMonant;
    }
    Map<String, dynamic> jsonObject = {
      "montant": _numberController.text.trim(),
      "echeancesIds": jsonEcheance,
      "typeReglement": type,
      "livreurUsername": AppUrl.user.userId,
      "pcfCode": widget.client.id,
      "etbCode": AppUrl.user.etblssmnt!.code,
      "livreurSalCode": AppUrl.user.salCode,
    };

    print('url sendPay: $url and json: $jsonObject');
    http.Response req =
    await http.post(Uri.parse(url), body: jsonEncode(jsonObject), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res sendPay code: ${req.statusCode}");
    print("res sendPay body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      showMessage(
          color: primaryColor,
          message: 'Encaissement avec succès',
          context: context);
      if (widget.toStat == null) {
        HttpRequestApp().sendItinerary('ENC');
        Navigator.pushNamedAndRemoveUntil(
            context, '/payment', (route) => false);
      } else {
        changeOppState(widget.client, widget.toStat!).then((value) {
          if (value) {
            HttpRequestApp().sendItinerary('ENC');
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          } else
            showMessage(
                color: Colors.red,
                message: 'Échec d\'encaissement ',
                context: context);
        });
      }
    } else {
      showMessage(
          color: Colors.red,
          message: 'Échec d\'encaissement ',
          context: context);
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

class CurrentPaymentWidget extends StatefulWidget {
  const CurrentPaymentWidget({
    super.key,
    required this.payments,
    required TextEditingController numberController,
  }) : _numberController = numberController;

  final PaymentProvider payments;
  final TextEditingController _numberController;

  @override
  State<CurrentPaymentWidget> createState() => _CurrentPaymentWidgetState();
}

class _CurrentPaymentWidgetState extends State<CurrentPaymentWidget> {
  double value = 0;

  @override
  Widget build(BuildContext context) {
    if (widget._numberController.text
        .trim()
        .isNotEmpty ||
        widget._numberController.text.trim() != null) {
      double initPayment = 0;
      if (widget._numberController.text
          .trim()
          .isNotEmpty)
        initPayment = double.parse(widget._numberController.text.trim());
      if (initPayment > widget.payments.sumOfRest())
        value = widget.payments.sumOfRest();
      else {
        value = initPayment;
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'Déja affecté : ',
          style: Theme
              .of(context)
              .textTheme
              .headline6,
        ),
        Text(
          '${AppUrl.formatter.format(value)} DZD',
          style: Theme
              .of(context)
              .textTheme
              .headline3!
              .copyWith(color: primaryColor),
        ),
      ],
    );
  }
}

class AffectedPaymentWidget extends StatefulWidget {
  const AffectedPaymentWidget({
    super.key,
    required this.payments,
    required TextEditingController numberController,
  }) : _numberController = numberController;

  final PaymentProvider payments;
  final TextEditingController _numberController;

  @override
  State<AffectedPaymentWidget> createState() => _AffectedPaymentWidgetState();
}

class _AffectedPaymentWidgetState extends State<AffectedPaymentWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'Reste à affecter',
          style: Theme
              .of(context)
              .textTheme
              .headline6,
        ),
        Text(
          '${AppUrl.formatter.format(widget.payments.restPayment(
              widget._numberController.text.trim()))} DZD',
          style: Theme
              .of(context)
              .textTheme
              .headline3!
              .copyWith(color: Colors.red),
        ),
      ],
    );
  }
}

class EchItem extends StatefulWidget {
  final Client client;
  final Payment payment;
  final GlobalKey<_CurrentPaymentWidgetState> currentPaymentWidgetKey;
  final GlobalKey<_AffectedPaymentWidgetState> affectedPaymentWidgetKey;
  final TextEditingController numberController;

  //final String paymentVal;

  const EchItem({
    super.key,
    required this.client,
    required this.payment,
    required this.currentPaymentWidgetKey,
    required this.affectedPaymentWidgetKey,
    required this.numberController,
  });

  @override
  State<EchItem> createState() => _EchItemState();
}

class _EchItemState extends State<EchItem> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<PaymentProvider>(context, listen: false);
    Color color = Colors.grey;
    if (widget.client.total == null) widget.client.total = 0.toString();
    if (double.parse(widget.client.total.toString()) > 0) {
      color = primaryColor;
    } else if (double.parse(widget.client.total.toString()) < 0) {
      color = Colors.red;
    }
    return InkWell(
      onTap: () {
        // showDialog(
        //     context: context,
        //     builder: (BuildContext context) {
        //       return PaymentDialog();
        //     });
      },
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Checkbox(
                  activeColor: primaryColor,
                  value: isSelected,
                  onChanged: (value) {
                    //provider.notifyListeners();
                    print(
                        'value ${widget.numberController.text
                            .trim()} restPayment: ${provider.restPayment(
                            widget.numberController.text.trim())}');
                    if (provider.restPayment(
                        widget.numberController.text.trim()) <=
                        0 &&
                        provider.sumOfRest() != 0 &&
                        isSelected != true) {
                      showMessage(
                          color: Colors.red,
                          message:
                          'Vous ne pouvez pas ajouter une autre écheance',
                          context: context);
                      widget.currentPaymentWidgetKey.currentState
                          ?.setState(() {});
                      widget.affectedPaymentWidgetKey.currentState
                          ?.setState(() {});
                      return;
                    }
                    setState(() {
                      isSelected = value!;
                      widget.payment.isChoosed = isSelected;
                      print(
                          'seleted size: ${provider.paymentListSelected
                              .length}');
                      widget.currentPaymentWidgetKey.currentState
                          ?.setState(() {});
                      widget.affectedPaymentWidgetKey.currentState
                          ?.setState(() {});
                    });
                  },
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Le reste : ${AppUrl.formatter.format(
                          widget.payment.currrentRest)} DZD',
                      style: Theme
                          .of(context)
                          .textTheme
                          .headline5!
                          .copyWith(color: primaryColor),
                    ),
                    Text(
                        'Total : ${AppUrl.formatter.format(
                            widget.payment.total)} DZD',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline6!
                            .copyWith(color: Colors.grey)),
                  ],
                ),
                Text(
                  ' ${DateFormat('yyyy-MM-dd HH:mm:ss').format(
                      widget.payment.date!)} ',
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: color, fontWeight: FontWeight.normal),
                ),
                SizedBox(
                  height: 10,
                )
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
