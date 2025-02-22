import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/constants/utils.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/file_note.dart';
import 'package:mobilino_app/models/note.dart';
import 'package:mobilino_app/models/pipeline.dart';
import 'package:mobilino_app/models/project.dart';
import 'package:mobilino_app/models/step_pip.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/models/type_activity.dart';
import 'package:mobilino_app/providers/clients_map_provider.dart';
import 'package:mobilino_app/providers/note_provider.dart';
import 'package:mobilino_app/providers/project_provider.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/drawers/project_drawer.dart';
import 'package:provider/provider.dart';

import 'dialog_filtred_projects.dart';
import 'add_text_note_page.dart';
import 'project_page.dart';

class ProjectsListPage extends StatefulWidget {
  const ProjectsListPage({super.key});

  static const String routeName = '/projects';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => ProjectsListPage(),
    );
  }

  @override
  State<ProjectsListPage> createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends State<ProjectsListPage> {
  @override
  initState() {
    super.initState();
    AppUrl.filtredCommandsClient.clients = [Client(id: '-1', name: 'Tout')];
    AppUrl.filtredCommandsClient.client =
        AppUrl.filtredCommandsClient.clients.first;
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   showLoaderDialog(context);
    //   _fetchData(context).then((value) {
    //     Navigator.pop(context);
    //   });
    // });
  }

  Future<bool> getProjectSteps() async {
    // for rights
    try {
      AppUrl.filtredCommandsClient.projectSteps.clear();
      String url = AppUrl.getPipelinesSteps + '4';
      http.Response req = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/",
        'Authorization': 'Bearer ${AppUrl.user.token}',
      });
      print("res projectSteps code is : ${req.statusCode}");
      print("res projectSteps body: ${req.body}");
      List<dynamic> steps = json.decode(req.body);
      steps.forEach((step) {
        AppUrl.filtredCommandsClient.projectSteps.add(StepPip(
          id: step['id'],
          name: step['libelle'],
          color: '',
        ));
      });
      // AppUrl.filtredCommandsClient.stepPipProject =
      //     AppUrl.filtredCommandsClient.projectSteps.first;
    } catch (e) {
      print(e);
    }
    return true;
  }

  Future<void> fetchDataTypeProject() async {
    String url = AppUrl.getTypesProject;
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res typeProject code : ${req.statusCode}");
    print("res typeProject body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      //activitiesProcesses[process] = types;
      data.toList().forEach((element) {
        AppUrl.user.typeProject.add(TypeActivity(
          id: element['id'],
          code: element['code'],
          name: element['lib'],
        ));
      });
      //activitiesProcesses[process] = types;
    }
  }

  Future<void> fetchData() async {
    //print('image: ${AppUrl.baseUrl}${AppUrl.user.image}');
    await fetchDataTypeProject();
    await getProjectSteps();
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    provider.projectList.clear();
    String url = '';
    try {
      if (AppUrl.filtredCommandsClient.stepPipProject!.id == -1)
        url = AppUrl.getAllProjects +
            '?dateDebut=${DateFormat('yyyy-MM-ddT00:00:00').format(AppUrl.filtredCommandsClient.date)}&dateFin=${DateFormat('yyyy-MM-ddT23:59:59').format(AppUrl.filtredCommandsClient.dateEnd)}&salCode=${AppUrl.user.salCode}&etbCode=${AppUrl.user.etblssmnt!.code}';
      else
        url = AppUrl.getAllProjects +
            '?dateDebut=${DateFormat('yyyy-MM-ddT00:00:00').format(AppUrl.filtredCommandsClient.date)}&dateFin=${DateFormat('yyyy-MM-ddT23:59:59').format(AppUrl.filtredCommandsClient.dateEnd)}&salCode=${AppUrl.user.salCode}&etbCode=${AppUrl.user.etblssmnt!.code}&etape=${AppUrl.filtredCommandsClient.stepPipProject!.id}';
    } catch (e) {
      url = AppUrl.getAllProjects +
          '?dateDebut=${DateFormat('yyyy-MM-ddT00:00:00').format(AppUrl.filtredCommandsClient.date)}&dateFin=${DateFormat('yyyy-MM-ddT23:59:59').format(AppUrl.filtredCommandsClient.dateEnd)}&salCode=${AppUrl.user.salCode}&etbCode=${AppUrl.user.etblssmnt!.code}';
    }
    print('url : $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res allProjects code : ${req.statusCode}");
    print("res allProjects body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      List<dynamic> data = json.decode(req.body);
      print('nbPro: ${data.length}');
      //data.forEach((element) {
      for (int i = 0; i < data.length; i++) {
        var element = data[i];
        // if (element['etbCode'] != AppUrl.user.etblssmnt!.code) continue;
        var elementClient = data[i]['tiers'];
        print('état : ${element['etat']}');
        Client client =
            Client(id: elementClient['pcfCode'], name: elementClient['rs']);
        int idStep = element['etat'];
        String status = AppUrl.filtredCommandsClient.projectSteps
            .where((element) => element.id == idStep)
            .first
            .name;
        Project project = Project(
            res: element,
            object: element['libelle'],
            client: client,
            code: element['code'],
            stat: element['etat'],
            status: status,
            endDate: DateTime.parse(element['dateFin']),
            startDate: DateTime.parse(element['dateDebut']));
        provider.projectList.add(project);

        //});}
      }
      print('sizeIS: ${provider.projectList.length}');
      provider.notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    PageNavigator page = PageNavigator(ctx: context);
    return FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Future is still running, return a loading indicator or some placeholder.
            return AlertDialog(
              content: Container(
                  width: 200,
                  height: 100,
                  child: Image.asset('assets/CRM-Loader.gif')),
            );
          } else if (snapshot.hasError) {
            // There was an error in the future, handle it.
            print('Error: ${snapshot.hasError} ${snapshot.error} ');
            return AlertDialog(
              content: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  // Text('Error: ${snapshot.error}')
                  Expanded(
                    child: Text(
                        'Nous sommes désolé, la qualité de votre connexion ne vous permet pas de vous connecter à votre serveur.'
                        ' Veuillez réessayer ultérieurement. Merci'),
                  ),
                ],
              ),
            );
          } else
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                  drawer: DrawerProjectsPage(),
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(100),
                    child: AppBar(
                      iconTheme: IconThemeData(
                        color: Colors.white, // Set icon color to white
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Projets',
                            style: Theme.of(context)
                                .textTheme
                                .headline3!
                                .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Du : ${DateFormat('dd-MM-yyyy').format(AppUrl.filtredCommandsClient.date)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Au : ${DateFormat('dd-MM-yyyy').format(AppUrl.filtredCommandsClient.dateEnd)}, de : ${AppUrl.filtredCommandsClient.collaborateur!.userName}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Pipeline : Appels d\'offres & consultations',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(20.0),
                        // Adjust this as needed
                        child: Container(
                          color: Colors.white,
                          child: TabBar(
                              //isScrollable: true,
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor),
                              labelColor: Theme.of(context).primaryColor,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Theme.of(context).primaryColor,
                              indicator: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                width: 2.5,
                                color: Theme.of(context).primaryColor,
                              ))),
                              tabs: [
                                Tab(
                                  text: 'Pipeline',
                                  //icon: Icon(Icons.bar_chart),
                                ),
                                Tab(
                                  text: 'Liste',
                                  //icon: Icon(Icons.list),
                                ),
                              ]),
                        ),
                      ),
                      backgroundColor: primaryColor,
                      actions: [
                        IconButton(
                            onPressed: () {
                              //_showDatePicker(context);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return FiltredProjectsDialog();
                                },
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            icon: Icon(
                              Icons.sort,
                              color: Colors.white,
                            ))
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      PipelineProjectFragment(),
                      ListProjectFragment(),
                    ],
                  )),
            );
        });
  }
}

class PipelineProjectFragment extends StatefulWidget {
  const PipelineProjectFragment({
    super.key,
  });

  @override
  State<PipelineProjectFragment> createState() =>
      _PipelineProjectFragmentState();
}

class _PipelineProjectFragmentState extends State<PipelineProjectFragment> {
  int selectedItemIndex = 0; // Index of the selected item

  @override
  Widget build(BuildContext context) {
    print('fffff: $selectedItemIndex');
    return Column(
      children: [
        Container(
          height: 50.0, // Adjust the height of the container
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppUrl.filtredCommandsClient.projectSteps.length,
            // Number of items
            itemBuilder: (context, index) {
              return Consumer<ProjectProvider>(
                  builder: (context, provider, snapshot) {
                List<Project> projectList = [];
                if (provider.projectList.length > 0) {
                  print(
                      'zzzzzzz: ${provider.projectList.first.stat} index: ${index + 1}');
                }
                projectList = provider.getProjectByStat(
                    index + AppUrl.filtredCommandsClient.projectSteps.first.id);
                return GestureDetector(
                  onTap: () {
                    // Handle item tap
                    setState(() {
                      selectedItemIndex = index;
                    });
                  },
                  child: Container(
                    width: 120.0,
                    // Adjust the width of each item
                    margin: EdgeInsets.all(8.0),
                    decoration: selectedItemIndex == index
                        ? BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                            width: 2.5,
                            color: Theme.of(context).primaryColor,
                          )))
                        : BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                            width: 2.5,
                            color: Colors.transparent,
                          ))),
                    // color: selectedItemIndex == index
                    //     ? Colors.blue // Color when item is selected
                    //     : Colors.grey,
                    // Default color
                    child: Center(
                      child: Text(
                        '${AppUrl.filtredCommandsClient.projectSteps[index].name} (${projectList.length})',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
        SizedBox(height: 20.0),
        selectedItemIndex != -1
            ? Consumer<ProjectProvider>(
                builder: (context, projectProvider, snapshot) {
                if (projectProvider.projectList.length == 0)
                  return Expanded(
                    child: Center(
                        child: Text(
                      'Aucun projet !',
                      style: Theme.of(context).textTheme.headline3,
                    )),
                  );
                else {
                  List<Project> projectList = projectProvider.getProjectByStat(
                      selectedItemIndex +
                          AppUrl.filtredCommandsClient.projectSteps.first.id);
                  print(
                      'sizePro : ${projectList.length}  ${AppUrl.filtredCommandsClient.projectSteps.length}  ${AppUrl.filtredCommandsClient.projectSteps.first.id}  ${selectedItemIndex}');
                  return Expanded(
                    child: (projectList.isEmpty)
                        ? Center(
                            child: Text(
                            'Aucun projet !',
                            style: Theme.of(context).textTheme.headline3,
                          ))
                        : ListView.builder(
                            padding: EdgeInsets.all(12),
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) =>
                                ProjectItem(project: projectList[index]),
                            // separatorBuilder: (BuildContext context, int index) {
                            //   return Divider(
                            //     color: Colors.grey,
                            //   );
                            // },
                            itemCount: projectProvider.projectList.length),
                  );
                }
              })
            : Container(),
      ],
    );
  }
}

class ListProjectFragment extends StatefulWidget {
  const ListProjectFragment({
    super.key,
  });

  @override
  State<ListProjectFragment> createState() => _ListProjectFragmentState();
}

class _ListProjectFragmentState extends State<ListProjectFragment> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<ProjectProvider>(
            builder: (context, projectProvider, snapshot) {
          if (projectProvider.projectList.length == 0)
            return Expanded(
              child: Center(
                  child: Text(
                'Aucun projet !',
                style: Theme.of(context).textTheme.headline3,
              )),
            );
          else {
            return Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.all(12),
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) =>
                      ProjectItem(project: projectProvider.projectList[index]),
                  // separatorBuilder: (BuildContext context, int index) {
                  //   return Divider(
                  //     color: Colors.grey,
                  //   );
                  // },
                  itemCount: projectProvider.projectList.length),
            );
          }
        }),
      ],
    );
  }
}

class ProjectItem extends StatefulWidget {
  final Project project;

  const ProjectItem({super.key, required this.project});

  @override
  State<ProjectItem> createState() => _ProjectItemState();
}

class _ProjectItemState extends State<ProjectItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () {
          PageNavigator(ctx: context).nextPage(
              page: ProjectPage(
            project: widget.project,
          ));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: primaryColor,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.project.code!,
                          style: Theme.of(context).textTheme.headline4!),
                      (widget.project.object != null)
                          ? Text(
                              widget.project.object!,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor),
                            )
                          : Text('Nom de l\'Affaire',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(color: Colors.black)),
                      Container(
                        width: 200,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Statut: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith()),
                            Text(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                '(${widget.project.status})',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(color: Colors.red)),
                          ],
                        ),
                      ),
                      Text('Tier: ${widget.project.client!.name}',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(color: Colors.grey)),
                      Text('Catégorie: ${widget.project.res['type']['lib']}',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(color: Colors.blue)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.date_range, color: primaryColor),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                              'Date début : ${DateFormat('dd-MM-yyyy').format(widget.project.startDate!)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith()),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.date_range,
                            color: primaryColor,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                              'Date fin : ${DateFormat('dd-MM-yyyy').format(widget.project.endDate!)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith()),
                        ],
                      ),
                      (widget.project.delivryDate != null)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fire_truck_outlined,
                                  color: primaryColor,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                    'Date livraison : ${DateFormat('yyyy-MM-dd').format(widget.project.delivryDate!)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith())
                              ],
                            )
                          : Container(),
                    ],
                  ),
                  Visibility(
                    visible: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                            onPressed: () {
                              if (widget.project.client!.phone != null)
                                PhoneUtils().makePhoneCall(
                                    widget.project.client!.phone!);
                              else
                                showAlertDialog(context,
                                    'Aucun numéro de téléphone pour ce client');
                            },
                            icon: Icon(
                              Icons.call,
                              color: primaryColor,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey,
            )
          ],
        ),
      );
    });
  }
}

showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Container(
        width: 200,
        height: 100,
        child: Image.asset('assets/CRM-Loader.gif')),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
