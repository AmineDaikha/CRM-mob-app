import 'package:mobilino_app/models/client.dart';

class Payment {
  String code;
  double total;
  double currrentRest = 0;
  String? type; // Espèces
  DateTime? date;
  double rest = 0;
  double paid;
  double currentPaid;
  bool isChoosed = false;
  Client? client;

  Payment({
    required this.code,
    required this.total,
    required this.paid,
    required this.currentPaid,
    this.type,
    this.date,
    this.client
  }) {
    this.currrentRest = this.total - this.paid;
    this.rest = this.total - this.paid;
  }
}
