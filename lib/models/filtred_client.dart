import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/team.dart';

import 'client.dart';
import 'familly.dart';
import 'pipeline.dart';
import 'sfamilly.dart';
import 'step_pip.dart';

class FiltredClient {
  Familly? selectedFamilly;
  SFamilly? selectedSFamilly;
  bool first = true;

  FiltredClient({
    this.selectedFamilly,
    this.selectedSFamilly,
  });
}
