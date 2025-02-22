import 'package:flutter/material.dart';
import 'package:mobilino_app/styles/colors.dart';

import 'text_field.dart';

class LibDialog extends StatelessWidget {
  String? lib;
  final TextEditingController _client = TextEditingController();
  final formKey = GlobalKey<FormState>();

  LibDialog({this.lib});
  @override
  Widget build(BuildContext context) {
    if(lib != null){
      _client.text = lib!;
    }
    return Theme(
      data: ThemeData(
        // Define the custom theme for the dialog
        primaryColor: primaryColor,
        backgroundColor: Colors.white,
        dialogBackgroundColor: Colors.white,
        buttonTheme: ButtonThemeData(
          buttonColor: primaryColor,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      child: Form(
        key: formKey,
        child: AlertDialog(
          content: Container(
            height: 70,
            child: Center(
              child: customTextField(
                obscure: false,
                hint: 'Entrer libelle',
                controller: _client,
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop('');
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState != null &&
                    formKey.currentState!.validate()) {
                  Navigator.of(context).pop(_client.text.trim());
                }
              },
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
