import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

class FullSize {
  BuildContext context;

  FullSize({required this.context});

  double getFullWidth(){
    return MediaQuery.of(context).size.width;
  }
}

class PhoneUtils {
  //   void makePhoneCall(String phoneNumber) async {
  //   final Uri phoneLaunchUri = Uri(scheme: 'tel', path: phoneNumber);
  //
  //   if (await canLaunch(phoneLaunchUri.toString())) {
  //     await launch(phoneLaunchUri.toString());
  //   } else {
  //     throw 'Could not launch $phoneLaunchUri';
  //   }
  // }
  makeSms(String phone) async {
    String body = "";
    if (Platform.isAndroid) {
      final uri = 'sms:${phone}?body=$body';
      await launch(uri);
    } else if (Platform.isIOS) {
      // iOS
      final uri = 'sms:${phone}&body=$body';
      await launch(uri);
    }
  }

  void makePhoneCall(String phoneNumber) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (res != null) {
      // Check the result of the call (true for success, false for failure, null for canceled)
      if (res) {
        print("Phone call successful");
      } else {
        print("Phone call failed");
      }
    }
  }

// Future<void> _makePhoneCalll(String phoneNumber) async {
//   final String telScheme = 'tel:$phoneNumber';
//   if (await canLaunch(telScheme)) {
//     await launch(telScheme);
//   } else {
//     throw 'Could not launch $telScheme';
//   }
// }
}
