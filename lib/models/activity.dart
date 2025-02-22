import 'package:equatable/equatable.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/process.dart';
import 'package:mobilino_app/models/type_activity.dart';
import 'package:mobilino_app/models/user.dart';

import 'contact.dart';

class Activity extends Equatable{
  String? id;
  Process? processes;
  TypeActivity? type;
  String? object;
  String? state;
  double? priority;
  double? emergency;
  String? image;
  String? typeTier;
  Contact? contact;
  String? comment;
  String? service;
  String? start;
  String? end;
  DateTime? dateStart;
  DateTime? dateEnd;
  User user;
  Client client;
  List<Collaborator> collaborators = [];
  List<Contact> contacts = [];
  String? contactTxt = '';
  String? collaboratorsTxt = '';
  String? motif;
  var res = null;

  Activity({
    this.id,
    required this.user,
    required this.client,
    this.processes,
    this.type,
    this.object,
    this.state,
    this.priority,
    this.emergency,
    this.typeTier,
    this.contact,
    this.comment,
    this.service,
    this.dateStart,
    this.dateEnd,
    this.start,
    this.end,
    this.collaboratorsTxt,
    this.contactTxt,
    this.res,
  });

  @override
  List<Object?> get props => [
        id,
        user,
        client,
        processes,
        type,
        object,
        state,
        priority,
        emergency,
        typeTier,
        contact,
        comment,
        service,
        dateStart,
        dateEnd,
        start,
        end
      ];

  Activity cloneActivity() {
    return Activity(
      user: user,
      client: client,
      id: id,
      type: type,
      emergency: emergency,
      processes: processes,
      dateStart: dateStart,
      priority: priority,
      state: state,
      object: object,
      dateEnd: dateEnd,
      start: start,
      service: service,
      comment: comment,
      contact: contact,
      end: end,
      typeTier: typeTier,
    );
  }
}
