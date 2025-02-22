import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/familly.dart';
import 'package:mobilino_app/models/sfamilly.dart';
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
  bool first = true;
  List<SFamilly> sFamillyList = [];
  List<SFamilly> sectorsList = [];
  LatLng? currentLocation;
  final TextEditingController road = TextEditingController();
  final TextEditingController way = TextEditingController();
  //final TextEditingController city = TextEditingController();
  final TextEditingController lat = TextEditingController();
  final TextEditingController lon = TextEditingController();
  final TextEditingController familly = TextEditingController();
  final TextEditingController surface = TextEditingController();
  late Familly selectedFamilly;
  late SFamilly selectedSFamilly;
  late Familly selectedRegion;
  late SFamilly selectedSector;
  Familly? selectedVille;
  final _formkey = GlobalKey<FormState>();
  bool isChecked = false;

  Future<void> fetchDataFamilly() async {
    first = false;
    AppUrl.tierFamillies = [];
    AppUrl.tierSFamillies = [];
    String url = '${AppUrl.tierFamilly}';
    print('url : $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res familly code : ${req.statusCode}");
    print("res familly body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      print('length ${data.length}');
      data.forEach((element) {
        AppUrl.tierFamillies.add(
            Familly(code: element['code'], name: element['lib'], type: ''));
      });
    }
    await fetchDataSFamilly();
    AppUrl.tierFamillies.insert(0, Familly(code: '', name: '', type: ''));
    AppUrl.tierSFamillies.insert(0, SFamilly(code: '', name: '', type: ''));
    selectedFamilly = AppUrl.tierFamillies.first;
    selectedSFamilly = AppUrl.tierSFamillies.first;
    sFamillyList = AppUrl.tierSFamillies
        .where((element) => element.type == selectedFamilly!.code)
        .toList();
    await fetchDataRegion();
    await fetchDataVille();
  }

  Future<void> fetchDataVille() async {
    AppUrl.villes = [];
    String url = '${AppUrl.getVilles}';
    print('url : $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res ville code : ${req.statusCode}");
    print("res ville body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      print('length ${data.length}');
      data.forEach((element) {
        try{
        AppUrl.villes.add(Familly(
            code: element['vilCode'],
            name: element['vilNom'], type: '',
            ));}catch(_){

        }
      });
    }
  }

  Future<void> fetchDataSFamilly() async {
    String url = '${AppUrl.tierSFamilly}';
    print('url : $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res sfamilly code : ${req.statusCode}");
    print("res sfamilly body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      print('length ${data.length}');
      data.forEach((element) {
        AppUrl.tierSFamillies.add(SFamilly(
            code: element['code'],
            name: element['lib'],
            type: element['fatCode']));
      });
    }
  }

  Future<void> fetchDataRegion() async {
    first = false;
    AppUrl.tierRegions = [];
    AppUrl.tierSectors = [];
    String url = '${AppUrl.tierRegion}';
    print('url : $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res region code : ${req.statusCode}");
    print("res region body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      print('length ${data.length}');
      data.forEach((element) {
        AppUrl.tierRegions.add(
            Familly(code: element['code'], name: element['nom'], type: ''));
      });
    }
    await fetchDataSector();
    AppUrl.tierRegions.insert(0, Familly(code: '', name: '', type: ''));
    AppUrl.tierSectors.insert(0, SFamilly(code: '', name: '', type: ''));
    selectedRegion = AppUrl.tierRegions.first;
    selectedSector = AppUrl.tierSectors.first;
    sectorsList = AppUrl.tierSectors
        .where((element) => element.type == selectedRegion.code)
        .toList();
  }

  Future<void> fetchDataSector() async {
    String url = '${AppUrl.tierSector}';
    print('url : $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res sector code : ${req.statusCode}");
    print("res sector body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      print('length ${data.length}');
      data.forEach((element) {
        AppUrl.tierSectors.add(SFamilly(
            code: element['code'],
            name: element['nom'],
            type: element['regionId']));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   showLoaderDialog(context);
    //   fetchDataFamilly().then((value) {
    //     print('hhhhh');
    //     Navigator.pop(context);
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: (first) ? fetchDataFamilly() : null ,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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
              content: Container(
                height: 100,
                child: Column(
                  children: [
                    Row(
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
                        Column(
                          children: [
                            // Text(
                            //     textAlign: TextAlign.center,
                            //     'Nous sommes désolé, la qualité de '
                            //     'votre connexion ne vous permet pas'
                            //     ' de vous connecter à votre serveur. '
                            //     'Veuillez réessayer ultérieurement. Merci'),
                            Text(
                                textAlign: TextAlign.center,
                                'Pas de connexion'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                Container(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (route) => false);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mettre à jour',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(color: Colors.white),
                        ),
                        Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          }
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
                      // Image.asset(
                      //   'assets/addclient.png',
                      //   fit: BoxFit.cover,
                      // ),
                      SizedBox(
                        height: 10,
                      ),
                      ListTile(
                        title: Text(
                          'Famille',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: DropdownButtonFormField<Familly>(
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(width: 2, color: primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(width: 2, color: primaryColor),
                              )),
                          hint: Text(
                            'Selectioner la famille',
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(color: Colors.grey),
                          ),
                          value: selectedFamilly,
                          onChanged: (newValue) {
                            selectedFamilly = newValue!;
                            print('fjhbkjbkkrt ${selectedFamilly.code} ${selectedFamilly.name} ${selectedFamilly.type}');
                            print('fjhbkjbkkrt ${newValue.code} ${newValue.name} ${newValue.type}');
                            if (selectedFamilly != null) {
                              sFamillyList = List<SFamilly>.from(AppUrl.tierSFamillies)
                                  .where((element) =>
                                      element.type == selectedFamilly.code)
                                  .toList();
                              sFamillyList.insert(
                                  0, SFamilly(code: '', name: '', type: ''));
                              selectedSFamilly = sFamillyList.first;
                              print('fjhbkjbkkrtlengh ${sFamillyList.length}');
                            }
                            setState(() {});
                          },
                          items: AppUrl.tierFamillies
                              .map<DropdownMenuItem<Familly>>((Familly value) {
                            return DropdownMenuItem<Familly>(
                              value: value,
                              child: Text(
                                value.name,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Sous Famille',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: DropdownButtonFormField<SFamilly>(
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(width: 2, color: primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(width: 2, color: primaryColor),
                              )),
                          hint: Text(
                            'Selectioner sous famille',
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(color: Colors.grey),
                          ),
                          value: selectedSFamilly,
                          onChanged: (newValue) {
                            setState(() {
                              selectedSFamilly = newValue!;
                              print('frfrffrfrfrf ${selectedSFamilly.code} ${selectedSFamilly.name} ${selectedSFamilly.type}');
                              print('fjhbkjbkkrt ${sFamillyList.length}');
                            });
                          },
                          items: sFamillyList.map<DropdownMenuItem<SFamilly>>(
                              (SFamilly value) {
                            return DropdownMenuItem<SFamilly>(
                              value: value,
                              child: Text(
                                value.name,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Région',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: DropdownButtonFormField<Familly>(
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(width: 2, color: primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(width: 2, color: primaryColor),
                              )),
                          hint: Text(
                            'Selectioner la région',
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(color: Colors.grey),
                          ),
                          value: selectedRegion,
                          onChanged: (newValue) {
                            selectedRegion = newValue!;
                            print('fjhbkjbkkrt ${selectedRegion.code} ${selectedRegion.name} ${selectedRegion.type}');
                            print('fjhbkjbkkrt ${newValue.code} ${newValue.name} ${newValue.type}');
                            if (selectedRegion != null) {
                              sectorsList = List<SFamilly>.from(AppUrl.tierSectors)
                                  .where((element) =>
                              element.type == selectedRegion.code)
                                  .toList();
                              sectorsList.insert(
                                  0, SFamilly(code: '', name: '', type: ''));
                              selectedSector = sectorsList.first;
                              print('fjhbkjbkkrtlengh ${sectorsList.length}');
                            }
                            setState(() {});
                          },
                          items: AppUrl.tierRegions
                              .map<DropdownMenuItem<Familly>>((Familly value) {
                            return DropdownMenuItem<Familly>(
                              value: value,
                              child: Text(
                                value.name,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Secteur',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: DropdownButtonFormField<SFamilly>(
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(width: 2, color: primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(width: 2, color: primaryColor),
                              )),
                          hint: Text(
                            'Selectioner le secteur',
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(color: Colors.grey),
                          ),
                          value: selectedSector,
                          onChanged: (newValue) {
                            setState(() {
                              selectedSector = newValue!;
                              print('frfrffrfrfrf ${selectedSector.code} ${selectedSector.name} ${selectedSector.type}');
                              print('fjhbkjbkkrt ${sectorsList.length}');
                            });
                          },
                          items: sectorsList.map<DropdownMenuItem<SFamilly>>(
                                  (SFamilly value) {
                                return DropdownMenuItem<SFamilly>(
                                  value: value,
                                  child: Text(
                                    value.name,
                                    style: Theme.of(context).textTheme.headline4,
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                      customTextFieldEmpty(
                        obscure: false,
                        controller: road,
                        hint: 'Rue',
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      customTextFieldEmpty(
                        obscure: false,
                        controller: way,
                        hint: 'Quartier',
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ListTile(
                        title: Text(
                          'Ville',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: DropdownButtonFormField<Familly>(
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(width: 2, color: primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(width: 2, color: primaryColor),
                              )),
                          hint: Text(
                            'Selectioner la villle',
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(color: Colors.grey),
                          ),
                          value: selectedVille,
                          onChanged: (newValue) {
                            selectedVille = newValue;
                            setState(() {});
                          },
                          items: AppUrl.villes
                              .map<DropdownMenuItem<Familly>>((Familly value) {
                            return DropdownMenuItem<Familly>(
                              value: value,
                              child: Container(
                                width: 230,
                                child: Text(
                                  value.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Visibility(
                        visible: false,
                        child: Row(
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
                                            lat.text = currentLocation!.latitude
                                                .toString();
                                            lon.text = currentLocation!
                                                .longitude
                                                .toString();
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
                      ),
                      Visibility(
                        visible: false,
                        child: Row(
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
                                print('fefee ${selectedVille!.name}');
                                if(selectedVille != null)
                                AppUrl.client.city = selectedVille!.name;
                                //AppUrl.client.location = currentLocation;
                                AppUrl.client.way = way.text.trim();
                                AppUrl.client.familly = familly.text.trim();
                                AppUrl.client.surface = surface.text.trim();
                                showLoaderDialog(context);
                                fetchData().then((value) {
                                  Navigator.pop(context);
                                  if (value) {
                                    showMessage(
                                        message:
                                            'Client / Prospect créé avec succès',
                                        context: context,
                                        color: primaryColor);
                                    Navigator.pop(context);
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
    ;
  }

  Future<bool> fetchData() async {

    String? familly;
    if(selectedFamilly.code != '')
      familly =selectedFamilly.code;
    String? sFamilly;
    if(selectedSFamilly.code != '')
      sFamilly =selectedSFamilly.code;
    String? region;
    if(selectedRegion.code != '')
      region =selectedRegion.code;
    String? sector;
    if(selectedSector.code != '')
      familly =selectedSector.code;

    double? latitude;
    double? longitude;
    if(AppUrl.client.location != null){
      latitude = AppUrl.client.location!.latitude;
      longitude = AppUrl.client.location!.longitude;
    }
    List<Map<String, dynamic>>? adress = [];
    if(sector != null || region != null || AppUrl.client.city != null || AppUrl.client.road != null || AppUrl.client.way != null){
      Map<String, dynamic> jsonAdress = {
        'tbl' : 'PCF',
        'numero' : '001',
        "title": 'Addresse de factoration',
        "rs": AppUrl.client.name,
        "rs2": AppUrl.client.name2,
        "rue": AppUrl.client.road,
        "qte": AppUrl.client.city,
        "reg": region,
        "secteur": sector,
        "longitude": longitude,
        "latitude": latitude,
      };
      Map<String, dynamic> jsonAdress2 = {
        'tbl' : 'PCF',
        'numero' : '002',
        "title": 'Addresse de livraison',
        "rs": AppUrl.client.name,
        "rs2": AppUrl.client.name2,
        "rue": AppUrl.client.road,
        "qte": AppUrl.client.way,
        "reg": region,
        'ville': AppUrl.client.city,
        "secteur": sector,
        "longitude": longitude,
        "latitude": latitude,
      };
      adress.add(jsonAdress);
      adress.add(jsonAdress2);
    }else{
      adress = null;
    }

    var body = jsonEncode({
      "code" : '${AppUrl.client.code}',
      "type": "${AppUrl.client.type}",
      "rs": "${AppUrl.client.name}",
      "rs2": "${AppUrl.client.name2}",
      "civilite": null,
      "familleId": familly,
      "sFamilleId": sFamilly,
      "region": region,
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
      "longitude": longitude,
      "latitude": latitude,
      "adress": adress,
      // "longitude": 33.3546854,//AppUrl.client.location!.longitude,
      // "latitude":  6.8431943//AppUrl.client.location!.latitude
    });
    print('jsonObj : $body');
    http.Response req =
        await http.post(Uri.parse(AppUrl.tier), body: body, headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res tier code : ${req.statusCode}");
    print("res tier body: ${req.body}");

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
