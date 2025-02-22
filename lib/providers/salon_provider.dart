import 'package:flutter/material.dart';
import 'package:mobilino_app/models/salon.dart';

class SalonProvider extends ChangeNotifier {
  List<Salon> salonList = [];

  List<Salon> getSalonByStat(int stat){
    return salonList.where((salon) => salon.stat == stat).toList();
  }
}
