import 'package:flutter/material.dart';
import 'package:mobilino_app/styles/colors.dart';

import '../screens/notes_page/title_note_dialog.dart';

class ConfirmationOppDialog {
  Future<bool> showConfirmationDialog(
      BuildContext context, String type) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        String content = '';
        String confirm = 'Oui';
        String cancel = 'Non';
        TextStyle style = Theme.of(context)
            .textTheme
            .headline5!
            .copyWith(color: primaryColor);
        if (type == 'cancelOpp') {
          content = 'Vous êtes sûr d\'annuler l\'opportunité ?';
        }
        if (type == 'editOpp') {
          content = 'Vous êtes sûr de modifier l\'opportunité ?';
        }
        if (type == 'visitedOpp') {
          content = 'Vous êtes sûr de marquer cette opportunité comme visité ?';
        }
        if (type == 'paymentOpp') {
          content = 'Vous êtes sûr de marquer cette opportunité comme Encaissé ?';
        }
        if (type == 'delivredOpp') {
          content = 'Vous êtes sûr de marquer cette opportunité comme Livré ?';
        }
        if (type == 'delivredAndPaymentOpp') {
          content = 'Vous êtes sûr de marquer cette opportunité comme Livré et Encaissé ?';
        }

        return AlertDialog(
          title: Text(
            'Confirmation',
            style: Theme.of(context).textTheme.headline3,
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false when canceled
              },
              child: Text(
                '$cancel',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true when confirmed
              },
              child: Text(
                '$confirm',
                style: style,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      print('User confirmed.');
      return true;
    } else {
      // User canceled, take appropriate action
      print('User canceled.');
      return false;
    }
  }
}
