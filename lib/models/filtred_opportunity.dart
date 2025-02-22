import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/team.dart';

import 'pipeline.dart';
import 'step_pip.dart';

class FiltredOpporunity {
  DateTime date;
  DateTime dateEnd;
  Team? team;
  Collaborator? collaborateur;
  Pipeline? pipeline;
  StepPip? stepPip;

  FiltredOpporunity({
    required this.date,
    required this.dateEnd,
    this.team,
    this.collaborateur,
    this.pipeline,
    this.stepPip,
  });
}
