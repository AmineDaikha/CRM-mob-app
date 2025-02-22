import 'package:flutter/material.dart';
import 'package:mobilino_app/models/payment.dart';

class PaymentProvider extends ChangeNotifier {
  List<Payment> paymentList = [];

  List<Payment> get paymentListSelected =>
      paymentList.where((payment) => payment.isChoosed == true).toList();

  double restPayment(String valuePayment) {
    if (valuePayment == null || valuePayment == '')
      return 0;
    double echence = sumOfRest();
    double result = double.parse(valuePayment) - echence;
    print('result: $result');
    print('valuePayment ${double.parse(valuePayment)}');
    print('echence: $echence');
    if (result > 0)
      return result;
    else
      return 0;
  }

  double sumOfRest() {
    double sum = 0;
    paymentListSelected.forEach((payment) {
      sum += payment.rest;
    });
    return sum;
  }

  double affected(String valuePayment) {
    if (valuePayment == null || valuePayment == '') return 0;
    return 0;
  }
}
