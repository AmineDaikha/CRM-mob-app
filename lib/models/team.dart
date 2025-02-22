import 'pipeline.dart';

class Team {
  int? id;
  String? lib;
  int? parentId;
  String? etbCode;
  String? roleId;

  List<Pipeline> pipelines = [];

  Team({this.id, this.lib, this.parentId, this.etbCode, this.roleId});
}
