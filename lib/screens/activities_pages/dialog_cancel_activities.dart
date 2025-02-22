import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/activity.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/filtred_activities.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/models/type_activity.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/widgets/alert.dart';

class CancelActivitiesDialog extends StatefulWidget {
  final Activity activity;

  const CancelActivitiesDialog({super.key, required this.activity});

  @override
  State<CancelActivitiesDialog> createState() => _CancelActivitiesDialogState();
}

class _CancelActivitiesDialogState extends State<CancelActivitiesDialog> {
  // List<String> states = [
  //   'Problème 1',
  //   'Problème 2',
  // ];

  TypeActivity? selectedStateItem;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (AppUrl.user.motifs.isNotEmpty)
      selectedStateItem = AppUrl.user.motifs.first;
    print('hhhselectedStateItem $selectedStateItem');
  }

  @override
  Widget build(BuildContext context) {
    //selectedStateItem = states.first;
    print('hhhselectedStateItem $selectedStateItem');
    return SimpleDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Annulation de l\' activites',
        style: Theme.of(context).textTheme.headline2,
      ),
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            // Set desired border radius
            color: Colors.white,
          ),
          width: 450,
          height: 200,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Motif : ',
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
                      'Selectioner le motif',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.grey),
                    ),
                    value:  selectedStateItem,
                    onChanged: (newValue) {
                      setState(() {
                        selectedStateItem = newValue!;
                      });
                    },
                    items: AppUrl.user.motifs
                        .map<DropdownMenuItem<TypeActivity>>(
                            (TypeActivity value) {
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onPressed: () {
                    if(AppUrl.user.motifs.isEmpty){
                      showAlertDialog(context, 'Il faut choisir le motif d\'abord');
                      return;
                    }
                    widget.activity.motif = selectedStateItem!.name;
                    Navigator.of(context).pop(widget.activity);
                  },
                  child: const Text(
                    "Confirmer",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
