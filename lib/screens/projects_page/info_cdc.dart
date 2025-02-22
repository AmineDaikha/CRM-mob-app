import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/project.dart';
import 'package:mobilino_app/models/type_activity.dart';
import 'package:mobilino_app/screens/activities_pages/activity_list_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:mobilino_app/widgets/text_field.dart';

class CDCWidget extends StatefulWidget {
  final Project project;

  const CDCWidget({Key? key, required this.project}) : super(key: key);

  @override
  _CDCWidgetState createState() => _CDCWidgetState();
}

class _CDCWidgetState extends State<CDCWidget> {
  late TypeActivity? selectedTypeItem = TypeActivity();

  final List<String> optionsSoumiss = ['Oui', 'Non'];
  final List<String> optionsCaution = ['Oui', 'Non'];
  final List<String> optionsReturn = ['Oui', 'Non'];

  String currentSoumiss = '';
  String currentCaution = '';
  String currentReturn = '';

  @override
  void initState() {
    super.initState();
    currentSoumiss = optionsSoumiss[1];
    currentCaution = optionsCaution[1];
    currentSoumiss = optionsReturn[1];
    if (widget.project.res['cdcf']['soumiPartielle'] == true)
      currentSoumiss = optionsSoumiss[0];
    if (widget.project.res['cdcf']['soumiCaution'] == true)
      currentCaution = optionsCaution[0];
    if (widget.project.res['cdcf']['retenueGarantie'] == true)
      currentReturn = optionsReturn[0];
     List<TypeActivity> regs = AppUrl.user.typeReg.where((element) {
      print('gg ${element.code} ${widget.project.res['cdcf']['regType']}');
      return element.code == widget.project.res['cdcf']['regType'];
    }).toList();
    if(regs.length >0 )
      selectedTypeItem = regs.first;
    else
      selectedTypeItem = AppUrl.user.typeReg.first;
  }

  @override
  Widget build(BuildContext context) {
    //List<String> options = ['Option 1', 'Option 2'];
    String typeTier = '';
    Color color = primaryColor;
    String type = widget.project.res['tiers']['type'];
    if (type == 'C') {
      typeTier = 'Client';
      color = Colors.blue;
    } else if (widget.project.res['tiers']['type'] == 'P') {
      typeTier = 'Prospect';
    } else if (widget.project.res['tiers']['type'] == 'F') {
      typeTier = 'Fournisseur';
      color = Colors.red;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiers : ',
                  style: Theme.of(context)
                      .textTheme
                      .headline3!
                      .copyWith(color: Colors.black),
                ),
                Text(
                  '${widget.project.client!.name!}',
                  style: Theme.of(context)
                      .textTheme
                      .headline3!
                      .copyWith(color: color),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Type de tiers : ',
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(color: Colors.black),
                ),
                Text(
                  '${typeTier}',
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(color: Colors.black),
                ),
              ],
            ),
            ListTile(
              title: Text(
                'Type de règlement :',
                style: Theme.of(context).textTheme.headline6,
              ),
              subtitle: DropdownButtonFormField<TypeActivity>(
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(width: 2, color: primaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(width: 2, color: primaryColor),
                    )),
                hint: Text(
                  'Selectioner le type de règlement',
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(color: Colors.grey),
                ),
                value: selectedTypeItem,
                onChanged: (newValue) {
                  setState(() {
                    selectedTypeItem = newValue!;
                  });
                },
                items: AppUrl.user.typeReg
                    .map<DropdownMenuItem<TypeActivity>>((TypeActivity value) {
                  return DropdownMenuItem<TypeActivity>(
                    value: value,
                    child: Text(
                      value.name!,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nombre de lot: ${widget.project.res['cdcf']['nbLot']}',
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                      //fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prix du cahier des charges: ${AppUrl.formatter.format(widget.project.res['cdcf']['prixCdcf'])} DZD',
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                      //fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NB',
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                      //fontStyle: FontStyle.italic,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'INTITULÉ LOT',
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                      //fontStyle: FontStyle.italic,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'DESCRIPTION',
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                      //fontStyle: FontStyle.italic,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(
              height: 100, //AppUrl.getFullHeight(context) * 0.4,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  //return Text('$index');
                  return LotItem(
                    index: index,
                  );
                },
                itemCount: widget.project.res['cdcf']['nbLot'],
              ),
            ),
            Divider(),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 30),
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //         primary: Theme.of(context).primaryColor,
            //         elevation: 0,
            //         shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(30))),
            //     onPressed: () {
            //       // Handle button press
            //     },
            //     child: Text(
            //       "Valider les lots",
            //       style: TextStyle(color: Colors.white, fontSize: 18),
            //     ),
            //   ),
            // ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Soumission Partielle Autorisée',
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      //fontStyle: FontStyle.italic,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      optionsSoumiss[0],
                      style: TextStyle(color: primaryColor),
                    ),
                    leading: Radio(
                      activeColor: primaryColor,
                      value: optionsSoumiss[0],
                      groupValue: currentSoumiss,
                      onChanged: (value) {
                        setState(() {
                          currentSoumiss = value.toString();
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      optionsSoumiss[1],
                      style: TextStyle(color: primaryColor),
                    ),
                    leading: Radio(
                      value: optionsSoumiss[1],
                      activeColor: primaryColor,
                      groupValue: currentSoumiss,
                      onChanged: (value) {
                        setState(() {
                          currentSoumiss = value.toString();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Caution de Soumission',
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      //fontStyle: FontStyle.italic,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      optionsCaution[0],
                      style: TextStyle(color: primaryColor),
                    ),
                    leading: Radio(
                      activeColor: primaryColor,
                      value: optionsCaution[0],
                      groupValue: currentCaution,
                      onChanged: (value) {
                        setState(() {
                          currentCaution = value.toString();
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      optionsCaution[1],
                      style: TextStyle(color: primaryColor),
                    ),
                    leading: Radio(
                      value: optionsCaution[1],
                      activeColor: primaryColor,
                      groupValue: currentCaution,
                      onChanged: (value) {
                        setState(() {
                          currentCaution = value.toString();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Soumission Partielle Autorisée',
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      //fontStyle: FontStyle.italic,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      optionsReturn[0],
                      style: TextStyle(color: primaryColor),
                    ),
                    leading: Radio(
                      activeColor: primaryColor,
                      value: optionsReturn[0],
                      groupValue: currentReturn,
                      onChanged: (value) {
                        setState(() {
                          currentReturn = value.toString();
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      optionsReturn[1],
                      style: TextStyle(color: primaryColor),
                    ),
                    leading: Radio(
                      value: optionsReturn[1],
                      activeColor: primaryColor,
                      groupValue: currentReturn,
                      onChanged: (value) {
                        setState(() {
                          currentReturn = value.toString();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                onPressed: () async {
                  ConfirmationDialog confirmationDialog = ConfirmationDialog();
                  bool confirmed = await confirmationDialog
                      .showConfirmationDialog(context, 'confirmChang');
                  if (confirmed) {
                    showLoaderDialog(context);
                    Future.delayed(Duration(seconds: 1))
                        .then((value) {
                      // showMessage(
                      //     message:
                      //     'Échec ...',
                      //     context: context,
                      //     color: Colors.red);
                      Navigator.pop(context);
                    });
                  }
                },
                child: Text(
                  "        Valider        ",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

// ouverture() {
//   Divider(color: Colors.grey),
//   SizedBox(height: 10),
//   Row(
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//   Text(
//   'Ouverture des Plis :',
//   style: Theme.of(context).textTheme.headline4,
//   ),
//   ],
//   ),
//   SizedBox(height: 10),
//   Center(
//   child: GestureDetector(
//   onTap: () {
//   //_selectStartDate(context);
//   //showDateTimeDialog(context);
//   },
//   child: Text(
//   'Date et Heure d’ouverture: : ${DateFormat('yyyy-MM-dd').format(widget.project.startDate!)}',
//   style: Theme.of(context)
//       .textTheme
//       .headline6!
//       .copyWith(fontStyle: FontStyle.italic, color: Colors.grey, fontWeight: FontWeight.normal),
//   ),
//   ),
//   ),
//   SizedBox(height: 10),
//   Text(
//   'Collaborateur : S.Karim',
//   style: Theme.of(context).textTheme.headline6,
//   ),
//   SizedBox(height: 10),
//   Container(
//   height: 150,
//   child: Column(
//   mainAxisAlignment: MainAxisAlignment.start,
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//   Text('Type : ', style: Theme.of(context).textTheme.headline5),
//   ListTile(
//   title: Text(
//   options[0],
//   style: TextStyle(color: Colors.blue),
//   ),
//   leading: Radio(
//   activeColor: Colors.blue,
//   value: options[0],
//   groupValue: currentOption,
//   onChanged: (value) {
//   setState(() {
//   currentOption = value.toString();
//   });
//   },
//   ),
//   ),
//   ListTile(
//   title: Text(
//   options[1],
//   style: TextStyle(color: Colors.blue),
//   ),
//   leading: Radio(
//   value: options[1],
//   activeColor: Colors.blue,
//   groupValue: currentOption,
//   onChanged: (value) {
//   setState(() {
//   currentOption = value.toString();
//   });
//   },
//   ),
//   ),
//   ],
//   ),
//   ),
//   Divider(color: Colors.grey),
// }
}

class LotItem extends StatelessWidget {
  int index;
  final TextEditingController _name = TextEditingController();
  final TextEditingController desc = TextEditingController();

  LotItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            //elemental
            return LotDialog();
          },
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${index + 1} ',
              style: Theme.of(context).textTheme.headline6!.copyWith(
                  //fontStyle: FontStyle.italic,
                  color: Colors.black,
                  fontWeight: FontWeight.normal),
            ),
            Text(
              'nom de lot',
              style: Theme.of(context).textTheme.headline6!.copyWith(
                  //fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal),
            ),
            Text(
              'Description',
              style: Theme.of(context).textTheme.headline6!.copyWith(
                  //fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal),
            ),
            // customTextFieldEmpty(
            //   obscure: false,
            //   controller: _name,
            //   hint: 'Description',
            // ),
          ],
        ),
      ),
    );
  }
}

class LibDialog extends StatelessWidget {
  final Object? lib;

  const LibDialog({Key? key, this.lib}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Lib Dialog'),
      content: Text(lib.toString()),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}

class LotDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController textField1Controller = TextEditingController();
    TextEditingController textField2Controller = TextEditingController();

    return Dialog(
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: textField1Controller,
              decoration: InputDecoration(labelText: 'Nom de lot'),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: textField2Controller,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Handle button press here
                String text1 = textField1Controller.text;
                String text2 = textField2Controller.text;
                // You can do whatever you want with the texts here
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Confirmer'),
            ),
          ],
        ),
      ),
    );
  }
}
