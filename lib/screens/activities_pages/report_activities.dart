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

class ReportedActivitiesDialog extends StatefulWidget {
  final Activity activity;

  const ReportedActivitiesDialog(
      {super.key, required this.activity});

  @override
  State<ReportedActivitiesDialog> createState() =>
      _ReportedActivitiesDialogState();
}

class _ReportedActivitiesDialogState extends State<ReportedActivitiesDialog> {

  late DateTime selectedStartTimeDate;
  late DateTime selectedEndTimeDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedStartTimeDate = widget.activity.dateStart!;
    selectedEndTimeDate = widget.activity.dateEnd!;
  }

  Future<void> showDateTimeDialog(BuildContext context, String type) async {
    // Initialize result variables
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    // Show date picker
    selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: primaryColor,
              // Day color
              buttonTheme: ButtonThemeData(
                colorScheme: ColorScheme.light(
                  primary: primaryColor, // Change the color here
                ),
              ),
              colorScheme: ColorScheme.light(primary: primaryColor)
                  .copyWith(secondary: primaryColor),
              // Button text color
            ),
            child: child!,
          );
        }
    );

    // Check if date was selected
    if (selectedDate != null) {
      // Show time picker
      selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                primaryColor: primaryColor,
                // Day color
                buttonTheme: ButtonThemeData(
                  colorScheme: ColorScheme.light(
                    primary: primaryColor, // Change the color here
                  ),
                ),
                colorScheme: ColorScheme.light(primary: primaryColor)
                    .copyWith(secondary: primaryColor),
                // Button text color
              ),
              child: child!,
            );
          }
      );

      // Handle both date and time selection
      if (selectedTime != null) {
        // Combine date and time and show final result
        DateTime selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        if (type == 'start')
          selectedStartTimeDate = selectedDateTime;
        else
          selectedEndTimeDate = selectedDateTime;
        print('date:: $type');
        setState(() {

        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //selectedStateItem = states.first;
    AppUrl.changed = false;
    return SimpleDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Reporter l\'activites',
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
                SizedBox(height: 15,),
                InkWell(
                  onTap: () {
                    showDateTimeDialog(context, 'start');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: primaryColor,
                      ),
                      Container(
                        width: 50,
                        child: Text(
                          'Début',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                      Text(
                        '${DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedStartTimeDate)}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () {
                    showDateTimeDialog(context, 'end');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: primaryColor,
                      ),
                      Container(
                        width: 50,
                        child: Text(
                          'Fin  ',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                      Text(
                        '${DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedEndTimeDate)}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onPressed: () {
                    if (DateTime.now()
                        .difference(selectedStartTimeDate)
                        .inMinutes >
                        0) {
                      showAlertDialog(context,
                          'Date début doit être supérieur à date actuelle !');
                      return;
                    }
                    if (selectedStartTimeDate
                        .difference(selectedEndTimeDate)
                        .inSeconds >=
                        0) {
                      showAlertDialog(context,
                          'Date début doit être supérieur à date fin !');
                      return;
                    }
                    widget.activity.dateStart = selectedStartTimeDate;
                    widget.activity.dateEnd = selectedEndTimeDate;

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartTimeDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: primaryColor,
              // Day color
              buttonTheme: ButtonThemeData(
                colorScheme: ColorScheme.light(
                  primary: primaryColor, // Change the color here
                ),
              ),
              colorScheme: ColorScheme.light(primary: primaryColor)
                  .copyWith(secondary: primaryColor),
              // Button text color
            ),
            child: child!,
          );
        }
    );
    print('date is : ${DateFormat('yyyy-MM-dd').format(picked!)}');
    if (picked != null && picked != selectedStartTimeDate) {
      setState(() {
        selectedStartTimeDate = picked;
        print(
            'date is : ${DateFormat('yyyy-MM-dd').format(selectedStartTimeDate)}');
      });
    }
  }

  Future<void> _selectDateEnd(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndTimeDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: primaryColor,
              // Day color
              buttonTheme: ButtonThemeData(
                colorScheme: ColorScheme.light(
                  primary: primaryColor, // Change the color here
                ),
              ),
              colorScheme: ColorScheme.light(primary: primaryColor)
                  .copyWith(secondary: primaryColor),
              // Button text color
            ),
            child: child!,
          );
        }
    );
    print('date is : ${DateFormat('yyyy-MM-dd').format(picked!)}');
    if (picked != null && picked != selectedEndTimeDate) {
      setState(() {
        selectedEndTimeDate = picked;
        print(
            'date is : ${DateFormat('yyyy-MM-dd').format(selectedEndTimeDate)}');
      });
    }
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
