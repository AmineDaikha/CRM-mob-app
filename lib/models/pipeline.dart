import 'step_pip.dart';
import 'team.dart';

class Pipeline {
  int? id;
  String? name;
  List<Team> teams = [];
  List<StepPip> steps = [];

  Pipeline({this.id, this.name});
}
