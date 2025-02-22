import 'package:mobilino_app/models/contact.dart';
import 'package:mobilino_app/models/depot.dart';
import 'package:mobilino_app/models/familly.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/models/type_activity.dart';

import 'collaborator.dart';
import 'etablissement.dart';
import 'pipeline.dart';
import 'sfamilly.dart';

class User {
  String? firstName;
  String? lastName;
  String? userId;
  String? password;
  String? company;
  String? token;
  String? id;
  String? email;
  String? phone;
  String? roleCRM;
  String? role;
  String? salCode;
  String? repCode;
  String? image;
  Etablissement? etblssmnt;
  Depot? localDepot;
  int? equipeId;
  List<Team> teams = [];
  //List<Team> allTeams = [];
  List<Familly> famillies = [];
  List<SFamilly> sFamillies = [];
  List<Collaborator> collaborator = [];
  List<Collaborator> allCollaborator = [];
  List<Collaborator> selectedCollaborator = [];
  List<Contact> selectedContact = [];
  List<Pipeline> pipelines = [];
  List<Pipeline> pipelinesProject = [];
  List<TypeActivity> motifs = [];
  List<TypeActivity> typeProject = [];
  List<TypeActivity> typeReg = [];
  Map<int, String> privileges = Map();



  User({
    this.userId,
    this.password,
    this.company,
    this.id,
    this.token,
    this.roleCRM,
    this.image,
    this.email,
    this.phone,
    this.role,
    this.salCode,
    this.etblssmnt,
    this.firstName,
    this.lastName,
    this.localDepot,
    this.equipeId,
});
}
