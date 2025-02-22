import 'package:flutter/material.dart';
import 'package:mobilino_app/models/product.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/snack_message.dart';

class CommandDialog extends StatefulWidget {
  Product product;

  CommandDialog(this.product);

  @override
  _CommandDialogState createState() => _CommandDialogState();
}

class _CommandDialogState extends State<CommandDialog> {
  TextEditingController quantityController = TextEditingController();
  TextEditingController quantityColisController = TextEditingController();
  TextEditingController promiseController = TextEditingController();
  TextEditingController tvaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize default values here
    quantityColisController.text =
        (widget.product.quantity / widget.product.quantityOfColis!)
            .toInt()
            .toString();
    quantityController.text = widget.product.quantity.toString();
    promiseController.text = widget.product.remise.toString();
    tvaController.text = widget.product.tva.toString();
  }

  @override
  Widget build(BuildContext context) {
    quantityColisController.text =
        (widget.product.quantity / widget.product.quantityOfColis!)
            .toInt()
            .toString();
    quantityController.text = widget.product.quantity.toString();
    promiseController.text = widget.product.remise.toString();
    tvaController.text = widget.product.tva.toString();
    return AlertDialog(
      title: Text("Modifier les values"),
      content: Container(
        height: 220,
        child: Column(
          children: [
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantité par unité'),
              onChanged: (value) {
                setState(() {
                  widget.product.quantity = int.parse(value);
                });
              },
            ),
            (widget.product.quantityOfColis! > 1)
                ? TextField(
                    controller: quantityColisController,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: 'Quantité par colis'),
                    onChanged: (value) {
                      setState(() {
                        //widget.product.quantityOfColis = int.tryParse(value);
                        widget.product.quantity =
                            widget.product.quantityOfColis! * int.parse(value);
                      });
                    },
                  )
                : Container(),
            TextField(
              controller: promiseController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Remise'),
            ),
            TextField(
              controller: tvaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'TVA'),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            String quantity = quantityController.text;
            String promise = promiseController.text;
            String tva = tvaController.text;
            // if(int.parse(quantity) >= widget.product.quantityStock!){
            //   showMessage(
            //       message: 'Quantité supérieure à la quantité en stock',
            //       context: context,
            //       color: Colors.red);
            //   return;
            // }
            if (int.parse(quantity) == 0) quantity = '1';
            widget.product.tva = double.parse(tva);
            widget.product.remise = double.parse(promise);
            widget.product.quantity = int.parse(quantity);
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(
            'Sauvgarder',
            style: TextStyle(color: primaryColor),
          ),
        ),
      ],
    );
  }
}
