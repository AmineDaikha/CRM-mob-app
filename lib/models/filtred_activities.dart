import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/models/type_activity.dart';

import 'collaborator.dart';

class FiltredActivities {
  DateTime start;
  DateTime end;
  String state;
  TypeActivity type;
  Collaborator collborator;
  Team team;


  FiltredActivities({
    required this.start,
    required this.end,
    required this.state,
    required this.type,
    required this.collborator,
    required this.team,
  });
}
