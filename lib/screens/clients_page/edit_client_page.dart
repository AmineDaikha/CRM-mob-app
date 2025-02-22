import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/text_field.dart';

import '../activities_pages/activity_list_page.dart';

class EditClientPage extends StatefulWidget {
  const EditClientPage({super.key, required this.client});

  final Client client;

  @override
  State<EditClientPage> createState() => _EditClientPageState();
}

final List<String> options = ['Prospect', 'Client', 'Fournisseur'];

class _EditClientPageState extends State<EditClientPage> {
  final TextEditingController nameRs = TextEditingController();
  final TextEditingController namRS2 = TextEditingController();
  final TextEditingController tel1 = TextEditingController();
  final TextEditingController tel2 = TextEditingController();
  final TextEditingController email = TextEditingController();
  LatLng? currentLocation;
  final TextEditingController city = TextEditingController();
  final TextEditingController lat = TextEditingController();
  final TextEditingController lon = TextEditingController();
  final TextEditingController road = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool isChecked = false;
  String currentOption = options[0];

  @override
  void initState() {
    super.initState();
    if (widget.client.type == 'P')
      currentOption = options[0];
    else if(widget.client.type == 'C')
      currentOption = options[1];
    else
      currentOption = options[2];
    if (widget.client.name != null) nameRs.text = widget.client.name!;
    if (widget.client.name2 != null) namRS2.text = widget.client.name2!;
    if (widget.client.phone != null) tel1.text = widget.client.phone!;
    if (widget.client.phone2 != null) tel2.text = widget.client.phone2!;
    if (widget.client.email != null) email.text = widget.client.email!;
    if (widget.client.city != null) city.text = widget.client.city!;
    if (widget.client.road != null) road.text = widget.client.road!;
    if (widget.client.location != null) {
      lat.text = widget.client.location!.latitude.toString();
      lon.text = widget.client.location!.longitude.toString();
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
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modifier le Tier : ',
              style: Theme.of(context)
                  .textTheme
                  .headline3!
                  .copyWith(color: Colors.white),
            ),
            Text(
              '${widget.client.name}',
              style: Theme.of(context)
                  .textTheme
                  .headline4!
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formkey,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Center(
            child: ListView(
              children: [
                SizedBox(
                  height: 50,
                ),
                // Image.asset(
                //   'assets/addclient.png',
                //   fit: BoxFit.cover,
                // ),
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
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: customTextFieldEmpty(
                        obscure: false,
                        controller: road,
                        hint: 'Rue',
                      ),
                    ),
                    SizedBox(width: 5),
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
                              style: TextStyle(color: primaryColor, fontSize: 11),
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
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                customTextFieldEmpty(
                  obscure: false,
                  controller: city,
                  hint: 'ville',
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
                SizedBox(
                    width: 200,
                    height: 45,
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
                          else if (options.indexOf(currentOption) == 1)
                            type = 'C';
                          else
                            type = 'F';
                          print('type: $type');
                          AppUrl.client = Client(
                            id: widget.client.id,
                            res: widget.client.res,
                            name: nameRs.text.trim(),
                            name2: namRS2.text.trim(),
                            phone: tel1.text.trim(),
                            phone2: tel2.text.trim(),
                            email: email.text.trim(),
                            type: type,
                          );
                          AppUrl.client.city = city.text.trim();
                          AppUrl.client.location = currentLocation;
                          print(
                              'client: ${AppUrl.client.id} ${AppUrl.client.res}');
                          showLoaderDialog(context);
                          sendEditClient(AppUrl.client).then((value) {
                            Navigator.pop(context);
                            if (value) {
                              showMessage(
                                  message: 'Tier a été modifiée avec succès',
                                  context: context,
                                  color: primaryColor);
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/clients', (route) => false);
                            } else {
                              showMessage(
                                  message: 'Échec de modification de Tier',
                                  context: context,
                                  color: Colors.red);
                            }
                          });
                        }
                      },
                      child: const Text(
                        "Modifier",
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

  Future<bool> sendEditClient(Client client) async {
    String url = AppUrl.tiers + '/${client.id}';
    print('res url $url');

    client.res['type'] = client.type;
    client.res['rs'] = client.name;
    client.res['rs2'] = client.name2;
    client.res['ville'] = client.city;
    client.res['email'] = client.email;
    client.res['tel1'] = client.phone;
    client.res['tel2'] = client.phone2;
    if (client.location != null) {
      client.res['longitude'] = client.location!.longitude;
      client.res['latitude'] = client.location!.latitude;
    }

    http.Response req = await http
        .put(Uri.parse(url), body: jsonEncode(client.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res editTier code : ${req.statusCode} ");
    print("res editTier body: ${req.body}");
    if (req.statusCode == 200) {
      return true;
    } else {
      print('Failed to load data');
      return false;
    }
  }
}
