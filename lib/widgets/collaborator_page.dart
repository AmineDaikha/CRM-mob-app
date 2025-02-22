import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/constants/utils.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/payment.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/providers/payment_provider.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/text_field.dart';
import 'package:provider/provider.dart';

import 'confirmation_dialog.dart';

class CollaboratorsPage extends StatefulWidget {
  CollaboratorsPage({
    super.key,
  });

  @override
  State<CollaboratorsPage> createState() => _CollaboratorsPageState();
}

class _CollaboratorsPageState extends State<CollaboratorsPage> {
  List<Collaborator> allCollaborator = [];
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchData() async {
    allCollaborator = [];
    AppUrl.user.selectedCollaborator = [];
    //AppUrl.user.allTeams = List<Team>.from(AppUrl.user.teams);
    for (Team team in AppUrl.user.teams) {
      if (team.id == AppUrl.user.equipeId) {
        allCollaborator.insert(
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
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/",
          'Authorization': 'Bearer ${AppUrl.user.token}',
        });
        print("res collaborateur code: ${req.statusCode}");
        print("res collaborateur body: ${req.body}");
        if (req.statusCode == 200 || req.statusCode == 201) {
          List<dynamic> data = json.decode(req.body);
          data.forEach((element) {
            try {
              allCollaborator.add(Collaborator(
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
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Future is still running, return a loading indicator or some placeholder.
            return Center(
              child: Row(
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                  ),
                  Center(
                    child: Container(
                      color: Colors.white,
                      margin: EdgeInsets.only(left: 15),
                      child: Text(
                        'Loading...',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // There was an error in the future, handle it.
            return Text('Error: ${snapshot.error}');
          }
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.white, // Set icon color to white
              ),
              backgroundColor: Theme.of(context).primaryColor,
              title: ListTile(
                title: Text(
                  'Collaborateurs',
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            body: Form(
              key: formKey,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: (allCollaborator.length == 0)
                            ? Center(
                                child: Text(
                                  'Aucun collaborateur!',
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                              )
                            : ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) => EchItem(
                                      collaborator: allCollaborator[index],
                                    ),
                                itemCount: allCollaborator.length),
                      ))
                    ],
                  ),
                  // Align(
                  //   alignment: Alignment.bottomCenter,
                  //   child: Container(
                  //     height: 70,
                  //     margin: EdgeInsets.only(bottom: 10),
                  //     width: double.infinity,
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         ElevatedButton(
                  //           style: ButtonStyle(
                  //             backgroundColor: MaterialStateProperty.all<Color>(
                  //                 primaryColor), // Change the color here
                  //           ),
                  //           onPressed: () async {},
                  //           child: Text(
                  //             'Confirmer',
                  //             style: Theme.of(context)
                  //                 .textTheme
                  //                 .headline4!
                  //                 .copyWith(
                  //                     color: Colors.white,
                  //                     fontWeight: FontWeight.bold),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        });
  }
}

class EchItem extends StatefulWidget {
  final Collaborator collaborator;

  //final String paymentVal;

  const EchItem({super.key, required this.collaborator});

  @override
  State<EchItem> createState() => _EchItemState();
}

class _EchItemState extends State<EchItem> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                activeColor: primaryColor,
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      AppUrl.user.selectedCollaborator.add(widget.collaborator);
                    } else {
                      AppUrl.user.selectedCollaborator
                          .remove(widget.collaborator);
                    }
                    isSelected = value;
                  });
                },
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                //crossAxisAlignment: CrossAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.collaborator.userName}',
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(color: primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.grey,
        )
      ],
    );
  }
}
