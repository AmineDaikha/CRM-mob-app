import 'package:flutter/material.dart';
import 'package:mobilino_app/models/salon.dart';
import 'package:mobilino_app/models/ticket.dart';

class TicketProvider extends ChangeNotifier {
  List<Ticket> ticketList = [];

  List<Ticket> getTicketByStat(int stat){
    return ticketList.where((ticket) => ticket.stat == stat).toList();
  }
}
