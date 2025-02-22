import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/text_field.dart';
import 'package:http/http.dart' as http;

class AddClientPage2 extends StatefulWidget {
  const AddClientPage2({super.key});

  static const String routeName = '/clients/add1/add2';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => AddClientPage2(),
    );
  }

  @override
  State<AddClientPage2> createState() => _AddClientPage2State();
}

class _AddClientPage2State extends State<AddClientPage2> {
  LatLng? currentLocation;
  final TextEditingController road = TextEditingController();
  final TextEditingController way = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController lat = TextEditingController();
  final TextEditingController lon = TextEditingController();
  final TextEditingController familly = TextEditingController();
  final TextEditingController surface = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool isChecked = false;

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
                Row(
                  children: [
                    Expanded(
                      child: customTextField(
                        obscure: false,
                        controller: road,
                        hint: 'Rue',
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: customTextField(
                        obscure: false,
                        controller: way,
                        hint: 'Quartier',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: customTextField(
                        obscure: false,
                        controller: city,
                        hint: 'ville',
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
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
                      child: customTextField(
                        obscure: false,
                        controller: lat,
                        hint: 'Latitude',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: customTextField(
                        obscure: false,
                        controller: lon,
                        hint: 'Longitude',
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: customTextFieldEmpty(
                        obscure: false,
                        controller: familly,
                        hint: 'Famille',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: customTextFieldEmpty(
                        obscure: false,
                        controller: surface,
                        hint: 'Surface en m²',
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
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
                          AppUrl.client.city = city.text.trim();
                          AppUrl.client.location = currentLocation;
                          AppUrl.client.way = way.text.trim();
                          AppUrl.client.familly = familly.text.trim();
                          AppUrl.client.surface = surface.text.trim();
                          showLoaderDialog(context);
                          fetchData().then((value) {
                            Navigator.pop(context);
                            if (value) {
                              showMessage(
                                  message: 'Client / Prospect créé avec succès',
                                  context: context,
                                  color: primaryColor);
                              Navigator.pop(context);
                              Future.delayed(Duration(seconds: 4)).then((value){
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/clients', (route) => false);
                              });
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
    ;
  }

  Future<bool> fetchData() async {
    var body = jsonEncode({
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
    http.Response req =
        await http.post(Uri.parse(AppUrl.tiers), body: body, headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
    });
    print("res tier code : ${req.statusCode}");
    print("res tier body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      print('Failed to load data');
    }
    return false;
  }

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
