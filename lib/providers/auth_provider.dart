import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobilino_app/constants/http_request.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:http/http.dart' as http;
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/database/database_helper.dart';
import 'package:mobilino_app/database/db_provider.dart';
import 'package:mobilino_app/models/step_pip.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/depot.dart';
import 'package:mobilino_app/models/etablissement.dart';
import 'package:mobilino_app/models/pipeline.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/models/step_pip.dart';
import 'package:mobilino_app/models/user.dart';
import 'package:mobilino_app/screens/authentication/etabliss_page.dart';
import 'package:mobilino_app/screens/home_page/home_page.dart';
import 'package:mobilino_app/utils/routers.dart';

class AuthProvider extends ChangeNotifier {
  // setter
  bool _isLoading = false;
  String _resMessage = "";

  // getter
  bool get isLoading => _isLoading;

  String get resMessage => _resMessage;

  //Login
  Future<int> loginUser({
    required User user,
    BuildContext? context,
  }) async {
    _isLoading = true;
    notifyListeners();
    String company = user.company!;
    //String url = AppUrl.baseUrl + AppUrl.auth;
    String url =
        'http://' + company + '.my-crm.net:5188/api/Auth/Authenticate';
    AppUrl.baseUrlApi = 'http://' + company + '.my-crm.net:5188/api/';
    ;
    AppUrl.baseUrl = 'http://' + company + '.my-crm.net:5188/';
    print('urls??: ${url}');
    print('urls??: ${AppUrl.baseUrlApi}');
    print('urls??: ${AppUrl.baseUrl}');
    //final body = {"email": user.email, "password": user.password, "company": user.comany};
    var body = jsonEncode({
      'username': user.userId,
      'password': user.password,
      "rememberme": true
    });
    //final body = '{"username": "admin", "password": "_?tYsu2J", "rememberme": true}';
    print(body);
    String userName = user.userId!;
    try {
      print('urlis: $url');
      http.Response req = await http.post(Uri.parse(url), body: body, headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + company + ".localhost:4200/"
      });

      print("res code is : ${req.statusCode}");
      print("res body: ${req.body}");
      if (req.statusCode == 200 || req.statusCode == 201) {
        var res = json.decode(req.body);
        //String s = res['etablissements'];
        Map<String, dynamic> jsonData = json.decode(req.body);
        List<dynamic> etablissementsData = jsonData['etablissements'];
        List<Etablissement> etablissementsList = etablissementsData
            .map((etablissement) => Etablissement.fromJson(etablissement))
            .toList();
        print('sizeEtb: ${etablissementsList.length}');
        AppUrl.etabList = etablissementsList;
        // List<dynamic> etblssmnts = json.decode(s);
        // etblssmnts.toList().forEach((etabliss) {
        //   AppUrl.user.etblssmnts!.add(Etablissement(
        //       code: etabliss['code'],
        //       name: etabliss['nom'],
        //       rs: etabliss['rs'],
        //       state: etabliss['etat']));
        // });
        print("res auth is: ${req}");
        _isLoading = false;
        _resMessage = "Login successfull!";
        notifyListeners();

        ///Save users data and then navigate to homepage
        final userId = userName;
        final token = res['token'];
        final provider = DatabaseProvider();
        // provider.saveEtablissements(etablissementsList.first);
        // AppUrl.user.etblssmnt = etablissementsList.first;
        provider.saveToken(token);
        provider.saveUserId(userId);
        AppUrl.user.token = token;
        AppUrl.user.userId = userId;
        AppUrl.user.password = user.password;
        // request get user
        final Map<String, String> headers = {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + company + ".localhost:4200/",
          'Authorization': 'Bearer $token',
        };
        url = AppUrl.getUser + userId;
        print('url getUser: ${url}');
        print('token is : ${token}');
        req = await http.get(Uri.parse(url), headers: headers);
        print("user res code is : ${req.statusCode}");
        print("user res body: ${req.body}");
        if (req.statusCode == 200) {
          res = json.decode(req.body);
          provider.saveRoleCRM(res['rolIdCRM']);
          AppUrl.user.roleCRM = res['rolIdCRM'];
          if (res['salCode'] != null) provider.saveSalCode(res['salCode']);
          AppUrl.user.salCode = res['salCode'];
          provider.saveImage(res['image']);
          AppUrl.user.image = res['image'];
          AppUrl.user.equipeId = res['equipeId'];
          user.equipeId = res['equipeId'];
          // request for get roles
          String roleCRM = res['rolIdCRM'];
          url = AppUrl.getRoles + roleCRM;
          print('url of getRoles $url');
          req = await http.get(Uri.parse(url), headers: headers);
          print("role res code is : ${req.statusCode}");
          print("role res body: ${req.body}");
          if (req.statusCode == 200) {
            res = json.decode(req.body);
            provider.saveRoleValue(res['name']);
            AppUrl.user.role = res['name'];
            // get Roles
            req = await http.get(
                Uri.parse(AppUrl.getMenuAuthorized + AppUrl.user.roleCRM!),
                headers: {
                  "Accept": "application/json",
                  "content-type": "application/json; charset=UTF-8",
                  "Referer": "http://" + company + ".localhost:4200/",
                  'Authorization': 'Bearer ${AppUrl.user.token}',
                });
            print("res MenuAcces code : ${req.statusCode}");
            print("res MenuAcces body: ${req.body}");
            if (req.statusCode == 200) {
              List<dynamic> data = json.decode(req.body);
              user.privileges.clear();
              data.toList().forEach((element) {
                user.privileges[element['mnuId']] = element['mnuLib'];
              });
              req = await http
                  .get(Uri.parse(AppUrl.getOneUser + userId), headers: {
                "Accept": "application/json",
                "content-type": "application/json; charset=UTF-8",
                "Referer": "http://" + company + ".localhost:4200/",
                'Authorization': 'Bearer ${AppUrl.user.token}',
              });
              print("res oneUser code: ${req.statusCode}");
              print("res oneUser body: ${req.body}");
              if (req.statusCode == 200) {
                res = json.decode(req.body);
                print('userName is: ${res['userName']}');
                user.firstName = res['firstName'];
                AppUrl.user.firstName = res['firstName'];
                user.lastName = res['lastName'];
                AppUrl.user.lastName = res['lastName'];
                user.email = res['email'];
                AppUrl.user.email = res['email'];
                user.salCode = res['salCode'];
                AppUrl.user.salCode = res['salCode'];
                user.repCode = res['repCode'];
                AppUrl.user.repCode = res['repCode'];
                user.phone = res['phoneNumber'];
                AppUrl.user.phone = res['phoneNumber'];
                print('urlLocalDepot: ' +
                    AppUrl.getLocalDepot +
                    '${user.salCode}/${AppUrl.user.etblssmnt!.code}');
                req = await http.get(
                    Uri.parse(AppUrl.getLocalDepot +
                        '${user.salCode}/${AppUrl.user.etblssmnt!.code}'),
                    headers: {
                      "Accept": "application/json",
                      "content-type": "application/json; charset=UTF-8",
                      "Referer": "http://" + company + ".localhost:4200/",
                      'Authorization': 'Bearer ${AppUrl.user.token}',
                    });
                print("res getLocalDepot code: ${req.statusCode}");
                print("res getLocalDepot body: ${req.body}");
                if (req.statusCode == 200) {
                  List<dynamic> data = json.decode(req.body);
                  data.toList().forEach((element) {
                    user.localDepot =
                        Depot(id: element['depCode'], name: element['depNom']);
                    AppUrl.user.localDepot =
                        Depot(id: element['depCode'], name: element['depNom']);
                    user.repCode = element['repCode'];
                    AppUrl.user.repCode = element['repCode'];
                  });
                  // get Equipes
                  url = AppUrl.getEquipes + AppUrl.user.equipeId!.toString();
                  print('url of getEquipes $url');
                  req = await http.get(Uri.parse(url), headers: headers);
                  print("equipes res code : ${req.statusCode}");
                  print("equipes res body: ${req.body}");
                  if (req.statusCode == 200 || req.statusCode == 201) {
                    List<dynamic> data = json.decode(req.body);
                    data.forEach((element) {
                      AppUrl.user.teams.add(Team(
                        id: element['id'],
                        lib: element['libelle'],
                        parentId: element['parentId'],
                        etbCode: element['etbCode'],
                        roleId: element['roleId'],
                      ));
                    });
                    // AppUrl.user.teams.insert(
                    //     0,
                    //     Team(
                    //       id: -1,
                    //       lib: 'Tout',
                    //     ));
                    // get Collaborateurs
                    AppUrl.user.collaborator = [];
                    //AppUrl.user.allTeams = List<Team>.from(AppUrl.user.teams);
                    for (Team team in AppUrl.user.teams) {
                      if (team.id == AppUrl.user.equipeId) {
                        AppUrl.user.collaborator.insert(
                            0,
                            Collaborator(
                                id: '-1',
                                userName: '${AppUrl.user.userId}',
                                salCode: AppUrl.user.salCode));
                        continue;
                      }
                      AppUrl.filtredOpporunity.team = AppUrl.user.teams
                          .where(
                              (thisTeam) => AppUrl.user.equipeId == thisTeam.id)
                          .first;
                      AppUrl.filtredCommandsClient.team = AppUrl.user.teams
                          .where(
                              (thisTeam) => AppUrl.user.equipeId == thisTeam.id)
                          .first;
                      String url = AppUrl.getCollaborateur + team.id.toString();
                      print('url of getCollaborateur $url');
                      try {
                        http.Response req =
                        await http.get(Uri.parse(url), headers: {
                          "Accept": "application/json",
                          "content-type": "application/json; charset=UTF-8",
                          "Referer":
                          "http://" + user.company! + ".localhost:4200/",
                          'Authorization': 'Bearer ${user.token}',
                        });
                        print("res collaborateur code is : ${req.statusCode}");
                        print("res collaborateur body: ${req.body}");
                        if (req.statusCode == 200 || req.statusCode == 201) {
                          List<dynamic> data = json.decode(req.body);
                          data.forEach((element) {
                            try {
                              user.collaborator.add(Collaborator(
                                id: element['id'],
                                userName: element['userName'],
                                salCode: element['salCode'],
                                repCode: element['repCode'],
                                equipeId: element['equipeId'],
                              ));
                            } catch (e) {
                              print('error: $e');
                            }
                          });
                        }
                        AppUrl.user.allCollaborator =
                        List<Collaborator>.from(AppUrl.user.collaborator);
                        AppUrl.filtredOpporunity.collaborateur =
                            AppUrl.user.collaborator.first;
                        AppUrl.filtredCommandsClient.collaborateur =
                            AppUrl.user.collaborator.first;
                        AppUrl.user.collaborator = [
                          Collaborator(
                              id: '-1',
                              userName: '${AppUrl.user.userId}',
                              salCode: AppUrl.user.salCode)
                        ];
                      } catch (e) {
                        print(e);
                      }
                    }
                    AppUrl.filtredOpporunity.team = AppUrl.user.teams
                        .where(
                            (thisTeam) => AppUrl.user.equipeId == thisTeam.id)
                        .first;
                    AppUrl.filtredCommandsClient.team = AppUrl.user.teams
                        .where(
                            (thisTeam) => AppUrl.user.equipeId == thisTeam.id)
                        .first;
                    AppUrl.filtredOpporunity.collaborateur =
                        AppUrl.user.collaborator.first;
                    AppUrl.filtredCommandsClient.collaborateur =
                        AppUrl.user.collaborator.first;
                    AppUrl.user.allCollaborator =
                    List<Collaborator>.from(AppUrl.user.collaborator);
                    AppUrl.user.company = user.company;
                    await HttpRequestApp().sendItinerary('CNX');
                    await getStartEnd(user);
                    // AppUrl.user.collaborator = [];
                    // // AppUrl.user.teams = List<Team>.from(AppUrl.user.teams.where(
                    // //     (element) => element.id != AppUrl.user.equipeId));
                    // for (Team team in AppUrl.user.teams) {
                    //   if(team.id == AppUrl.user.equipeId){
                    //     AppUrl.user.collaborator.insert(
                    //         0,
                    //         Collaborator(
                    //           id: '-1',
                    //           userName: '${AppUrl.user.userId}',
                    //           salCode: AppUrl.user.salCode
                    //         ));
                    //     continue;
                    //   }
                    //   try {
                    //     url = AppUrl.getCollaborateur + team.id.toString();
                    //     print('url of getCollaborateurs $url');
                    //     req = await http.get(Uri.parse(url), headers: headers);
                    //     print("res Collaborateur code : ${req.statusCode}");
                    //     print("res Collaborateur body: ${req.body}");
                    //     if (req.statusCode == 200 || req.statusCode == 201) {
                    //       List<dynamic> data = json.decode(req.body);
                    //       data.forEach((element) {
                    //         try {
                    //           AppUrl.user.collaborator.add(Collaborator(
                    //             id: element['id'],
                    //             userName: element['userName'],
                    //             salCode: element['salCode'],
                    //             repCode: element['repCode'],
                    //             equipeId: element['equipeId'],
                    //           ));
                    //           user.collaborator.add(Collaborator(
                    //             id: element['id'],
                    //             userName: element['userName'],
                    //             salCode: element['salCode'],
                    //             repCode: element['repCode'],
                    //             equipeId: element['equipeId'],
                    //           ));
                    //         } catch (e) {
                    //           print('error: $e');
                    //         }
                    //       });
                    //       print(
                    //           'collaborators size: ${AppUrl.user.collaborator.length}');
                    //     }
                    //   } catch (e) {
                    //     print(e);
                    //   }
                    // }
                    // AppUrl.filtredOpporunity.team = AppUrl.user.teams.where((thisTeam) => AppUrl.user.equipeId == thisTeam.id).first;
                    // AppUrl.filtredCommandsClient.team = AppUrl.user.teams.where((thisTeam) => AppUrl.user.equipeId == thisTeam.id).first;
                    // //AppUrl.filtredOpporunity.team = AppUrl.user.teams.first;
                    // AppUrl.user.allCollaborator =
                    // List<Collaborator>.from(AppUrl.user.collaborator);
                    // AppUrl.filtredOpporunity.collaborateur =
                    //     AppUrl.user.collaborator.first;
                    // AppUrl.filtredCommandsClient.collaborateur =
                    //     AppUrl.user.collaborator.first;
                    // AppUrl.user.collaborator = [Collaborator(
                    //   id: '-1',
                    //   userName: '${AppUrl.user.userId}',
                    //     salCode: AppUrl.user.salCode
                    // )];
                  }
                  provider.saveOneUser(user);
                  await getPipelines(user);
                }
                //provider.saveOneUser(user);
              }
              // if (etablissementsList.length > 1) {
              //
              //   PageNavigator(ctx: context).nextPage(page: EtablissPage(etablissementsList: etablissementsList));
              //   return 10;
              // } else if (etablissementsList.length == 1) {
              //
              // }
              return 0;
            } else {
              return 1;
            }

            // DatabaseProvider().getUser().then((value) {
            //   getMenuAcces(value).then((value) {
            //     print('valur of getMenuAcces: $value');
            //     if (value!) {
            //       return 0;
            //     } else {
            //       return 1;
            //     }
            //   });
            // });
            // url = 'http://"+company+".my-crm.net:5188/api/Roles/all';
            // req = await http.get(Uri.parse(url), headers: headers);
            // print("role all res code is : ${req.statusCode}");
            // print("role all res body: ${req.body}");
            return 1;
          }
        }
        //Navigator.pushNamedAndRemoveUntil(context!, '/home', (route) => false);
      } else {
        // final res = json.decode(req.body);
        // print('rese in err' + res);
        // _isLoading = false;
        notifyListeners();
        return 2;
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = "Internet connection is not available ";
      notifyListeners();
      print(":::: $_resMessage");
      return 1;
    } catch (e) {
      print('hherr: $e');
      return 1;
    }
    // catch (e) {
    //   _isLoading = false;
    //   _resMessage = "Please try again`";
    //   notifyListeners();
    //
    //   print("hmm:::: $e");
    // }

    return 1;
  }

  // Function to fetch JSON data from an API
  Future<bool?> getMenuAcces(User user) async {
    // for rights
    http.Response req = await http
        .get(Uri.parse(AppUrl.getMenuAuthorized + user.roleCRM!), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + user.company! + ".localhost:4200/",
      'Authorization': 'Bearer ${user.token}',
    });
    print("res MenuAcces code : ${req.statusCode}");
    print("res MenuAcces body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      user.privileges.clear();
      data.toList().forEach((element) {
        user.privileges[element['mnuId']] = element['mnuLib'];
      });

      return true;
    } else {
      return false;
    }
  }

  Future<bool> getTeams(User user) async {
    // for rights
    String url = AppUrl.getEquipes + user.equipeId!.toString();
    print('url of getEquipes $url');
    try {
      http.Response req = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + user.company! + ".localhost:4200/",
        'Authorization': 'Bearer ${user.token}',
      });
      print("equipes res code is : ${req.statusCode}");
      print("equipes res body: ${req.body}");
      if (req.statusCode == 200 || req.statusCode == 201) {
        List<dynamic> data = json.decode(req.body);
        data.forEach((element) {
          AppUrl.user.teams.add(Team(
            id: element['id'],
            lib: element['libelle'],
            parentId: element['parentId'],
            etbCode: element['etbCode'],
            roleId: element['roleId'],
          ));
        });
        // AppUrl.user.teams.insert(
        //     0,
        //     Team(
        //       id: -1,
        //       lib: 'Tout',
        //     ));
        AppUrl.filtredOpporunity.team = AppUrl.user.teams
            .where((thisTeam) => AppUrl.user.equipeId == thisTeam.id)
            .first;
        AppUrl.filtredCommandsClient.team = AppUrl.user.teams
            .where((thisTeam) => AppUrl.user.equipeId == thisTeam.id)
            .first;
        //AppUrl.filtredOpporunity.team = AppUrl.user.teams.first;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> getUpdate() async {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> rows = await dbHelper.queryAllRows();
    for (int i = 0; i < rows.length; i++) {
      print('one row : ${rows[i][DatabaseHelper.columnSalCode]}');
      Map<String, dynamic> jsonObject = {
        "salCode": rows[i][DatabaseHelper.columnSalCode],
        "etbCode": rows[i][DatabaseHelper.columnEtbCode],
        "date": rows[i][DatabaseHelper.columnEtbCode],
        "longitude": rows[i][DatabaseHelper.columnEtbCode],
        "latitude": rows[i][DatabaseHelper.columnEtbCode],
        "type": 'CPT'
      };
      http.Response req = await http.post(Uri.parse(AppUrl.itinerary),
          body: jsonEncode(jsonObject),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
            "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
          });
      print("res itinerary code : ${req.statusCode}");
      print("res itinerary body: ${req.body}");
    }
    dbHelper.deleteAll();
    return false;
  }

  Future<bool> getStartEnd(User user) async {
    String url = AppUrl.getSociete;
    print('url of getStartEnd $url');
    try {
      http.Response req = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + user.company! + ".localhost:4200/",
        'Authorization': 'Bearer ${user.token}',
      });
      print("startEnd res code is : ${req.statusCode}");
      print("startEnd res body: ${req.body}");
      if (req.statusCode == 200 || req.statusCode == 201) {
        var res = json.decode(req.body);
        if (res['heureDebut'] != null) {
          List<String> tab = res['heureDebut'].toString().split(':');
          AppUrl.startTime = DateTime(
              DateTime
                  .now()
                  .year,
              DateTime
                  .now()
                  .month,
              DateTime
                  .now()
                  .day,
              int.parse(tab[0]),
              int.parse(tab[1]),
              int.parse(tab[2]));
        }
        if (res['heureFin'] != null) {
          List<String> tab = res['heureFin'].toString().split(':');
          AppUrl.endTime = DateTime(
              DateTime
                  .now()
                  .year,
              DateTime
                  .now()
                  .month,
              DateTime
                  .now()
                  .day,
              int.parse(tab[0]),
              int.parse(tab[1]),
              int.parse(tab[2]));
        }
        if (res['syncroTime'] != null) {
          AppUrl.syncroTime = res['syncroTime'];
        }
        if (res['jourDepasAct'] != null) {
          AppUrl.dayDepasAct = res['jourDepasAct'];
        }
        if (res['jourDepasCoursAct'] != null) {
          AppUrl.dayDepasCoursAct = res['jourDepasCoursAct'];
        }
      }
      return true;
    } catch (_) {}
    return false;
  }

  Future<bool> getCollaborateurs(User user) async {
    // for rights
    AppUrl.user.collaborator = [];
    //AppUrl.user.allTeams = List<Team>.from(AppUrl.user.teams);
    for (Team team in AppUrl.user.teams) {
      if (team.id == AppUrl.user.equipeId) {
        AppUrl.user.collaborator.insert(
            0,
            Collaborator(
                id: '-1', userName: '${AppUrl.user.userId}', salCode: AppUrl.user.salCode));
        continue;
      }
      String url = AppUrl.getCollaborateur + team.id.toString();
      print('url of getCollaborateur $url');
      try {
        http.Response req = await http.get(Uri.parse(url), headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + user.company! + ".localhost:4200/",
          'Authorization': 'Bearer ${user.token}',
        });
        print("res collaborateur code is : ${req.statusCode}");
        print("res collaborateur body: ${req.body}");
        if (req.statusCode == 200 || req.statusCode == 201) {
          List<dynamic> data = json.decode(req.body);
          data.forEach((element) {
            try {
              user.collaborator.add(Collaborator(
                id: element['id'],
                userName: element['userName'],
                salCode: element['salCode'],
                repCode: element['repCode'],
                equipeId: element['equipeId'],
              ));
            } catch (e) {
              print('error: $e');
            }
          });
        }
        AppUrl.user.allCollaborator =
        List<Collaborator>.from(AppUrl.user.collaborator);
        AppUrl.filtredOpporunity.collaborateur = AppUrl.user.collaborator.first;
        AppUrl.filtredCommandsClient.collaborateur =
            AppUrl.user.collaborator.first;
        AppUrl.user.collaborator = [
          Collaborator(id: '-1', userName: '${AppUrl.user.userId}', salCode: AppUrl.user.salCode)
        ];
      } catch (e) {
        print(e);
      }
    }
    AppUrl.filtredOpporunity.collaborateur = AppUrl.user.collaborator.first;
    AppUrl.filtredCommandsClient.collaborateur = AppUrl.user.collaborator.first;
    AppUrl.user.allCollaborator =
    List<Collaborator>.from(AppUrl.user.collaborator);
    return true;
  }

  Future<bool> getPipelines(User user) async {
    // for rights
    AppUrl.user.pipelines = [];
    String url = AppUrl.getPipelines;
    print('url of getPipelines $url');
    try {
      // get all pipelines
      http.Response req = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + user.company! + ".localhost:4200/",
        'Authorization': 'Bearer ${user.token}',
      });
      print("res piplines code is : ${req.statusCode}");
      print("res piplines body: ${req.body}");
      if (req.statusCode == 200 || req.statusCode == 201) {
        List<dynamic> data = json.decode(req.body);
        for (int i = 0; i < data.length; i++) {
          var element = data[i];
          if(element['processId'] == 4 || element['processId'] == 3){
            continue;
          }
          Pipeline pipeline =
          Pipeline(id: element['id'], name: element['libelle']);
          // get States of pipeline
          url = AppUrl.getPipelinesSteps + element['id'].toString();

          http.Response req = await http.get(Uri.parse(url), headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
            "Referer": "http://" + user.company! + ".localhost:4200/",
            'Authorization': 'Bearer ${user.token}',
          });
          print("res piplineSteps code is : ${req.statusCode}");
          print("res piplineSteps body: ${req.body}");
          List<dynamic> steps = json.decode(req.body);
          steps.forEach((step) {
            pipeline.steps.add(StepPip(
                id: step['id'],
                name: step['libelle'],
                color: element['couleur']));
          });
          // get all teams of pipeline
          url = AppUrl.getTeamsPipeline + element['id'].toString();
          print('url getTeamsPipeline $url');
          req = await http.get(Uri.parse(url), headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
            "Referer": "http://" + user.company! + ".localhost:4200/",
            'Authorization': 'Bearer ${user.token}',
          });
          print("res teamPiplines code is : ${req.statusCode}");
          print("res teamPiplines body: ${req.body}");
          if (req.statusCode == 200 || req.statusCode == 201) {
            List<dynamic> teams = json.decode(req.body);
            List<Team> teamsList = [];
            teams.forEach((oneTeam) {
              teamsList = List<Team>.from(AppUrl.user.teams).where((item) {
                if (item.id == oneTeam['id']) {
                  item.pipelines.add(pipeline);
                  return true;
                }
                return false;
              }).toList();
              if (teamsList.isNotEmpty) {
                Pipeline pip =
                Pipeline(id: element['id'], name: element['libelle']);
                pip.teams = List<Team>.from(teamsList);
                AppUrl.user.pipelines.add(pip);
              }
            });
            //List<Team> teamsList = List<Team>.from(AppUrl.user.teams).where((element) => false).toList();
          }
        }
        print('pipSize: ${AppUrl.user.pipelines.length}');
        print('teamSize: ${AppUrl.user.teams.last.lib}');
        AppUrl.filtredOpporunity.pipeline =
            AppUrl.filtredOpporunity.team!.pipelines.first;
        AppUrl.filtredOpporunity.stepPip =
            AppUrl.filtredOpporunity.pipeline!.steps.first;
      }
    } catch (e) {
      print(e);
    }
    return true;
  }

  void clear() {
    _resMessage = "";
    // _isLoading = false;
    notifyListeners();
  }
}
