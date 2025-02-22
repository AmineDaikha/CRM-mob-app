import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/team.dart';

import 'client.dart';
import 'familly.dart';
import 'pipeline.dart';
import 'sfamilly.dart';
import 'step_pip.dart';

class FiltredCatalog {
  Familly? selectedFamilly;
  SFamilly? selectedSFamilly;

  FiltredCatalog({
    this.selectedFamilly,
    this.selectedSFamilly,
  });
}
