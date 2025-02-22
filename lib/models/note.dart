import 'package:mobilino_app/models/file_note.dart';

import 'client.dart';
import 'collaborator.dart';

class Note {
  static final String TEXT = 'txt';

  Client? client;
  String type;
  String? title;
  String? text;
  DateTime? date;
  List<FileNote> files = [];
  String? collaboratorsTxt = '';
  List<Collaborator> collaborators = [];

  Note({
    required this.type,
    this.title,
    this.text,
    this.collaboratorsTxt,
    this.client,
    this.date,
  });
}
