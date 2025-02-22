
import 'package:flutter/widgets.dart';
import 'package:mobilino_app/models/command.dart';
import 'package:mobilino_app/models/payment.dart';

class CommandProvider extends ChangeNotifier{

  List<Command> devisList = [];
  List<Command> commandList = [];
  List<Command> deliverdList = [];
  List<Command> returnedList = [];
  List<Payment> paymentList = [];
}