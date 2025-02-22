import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/depot.dart';
import 'package:mobilino_app/providers/depot_provider.dart';
import 'package:mobilino_app/screens/chargement/chargement_fragment.dart';
import 'package:mobilino_app/screens/chargement/dechargement_fragment.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/widgets/appbars/charg_appbar.dart';
import 'package:mobilino_app/widgets/drawers/chargement_drawer.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ChargPage extends StatefulWidget {
  const ChargPage({super.key});

  static const String routeName = '/charg';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => ChargPage(),
    );
  }

  @override
  State<ChargPage> createState() => _ChargPageState();
}

class _ChargPageState extends State<ChargPage> {
  int PageNumber = 1;
  int PageSize = 20;
  String filter = '';

  @override
  void initState() {
    super.initState();
    // final provider = Provider.of<DepotProvider>(context, listen: false);
    // provider.depotList = [];
    // for (int i = 0; i < 4; i++) {
    //   print('$i hhhh!');
    //   provider.depotList.add(Depot(id: '$i', name: 'Dépôt ${i + 1}'));
    // }
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   //showLoaderDialog(context);
    //   fetchData().then((value) {
    //     //Navigator.pop(context);
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    Client client = Client(id: AppUrl.user.userId);
    return FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Future is still running, return a loading indicator or some placeholder.
            return Row(
              children: [
                CircularProgressIndicator(
                  color: primaryColor,
                ),
                Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(left: 15),
                    child: Text(
                      "",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    )),
              ],
            );
          } else if (snapshot.hasError) {
            // There was an error in the future, handle it.
            return Center(child: Text('Error: ${snapshot.error}'));
          } else
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                  appBar: ChargAppBar(),
                  drawer: DrawerChargPage(),
                  body: TabBarView(
                    children: [
                      ChargementFragment(client: client),
                      DechargementFragment(client: client),
                    ],
                  )),
            );
        });
  }

  // Function to fetch JSON data from an API
  Future<void> fetchData() async {
    final provider = Provider.of<DepotProvider>(context, listen: false);
    DepotProvider.depotList = [];
    print('url: ${AppUrl.depots +
        '${AppUrl.user.etblssmnt!.code}?PageNumber=$PageNumber&PageSize=$PageSize'}');
    http.Response req = await http.get(
        Uri.parse(AppUrl.depots +
            '${AppUrl.user.etblssmnt!.code}?PageNumber=$PageNumber&PageSize=$PageSize'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
        });
    print("res depot code : ${req.statusCode}");
    print("res depot body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.toList().forEach((element) {
        //http://"+AppUrl.user.company!+".my-crm.net:5188/api/Depots/ETB001?PageNumber=1&PageSize=20
        //http://"+AppUrl.user.company!+".my-crm.net:5188/api/Depots/ETB001?PageNumber=1&PageSize=20
        DepotProvider.depotList
            .add(Depot(id: element['depCode'], name: element['depNom']));
      });
      provider.notifyListeners();
      print('itemsCh: ${DepotProvider.depotList.length}');
      print('hhhh1');
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
