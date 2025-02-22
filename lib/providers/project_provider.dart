import 'package:flutter/material.dart';
import 'package:mobilino_app/models/project.dart';

class ProjectProvider extends ChangeNotifier {
  List<Project> projectList = [];

  List<Project> getProjectByStat(int stat){
    return projectList.where((project) => project.stat == stat).toList();
  }
}
