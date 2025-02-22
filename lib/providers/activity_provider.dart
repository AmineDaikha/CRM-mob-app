import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobilino_app/models/activity.dart';
import 'package:mobilino_app/models/filtred_activities.dart';

class ActivityProvider extends ChangeNotifier {
  List<Activity> activityList = [];

  // List<Activity> filtredListActivity(String state, DateTime date) =>
  //     activityList
  //         .where((activity) =>
  //             activity.state == state &&
  //             DateFormat('yyyy-MM-dd 00:00:00').format(activity.dateStart!) ==
  //                 DateFormat('yyyy-MM-dd 00:00:00').format(date))
  //         .toList();

  List<Activity> filtredListActivity(FiltredActivities filtred) {
    if (filtred.state == 'Tout' && filtred.type.name == 'Tout') {
      return activityList
          // .where((activity) =>
          //     DateFormat('yyyy-MM-dd').format(activity.dateStart!) ==
          //     DateFormat('yyyy-MM-dd').format(filtred.start))
          .toList();
    } else {
      List<Activity> list = [];
      if (filtred.state != 'Tout')
        list = activityList
            .where((activity) =>
                activity.state == filtred.state
                //     &&
                // DateFormat('yyyy-MM-dd').format(activity.dateStart!) ==
                //     DateFormat('yyyy-MM-dd').format(filtred.start)
        )
            .toList();
      if (filtred.type.name != 'Tout')
        list = list
            .where((activity) =>
        activity.type!.name == filtred.type.name
            // &&
            // DateFormat('yyyy-MM-dd').format(activity.dateStart!) ==
            //     DateFormat('yyyy-MM-dd').format(filtred.start)
        )
            .toList();
      //print('type: ${list[0].type!.name} filterType: ${filtred.type}');
      return list;
    }
  }
}
