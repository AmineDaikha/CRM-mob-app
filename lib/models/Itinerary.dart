import 'package:latlong2/latlong.dart';

class Itinerary {
  String salCode;
  String etbCode;
  LatLng position;
  String type;
  String? codeLie;
  DateTime date;

  Itinerary({
    required this.salCode,
    required this.etbCode,
    required this.position,
    required this.type,
    required this.date,
    this.codeLie,
  });
}
