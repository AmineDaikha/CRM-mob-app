import 'concurrent.dart';

class Lot {
  String? prjCode;
  String? cdcfCode;
  int? id;
  String? nomLot;
  int? numLot;
  String? desc;
  bool? attribue;
  List<Concurrent> concurrent = [];

  Lot({this.id, this.nomLot, this.numLot, this.desc, this.attribue, this.cdcfCode, this.prjCode});
}
