import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobilino_app/models/activity.dart';
import 'package:mobilino_app/models/filtred_activities.dart';
import 'package:mobilino_app/models/notif.dart';

class NotifProvider extends ChangeNotifier {
  List<Notif> notifList = [];

  int countNotif = 0;


}
