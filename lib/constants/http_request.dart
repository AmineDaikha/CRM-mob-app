import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/database/database_helper.dart';
import 'package:mobilino_app/providers/notif_provider.dart';
import 'package:pdf/widgets.dart';
import 'package:provider/provider.dart';

import 'urls.dart';

class HttpRequestApp {
  LatLng? currentLocation;

  Future<bool> sendEmail(String numDoc, String type, String email) async {
    Map<String, dynamic> jsonEmail = {
      "toEmail": '$email',
      "subject": 'subject',
      "message": 'Envoie de $type'
    };
    String url = AppUrl.email + '${AppUrl.user.etblssmnt!.code}/$numDoc';
    print('url : $url');
    http.Response req =
        await http.post(Uri.parse(url), body: jsonEncode(jsonEmail), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res email code : ${req.statusCode}");
    print("res email body: ${req.body}");
    if (req.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentLocation = LatLng(position.latitude, position.longitude);
      print('latLng: ${position.latitude} ${position.longitude}');
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> getNotif() async {
    String url = AppUrl.getNotif + '?salCode=${AppUrl.user.salCode}&vu=false';
    print('urlNotif : $url');
    print('efef :: ${AppUrl.user.company}');
    try {
      http.Response req = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
      });

      print("res notif code : ${req.statusCode}");
      print("res notif body: ${req.body}");
      if (req.statusCode == 200) {
        List<dynamic> data = json.decode(req.body);
        AppUrl.nbNotif = data.length;
      } else {}
    } catch (e) {
      print('efeefe $e');
    }
  }

  Future<bool?> sendItinerary(String type) async {
    if (AppUrl.user.salCode == null) return false;
    await getNotif();
    await _getCurrentLocation().then((value) async {
      if (currentLocation == null) {
        return false;
      } else {
        try {
          Map<String, dynamic> jsonObject = {
            "salCode": AppUrl.user.salCode,
            "etbCode": AppUrl.user.etblssmnt!.code,
            "date": DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
            "longitude": currentLocation!.longitude,
            "latitude": currentLocation!.latitude,
            "type": '$type'
          };
          print('jsonObj: ${jsonObject}');
          http.Response req = await http.post(Uri.parse(AppUrl.itinerary),
              body: jsonEncode(jsonObject),
              headers: {
                "Accept": "application/json",
                "content-type": "application/json; charset=UTF-8",
                "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
              });
          print("res itinerary code : ${req.statusCode}");
          print("res itinerary body: ${req.body}");
          if (req.statusCode == 200 || req.statusCode == 201) {
            return true;
          } else {
            return false;
          }
        } catch (e) {
          final DatabaseHelper dbHelper = DatabaseHelper.instance;
          Map<String, dynamic> row = {
            DatabaseHelper.columnSalCode: '${AppUrl.user.salCode}',
            DatabaseHelper.columnSalCode: '${AppUrl.user.etblssmnt!.code!}',
            DatabaseHelper.columnDate:
                '${DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now())}',
            DatabaseHelper.columnLat: '${currentLocation!.latitude}',
            DatabaseHelper.columnLon: '${currentLocation!.longitude}',
          };
          int id = await dbHelper.insert(row);
          print('inserted!! ${id}');
        }
      }
    });
  }

  Future<bool?> sendItineraryDec(
      String type, String salCode, String etbCode) async {
    // if (AppUrl.user.salCode == null) return false;
    print('fff: ${AppUrl.user.salCode} ${AppUrl.user.etblssmnt!.code}');
    await _getCurrentLocation().then((value) async {
      if (currentLocation == null) {
        return false;
      } else {
        try {
          Map<String, dynamic> jsonObject = {
            "salCode": salCode,
            "etbCode": etbCode,
            "date": DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
            "longitude": currentLocation!.longitude,
            "latitude": currentLocation!.latitude,
            "type": '$type'
          };
          print('jsonObj: ${jsonObject}');
          http.Response req = await http.post(Uri.parse(AppUrl.itinerary),
              body: jsonEncode(jsonObject),
              headers: {
                "Accept": "application/json",
                "content-type": "application/json; charset=UTF-8",
                "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
              });
          print("res itinerary code : ${req.statusCode}");
          print("res itinerary body: ${req.body}");
          if (req.statusCode == 200 || req.statusCode == 201) {
            return true;
          } else {
            return false;
          }
        } catch (e) {
          final DatabaseHelper dbHelper = DatabaseHelper.instance;
          Map<String, dynamic> row = {
            DatabaseHelper.columnSalCode: '${AppUrl.user.salCode}',
            DatabaseHelper.columnSalCode: '${AppUrl.user.etblssmnt!.code!}',
            DatabaseHelper.columnDate:
                '${DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now())}',
            DatabaseHelper.columnLat: '${currentLocation!.latitude}',
            DatabaseHelper.columnLon: '${currentLocation!.longitude}',
          };
          int id = await dbHelper.insert(row);
          print('inserted!! ${id}');
        }
      }
    });
  }
}
