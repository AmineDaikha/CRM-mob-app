import 'dart:async';

class FileNote {
  String type;
  String path;
  StreamSubscription<List<int>>? audioStreamSubscription;

  FileNote({required this.type, required this.path, this.audioStreamSubscription});
}
