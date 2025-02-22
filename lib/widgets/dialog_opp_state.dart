import 'package:flutter/material.dart';

import '../styles/colors.dart';
import 'confirmation_opportunity_dialog.dart';

class ChoiceDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ConfirmationOppDialog confirmationOppDialog = ConfirmationOppDialog();
    return SimpleDialog(
      title: Text(
        'Selectionner l\'état',
        style: Theme.of(context).textTheme.headline2,
      ),
      children: [
        InkWell( // visited
          onTap: () async {
            bool confirmed = await confirmationOppDialog.showConfirmationDialog(
                context, 'visitedOpp');
            if (confirmed)
              Navigator.pop(context, 2);
            else
              Navigator.pop(context, 0);
          },
          child: buildChoiceItem(
              context,
              'Visité',
              Icon(
                Icons.check,
                color: primaryColor,
              )),
        ),
        InkWell(// cancel
          onTap: () async {
            bool confirmed = await confirmationOppDialog.showConfirmationDialog(
                context, 'delivredOpp');
            if (confirmed)
              Navigator.pop(context, 3);
            else
              Navigator.pop(context, 0);
          },
          child: buildChoiceItem(
              context,
              'Livré',
              Icon(
                Icons.delivery_dining_outlined,
                color: primaryColor,
              )),
        ),
        InkWell( // payment
          onTap: () async {
            bool confirmed = await confirmationOppDialog.showConfirmationDialog(
                context, 'paymentOpp');
            if (confirmed)
              Navigator.pop(context, 4);
            else
              Navigator.pop(context, 0);
          },
          child: buildChoiceItem(
              context,
              'Encaissé',
              Icon(
                Icons.money_outlined,
              )),
        ),
        InkWell( // payment + delivred
          onTap: () async {
            bool confirmed = await confirmationOppDialog.showConfirmationDialog(
                context, 'delivredAndPaymentOpp');
            if (confirmed)
              Navigator.pop(context, 5);
            else
              Navigator.pop(context, 0);
          },
          child: buildChoiceItem(
              context,
              'Livré & Encaissé',
              Icon(
                Icons.monetization_on_outlined,
                color: primaryColor,
              )),
        ),
        InkWell(// cancel
          onTap: () async {
            bool confirmed = await confirmationOppDialog.showConfirmationDialog(
                context, 'cancelOpp');
            if (confirmed)
              Navigator.pop(context, 6);
            else
              Navigator.pop(context, 0);
          },
          child: buildChoiceItem(
              context,
              'Annulé',
              Icon(
                Icons.clear_rounded,
                color: Colors.red,
              )),
        ),
      ],
    );
  }

  Widget buildChoiceItem(BuildContext context, String choice, Icon icon) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          icon,
          SizedBox(width: 16),
          Text(
            choice,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
