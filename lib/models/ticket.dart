import 'package:mobilino_app/models/lot.dart';

import 'client.dart';
import 'concurrent.dart';
import 'plis.dart';

class Ticket {
  String? title;
  String? message;
  String? code;
  Client? client;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? delivryDate;
  DateTime? plisDate;
  int? stat = 0;
  String? status;
  var res;
  List<Plis> plis = [];
  List<Lot> lots = [];
  List<Concurrent> concurrent = [];

  Ticket(
      {this.client,
      this.code,
        this.message,
      this.title,
      this.stat,
      this.delivryDate,
      this.endDate,
      this.status,
      this.res,
      this.startDate});
}
