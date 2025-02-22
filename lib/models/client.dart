import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/command.dart';

import 'contact.dart';
import 'depot.dart';
import 'product.dart';

class Client {
  String? code;
  String? id;
  String? email;
  String? phone;
  String? phone2;
  String? name;
  String? name2;
  String? city;
  String? road;
  String? way;
  String? region;
  String? sector;
  String? familly;
  String? surface;
  String? total;
  double? totalPay = 0;
  Command? command;
  Depot? depot;
  int? stat = 0;
  LatLng? location;
  String? idOpp;
  int? priority = 0;
  int? emergency = 0;
  String? lib;
  String? desc;
  String? type;
  DateTime? dateCreation;
  DateTime? dateStart;
  String? familleId;
  String? sFamilleId;
  String? typeCommand = 'cmd';
  var res = null;
  var resOppo = null;
  List<Contact> contacts = [];

  Client(
      {this.code,
      this.id,
      this.name,
      this.phone,
      this.city,
      this.total,
      this.stat,
      this.command,
      this.depot,
      this.location,
      this.idOpp,
      this.totalPay,
      this.phone2,
      this.name2,
      this.email,
      this.surface,
      this.familly,
      this.way,
      this.road,
      this.priority,
      this.type,
      this.emergency,
      this.desc,
      this.dateCreation,
      this.dateStart,
      this.familleId,
      this.sFamilleId,
      this.resOppo,
      this.res,
      this.lib}) {
    if (totalPay == null) totalPay = 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Client && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
