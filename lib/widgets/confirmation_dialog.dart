import 'package:flutter/material.dart';
import 'package:mobilino_app/styles/colors.dart';

class ConfirmationDialog {
  Future<bool> showConfirmationDialog(
      BuildContext context, String type) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        String content = '';
        String confirm = 'Confirmer';
        TextStyle style = TextStyle();
        if (type == 'deleteProduct') {
          content = 'Vous êtes sûr de supprimer ce produit de la commande ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: Colors.red);
        }
        if (type == 'logout') {
          confirm = 'Déconnecter';
          content = 'Vous êtes sûr de déconnecter ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'progressAct') {
          content = 'Vous êtes sûr de commencer cette activité ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'confirmChang') {
          content = 'Vous êtes sûr de confirmer ces changement ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'deleteCont') {
          content = 'Vous êtes sûr de supprimer ce contact ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'endAct') {//endAct
          content = 'Vous êtes sûr de terminer cette activité ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'deleteCommand') {
          content = 'Vous êtes sûr de supprimer cette commande ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: Colors.red);
        }
        if (type == 'confirmCommand') {
          content = 'Vous êtes sûr de confirmer cette commande ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'confirmDevis') {
          content = 'Vous êtes sûr de confirmer ce devis ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'changToGan') {
          content = 'Êtes-vous sûr de changer l\'état cette opportunité ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'transToCommand') {
          content = 'Vous êtes sûr de transférer ce devis à une commande ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'confirmDelivr') {
          content = 'Vous êtes sûr de confirmer cette livraison ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }

        if (type == 'confirmCharg') {
          content = 'Vous êtes sûr de confirmer ce chargement ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }

        if (type == 'confirmDecharg') {
          content = 'Vous êtes sûr de confirmer ce déchargement ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }

        if (type == 'confirmPayment') {
          content = 'Vous êtes sûr de confirmer ce règlement ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }

        if (type == 'confirmReturn') {
          content = 'Vous êtes sûr de confirmer ce bon de retour ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }

        if (type == 'confirmEditAct') {
          content = 'Vous êtes sûr de modifier cette activité ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'confirmDupAct') {
          content = 'Vous êtes sûr de dupliquer cette activité ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'confirmAct') {
          content = 'Vous êtes sûr d\'ajouter cette activité ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'confirmOpp') {
          content = 'Vous êtes sûr d\'ajouter cette opportunité ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
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
                'Annuler',
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
