import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/text_field.dart';

import 'add_client_page2.dart';

class AddClientPage1 extends StatefulWidget {
  const AddClientPage1({super.key});

  static const String routeName = '/clients/add1';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => AddClientPage1(),
    );
  }

  @override
  State<AddClientPage1> createState() => _AddClientPage1State();
}

final List<String> options = ['Prospect', 'Client', 'Fournisseur'];

class _AddClientPage1State extends State<AddClientPage1> {
  final TextEditingController code = TextEditingController();
  final TextEditingController nameRs = TextEditingController();
  final TextEditingController namRS2 = TextEditingController();
  final TextEditingController tel1 = TextEditingController();
  final TextEditingController tel2 = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController sold = TextEditingController();
  final TextEditingController lat = TextEditingController();
  final TextEditingController lon = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  bool isChecked = false;
  LatLng? currentLocation;
  String currentOption = options[0];

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        print('latLng: ${position.latitude} ${position.longitude}');
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set icon color to white
        ),
        backgroundColor: primaryColor,
        title: Text(
          'Ajouter un client',
          style: Theme.of(context)
              .textTheme
              .headline2!
              .copyWith(color: Colors.white),
        ),
      ),
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset(
                  'assets/addclient.png',
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  height: 10,
                ),
                customTextFieldEmpty(
                  obscure: false,
                  controller: code,
                  hint: 'code',
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: customTextField(
                        obscure: false,
                        controller: nameRs,
                        hint: 'Nom',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: customTextFieldEmpty(
                        obscure: false,
                        controller: namRS2,
                        hint: 'Nom 2',
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: customTextFieldEmpty(
                        obscure: false,
                        controller: tel1,
                        hint: 'Téléphone 1',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: customTextFieldEmpty(
                        obscure: false,
                        controller: tel2,
                        hint: 'Téléphone 2',
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                customTextFieldEmpty(
                  obscure: false,
                  controller: email,
                  hint: 'Adresse e-mail ',
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                      child: Checkbox(
                          activeColor: Theme.of(context).primaryColor,
                          checkColor: Colors.white,
                          value: isChecked,
                          onChanged: (_) {
                            setState(() {
                              isChecked = !isChecked;
                              if (isChecked) {
                                _getCurrentLocation().then((value) {
                                  if (currentLocation != null) {
                                    lat.text =
                                        currentLocation!.latitude.toString();
                                    lon.text =
                                        currentLocation!.longitude.toString();
                                  }
                                });
                              }
                            });
                          }),
                    ),
                    Expanded(
                      child: customTextFieldEmpty(
                        obscure: false,
                        controller: lat,
                        hint: 'Latitude',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: customTextFieldEmpty(
                        obscure: false,
                        controller: lon,
                        hint: 'Longitude',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              options[0],
                              style: TextStyle(color: primaryColor, fontSize: 11),
                            ),
                            leading: Radio(
                              activeColor: primaryColor,
                              value: options[0],
                              groupValue: currentOption,
                              onChanged: (value) {
                                setState(() {
                                  currentOption = value.toString();
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: Text(
                              options[1],
                              style: TextStyle(color: primaryColor, fontSize: 11),
                            ),
                            leading: Radio(
                              value: options[1],
                              activeColor: primaryColor,
                              groupValue: currentOption,
                              onChanged: (value) {
                                setState(() {
                                  currentOption = value.toString();
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: Text(
                              options[2],
                              style: TextStyle(color: primaryColor, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                            leading: Radio(
                              value: options[2],
                              activeColor: primaryColor,
                              groupValue: currentOption,
                              onChanged: (value) {
                                setState(() {
                                  currentOption = value.toString();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: customTextFieldEmpty(
                        obscure: false,
                        controller: sold,
                        hint: 'Solde',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                SizedBox(
                    width: 200,
                    height: 45,
                    // todo 7
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.indigo,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      onPressed: () {
                        if (_formkey.currentState != null &&
                            _formkey.currentState!.validate()) {
                          String type = '';
                          if (options.indexOf(currentOption) == 0)
                            type = 'P';
                          else if (options.indexOf(currentOption) == 1)
                            type = 'C';
                          else if (options.indexOf(currentOption) == 1)
                            type = 'F';
                          print('type: $type');
                          AppUrl.client = Client(
                            code: code.text.trim(),
                            name: nameRs.text.trim(),
                            name2: namRS2.text.trim(),
                            phone: tel1.text.trim(),
                            phone2: tel2.text.trim(),
                            email: email.text.trim(),
                            total: sold.text.trim(),
                            type: type,
                          );
                          AppUrl.client.location = currentLocation;
                          PageNavigator(ctx: context)
                              .nextPage(page: AddClientPage2());
                        }
                      },
                      child: const Text(
                        "Continuer",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )),
                SizedBox(height: 10,),
                SizedBox(
                    width: 200,
                    height: 45,
                    // todo 7
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      onPressed: () {
                        if (_formkey.currentState != null &&
                            _formkey.currentState!.validate()) {
                          String type = '';
                          if (options.indexOf(currentOption) == 0)
                            type = 'P';
                          else if(options.indexOf(currentOption) == 1)
                            type = 'C';
                          else
                          type = 'F';
                          print('type: $type');
                          AppUrl.client = Client(
                            code: code.text.trim(),
                            name: nameRs.text.trim(),
                            name2: namRS2.text.trim(),
                            phone: tel1.text.trim(),
                            phone2: tel2.text.trim(),
                            email: email.text.trim(),
                            total: sold.text.trim(),
                            type: type,
                          );
                          AppUrl.client.location = currentLocation;
                          showLoaderDialog(context);
                          sendTier().then((value) {
                            Navigator.pop(context);
                            if (value) {
                              showMessage(
                                  message: 'Client / Prospect créé avec succès',
                                  context: context,
                                  color: primaryColor);
                              Navigator.pop(context);
                            } else {
                              showMessage(
                                  message:
                                  'Échec de l\'ajout du client / prospect',
                                  context: context,
                                  color: Colors.red);
                            }
                          });
                        }
                      },
                      child: const Text(
                        "Valider",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> sendTier() async {
    print('ff: ${AppUrl.client.location}');
    var body;
    if(AppUrl.client.location == null){
      body =  jsonEncode({
        "code": '${AppUrl.client.code}',
        "type": "${AppUrl.client.type}",
        "rs": "${AppUrl.client.name}",
        "rs2": "${AppUrl.client.name2}",
        "civilite": null,
        "familleId": null,
        "sFamilleId": null,
        "siret": null,
        "rcs": null,
        "ape": null,
        "nii": null,
        "tin": null,
        "dateImmat": null,
        "status": null,
        "inscription": null,
        "capitalSoc": null,
        "capital": null,
        "effectif": null,
        "etablissement": AppUrl.user.etblssmnt!.code,
        "dateCree": null,
        "userCree": null,
        "dateMaj": null,
        "userMaj": null,
        "deleted": null,
        "dateSupp": null,
        "userSupp": null,
        "npai": null,
        "rue": null,
        "cp": null,
        "ville": "${AppUrl.client.city}",
        "region": null,
        "etat": null,
        "pays": null,
        "email": "${AppUrl.client.email}",
        "url": null,
        "tel1": "${AppUrl.client.phone}",
        "tel2": "${AppUrl.client.phone2}",
        "fC1": null,
        "fC2": null,
        "fC3": null,
        "fC4": null,
        "fC5": null,
        "longitude": lon.text.trim(),
        "latitude":lat.text.trim(),
        // "longitude": 33.3546854,//AppUrl.client.location!.longitude,
        // "latitude":  6.8431943//AppUrl.client.location!.latitude
      });
    }else{
      body =  jsonEncode({
        "type": "${AppUrl.client.type}",
        "rs": "${AppUrl.client.name}",
        "rs2": "${AppUrl.client.name2}",
        "civilite": null,
        "familleId": null,
        "sFamilleId": null,
        "siret": null,
        "rcs": null,
        "ape": null,
        "nii": null,
        "tin": null,
        "dateImmat": null,
        "status": null,
        "inscription": null,
        "capitalSoc": null,
        "capital": null,
        "effectif": null,
        "etablissement": AppUrl.user.etblssmnt!.code,
        "dateCree": null,
        "userCree": null,
        "dateMaj": null,
        "userMaj": null,
        "deleted": null,
        "dateSupp": null,
        "userSupp": null,
        "npai": null,
        "rue": null,
        "cp": null,
        "ville": "${AppUrl.client.city}",
        "region": null,
        "etat": null,
        "pays": null,
        "email": "${AppUrl.client.email}",
        "url": null,
        "tel1": "${AppUrl.client.phone}",
        "tel2": "${AppUrl.client.phone2}",
        "fC1": null,
        "fC2": null,
        "fC3": null,
        "fC4": null,
        "fC5": null,
        "longitude": AppUrl.client.location!.longitude,
        "latitude": AppUrl.client.location!.latitude,
        // "longitude": 33.3546854,//AppUrl.client.location!.longitude,
        // "latitude":  6.8431943//AppUrl.client.location!.latitude
      });
    }
    http.Response req =
    await http.post(Uri.parse(AppUrl.tiers), body: body, headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
    });
    print("res add tier code : ${req.statusCode}");
    print("res add tier body: ${req.body}");

    if (req.statusCode == 200 || req.statusCode == 201) {
      var res = json.decode(req.body);
      AppUrl.client.id = res['code'];
      AppUrl.selectedClient = AppUrl.client;
      return true;
    } else {
      print('Failed to load data');
    }
    return false;
  }
}
