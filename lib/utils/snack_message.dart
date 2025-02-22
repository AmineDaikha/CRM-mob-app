import 'package:flutter/material.dart';
import 'package:mobilino_app/styles/colors.dart';

void showMessage({String? message, BuildContext? context, Color? color}) {
  ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
      content: Text(
        message!,
        style: Theme.of(context).textTheme.headline5!.copyWith(color: white),
      ),
      backgroundColor: color));
}
