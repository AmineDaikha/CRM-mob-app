import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/providers/providers.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/widgets/add_payment_dialog.dart';
import 'package:mobilino_app/widgets/appbars/my_commands_appbar.dart';
import 'package:mobilino_app/widgets/drawers/my_commands_drawer.dart';
import 'package:mobilino_app/widgets/drawers/my_delivers_drawer.dart';
import 'package:mobilino_app/screens/payment_page/dialog_filtred_commands_clients.dart';
import 'package:provider/provider.dart';

import '../activities_pages/activity_page.dart';
import 'my_delivred_fragment.dart';




class MyDelivryPage extends StatefulWidget {
  const MyDelivryPage({super.key,});

  static const String routeName = '/mydelivery';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => MyDelivryPage(),
    );
  }
  @override
  State<MyDelivryPage> createState() => _MyDelivryPageState();
}

class _MyDelivryPageState extends State<MyDelivryPage> {

  @override
  void initState() {
    super.initState();
    AppUrl.filtredCommandsClient.clients = [Client(id: '-1', name: 'Tout')];
    AppUrl.filtredCommandsClient.client = AppUrl.filtredCommandsClient.clients.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoaderDialog(context);
      _fetchData(context).then((value) {
        Navigator.pop(context);
      });
    });
  }
  Future<void> _fetchData(BuildContext context) async {
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.filtredClients = [];
    String query = '';
    http.Response req = await http.get(
        Uri.parse(AppUrl.tiersPage +'?PageNumber=1&Filter=$query&PageSize=20'),
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
          LatLng latLng;
          if (element['longitude'] == null || element['latitude'] == null){
            latLng = LatLng(1.354474457244855, 1.849465150689236);
          }
          else {
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
          if(familleId != null){
            req = await http.get(
                Uri.parse(AppUrl.getFamilly +
                    '$familleId'),
                headers: {
                  "Accept": "application/json",
                  "content-type": "application/json; charset=UTF-8",
                  "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
                });
            print("res familleId code : ${req.statusCode}");
            print("res familleId body: ${req.body}");
            if(req.statusCode == 200){
              print('ddd: ${json.decode(req.body)['lib']}');
              familleId = json.decode(req.body)['lib'];
            }
          }

          if(sFamilleId != null){
            req = await http.get(
                Uri.parse(AppUrl.getSFamilly +
                    '$sFamilleId'),
                headers: {
                  "Accept": "application/json",
                  "content-type": "application/json; charset=UTF-8",
                  "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
                });
            print("res sfamilleId code : ${req.statusCode}");
            print("res sfamilleId body: ${req.body}");
            if(req.statusCode == 200){
              sFamilleId = json.decode(req.body)['lib'];
            }
          }
          print('TiersFams!!: $familleId $sFamilleId');
          AppUrl.filtredCommandsClient.clients.add(Client(
              name: element['rs'],
              totalPay: total,
              location: latLng,
              familleId: familleId,
              sFamilleId: sFamilleId,
              type: element['type'],
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
  @override
  Widget build(BuildContext context) {
    Client client = Client();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set icon color to white
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                //_showDatePicker(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FiltredCommandsClientDialog();
                  },
                ).then((value){
                  setState(() {

                  });
                });
              },
              icon: Icon(
                Icons.sort,
                color: Colors.white,
              ))
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mes livraisons',
              style: Theme.of(context)
                  .textTheme
                  .headline3!
                  .copyWith(color: Colors.white),
            ),
            Text(
              'Client : ${AppUrl.filtredCommandsClient.client!.name}',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'Collaborateur : ${AppUrl.filtredCommandsClient.collaborateur!.userName}',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      drawer: DrawerMyDeliveryPage(),
      body: DelivredHistoryFragment(client: client,),
    );
  }
}



