import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/team.dart';

import 'client.dart';
import 'pipeline.dart';
import 'step_pip.dart';

class FiltredCommandsClient {
  DateTime date;
  DateTime dateEnd;
  Team? team;
  Collaborator? collaborateur;
  Pipeline? pipeline;
  StepPip? stepPip;
  StepPip? stepPipProject;
  StepPip? stepPipSalon;
  Client? client;
  List<Client> clients = [];
  List<StepPip> projectSteps =[];
  List<StepPip> salonSteps =[];
  List<StepPip> ticketsSteps =[];
  bool allCollaborators = true;

  FiltredCommandsClient(
      {required this.date,
      required this.dateEnd,
      this.team,
      this.collaborateur,
      this.pipeline,
      this.stepPip});
}
