import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/file_note.dart';
import 'package:mobilino_app/models/note.dart';
import 'package:mobilino_app/providers/clients_map_provider.dart';
import 'package:mobilino_app/providers/note_provider.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/widgets/add_payment_dialog.dart';
import 'package:mobilino_app/widgets/drawers/my_notes_drawer.dart';
import 'package:mobilino_app/screens/notes_page/title_note_dialog.dart';
import 'package:provider/provider.dart';

import 'dialog_filtred_notes.dart';
import 'add_text_note_page.dart';
import 'text_note_page.dart';

class NoteListPage extends StatefulWidget {
  final Client client;

  const NoteListPage({super.key, required this.client});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
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

  Future<void> fetchData() async {
    //print('image: ${AppUrl.baseUrl}${AppUrl.user.image}');
    final provider = Provider.of<NoteProvider>(context, listen: false);
    provider.noteList.clear();
    String url = AppUrl.getAllNotes + '?opportuniteId=' + widget.client.idOpp!;
    print('url oppoNote: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res allNote code : ${req.statusCode}");
    print("res allNote body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      List<dynamic> data = json.decode(req.body);
      //data.forEach((element) {
      for (int i = 0; i < data.length; i++) {
        var element = data[i];
        url = AppUrl.getFileNote + element['id'].toString();
        print('url : $url');
        req = await http.get(Uri.parse(url), headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
        print("res allDocNote code : ${req.statusCode}");
        print("res allDocNote body: ${req.body}");
        List<FileNote> images = [];
        if (req.statusCode == 200) {
          List<dynamic> docs = json.decode(req.body);
          if (docs.length > 0) {
            for (int j = 0; j < docs.length; j++) {
              images.add(FileNote(type: docs[j]['type'], path:docs[j]['path']));
            }
          }
        }
        Note note = Note(
            type: element['type'],
            title: element['nom'],
            text: element['description'],
            client: widget.client,
            date: DateTime.parse(element['dateCreation']),
            collaboratorsTxt: element['userCreate']);
        note.files = images;
        provider.noteList.add(note);
        if (element['type'] == 'txt') {

        }

        //});}
      }
      provider.noteList.sort((a, b) => b.date!.compareTo(a.date!));
      print('sizeIS: ${provider.noteList.length}');
      provider.notifyListeners();
    }
  }

  // Future<void> _fetchData(BuildContext context) async {
  //   final provider = Provider.of<ClientsMapProvider>(context, listen: false);
  //   provider.filtredClients = [];
  //   String query = '';
  //   http.Response req = await http.get(
  //       Uri.parse(AppUrl.tiersPage + '?PageNumber=1&rs=$query&PageSize=20'),
  //       headers: {
  //         "Accept": "application/json",
  //         "content-type": "application/json; charset=UTF-8",
  //         "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
  //       });
  //   print("res tiers code : ${req.statusCode}");
  //   print("res tiers body: ${req.body}");
  //   if (req.statusCode == 200) {
  //     List<dynamic> data = json.decode(req.body);
  //     for (int i = 0; i < data.toList().length; i++) {
  //       var element = data.toList()[i];
  //       print('code client:  ${element['code']}');
  //       req = await http.get(
  //           Uri.parse(AppUrl.tiersEcheance +
  //               '${AppUrl.user.etblssmnt!.code}/${element['code']}'),
  //           headers: {
  //             "Accept": "application/json",
  //             "content-type": "application/json; charset=UTF-8",
  //             "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
  //           });
  //       print("res total code : ${req.statusCode}");
  //       print("res total body: ${req.body}");
  //       if (req.statusCode == 200) {
  //         double total = 0;
  //         List<dynamic> echeances = json.decode(req.body);
  //         echeances.toList().forEach((ech) {
  //           total = total + ech['echArecev'] - ech['echRecu'];
  //           print('ech: ${ech['echArecev']}');
  //         });
  //         LatLng latLng;
  //         if (element['longitude'] == null || element['latitude'] == null) {
  //           latLng = LatLng(1.354474457244855, 1.849465150689236);
  //         } else {
  //           try {
  //             latLng = LatLng(element['latitude'], element['longitude']);
  //           } catch (e) {
  //             print('latlong err: $e');
  //             latLng = LatLng(1.354474457244855, 1.849465150689236);
  //           }
  //         }
  //         String? familleId = element['familleId'];
  //         String? sFamilleId = element['sFamilleId'];
  //         print('TiersFams: ${element['familleId']} ${element['sFamilleId']}');
  //         if (familleId != null) {
  //           req = await http
  //               .get(Uri.parse(AppUrl.getFamilly + '$familleId'), headers: {
  //             "Accept": "application/json",
  //             "content-type": "application/json; charset=UTF-8",
  //             "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
  //           });
  //           print("res familleId code : ${req.statusCode}");
  //           print("res familleId body: ${req.body}");
  //           if (req.statusCode == 200) {
  //             print('ddd: ${json.decode(req.body)['lib']}');
  //             familleId = json.decode(req.body)['lib'];
  //           }
  //         }
  //
  //         if (sFamilleId != null) {
  //           req = await http
  //               .get(Uri.parse(AppUrl.getSFamilly + '$sFamilleId'), headers: {
  //             "Accept": "application/json",
  //             "content-type": "application/json; charset=UTF-8",
  //             "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
  //           });
  //           print("res sfamilleId code : ${req.statusCode}");
  //           print("res sfamilleId body: ${req.body}");
  //           if (req.statusCode == 200) {
  //             sFamilleId = json.decode(req.body)['lib'];
  //           }
  //         }
  //         print('TiersFams!!: $familleId $sFamilleId');
  //         AppUrl.filtredCommandsClient.clients.add(Client(
  //             name: element['rs'],
  //             totalPay: total,
  //             location: latLng,
  //             familleId: familleId,
  //             sFamilleId: sFamilleId,
  //             type: element['type'],
  //             name2: element['rs2'],
  //             phone: element['tel1'],
  //             phone2: element['tel2'],
  //             city: element['ville'],
  //             id: element['code']));
  //         //provider.notifyListeners();
  //       }
  //     }
  //   }
  //   provider.notifyListeners();
  // }

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
                  Text('Nous sommes désolé, la qualité de votre connexion ne vous permet pas de vous connecter à votre serveur.'
                      ' Veuillez réessayer ultérieurement. Merci'),
                ],
              ),
            );
          } else
            return Scaffold(
                //drawer: DrawerNotesPage(),
                appBar: AppBar(
                  iconTheme: IconThemeData(
                    color: Colors.white, // Set icon color to white
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Opportunité notes ',
                        style: Theme.of(context).textTheme.headline3!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Client : ${widget.client!.name}',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  backgroundColor: primaryColor,
                  actions: [

                  ],
                ),
                floatingActionButton:FloatingActionButton(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(50.0), // Set FAB shape to circle
                  ),
                  backgroundColor: primaryColor,
                  onPressed: () {
                    page
                        .nextPage(
                        page: AddTextNotePage(
                            visible: true,
                            client: widget.client,
                            note: Note(
                              type: Note.TEXT,
                            )))
                        .then((value) {
                      setState(() {});
                    });
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
                body:
                    Consumer<NoteProvider>(builder: (context, notes, snapshot) {
                  if (notes.noteList.length == 0)
                    return Center(
                        child: Text(
                      'Aucune note !',
                      style: Theme.of(context).textTheme.headline3,
                    ));
                  else
                    return ListView.builder(
                        padding: EdgeInsets.all(12),
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) =>
                            NoteItem(note: notes.noteList.toList()[index]),
                        // separatorBuilder: (BuildContext context, int index) {
                        //   return Divider(
                        //     color: Colors.grey,
                        //   );
                        // },
                        itemCount: notes.noteList.length);
                }));
        });
  }
}

class NoteItem extends StatefulWidget {
  const NoteItem({super.key, required this.note});

  final Note note;

  @override
  State<NoteItem> createState() => _NoteItemState();
}

class _NoteItemState extends State<NoteItem> {
  late Icon icon;

  @override
  void initState() {
    super.initState();
    print('sizeeee: ${widget.note.client!.id}');
    if (widget.note.type == 'vocal') {
      icon = Icon(
        Icons.mic_none_outlined,
        color: primaryColor,
      );
    } else if (widget.note.type == 'photo') {
      icon = Icon(
        Icons.image_outlined,
        color: primaryColor,
      );
    } else if (widget.note.type == 'video') {
      icon = Icon(
        Icons.video_camera_back_outlined,
        color: primaryColor,
      );
    } else if (widget.note.type == Note.TEXT) {
      icon = Icon(
        Icons.text_snippet_outlined,
        color: primaryColor,
      );
    }

    icon = Icon(
      Icons.text_snippet_outlined,
      color: primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('path: ${widget.note.files}');
    PageNavigator page = PageNavigator(ctx: context);
    return GestureDetector(
      onTap: () {
        page.nextPage(
            page: TextNotePage(
              note: widget.note,
              visible: false,
            ));
        if (widget.note.type == Note.TEXT) {
          // page.nextPage(
          //     page: TextNotePage(
          //   note: widget.note,
          //   visible: false,
          // ));
        }
      },
      child: Column(
        children: [
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.note.title!,
                    style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: 7,),
                Text('${widget.note.text}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.headline6),
                SizedBox(height: 7,),
                Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        color: primaryColor, size: 20),
                    SizedBox(
                      width: 7,
                    ),
                    Text(
                        '${DateFormat('dd-MM-yyyy').format(widget.note.date!)}',
                        style:
                        Theme.of(context).textTheme.bodyText1!.copyWith()),
                    SizedBox(
                      width: 20,
                    ),
                    Icon(Icons.access_time, color: primaryColor, size: 20),
                    SizedBox(
                      width: 7,
                    ),
                    Text('${DateFormat('HH:mm').format(widget.note.date!)}',
                        style:
                        Theme.of(context).textTheme.bodyText1!.copyWith()),
                  ],
                ),
                SizedBox(height: 7,),
                Row(
                  children: [
                    Icon(Icons.person_2_outlined,
                        color: primaryColor, size: 20),
                    SizedBox(
                      width: 7,
                    ),
                    Text('${widget.note.client!.name}',
                        style:
                        Theme.of(context).textTheme.bodyText1!.copyWith()),
                  ],
                )
              ],
            ),
            leading: icon,
          ),
          Divider(
            color: Colors.grey,
          )
        ],
      ),
    );
    // return Column(
    //   children: [
    //     Container(
    //       height: 70,
    //       child: Row(
    //         //mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           icon,
    //           Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text('${widget.note.type}'),
    //             ],
    //           ),
    //         ],
    //       ),
    //     ),
    //     Divider(
    //       color: Colors.grey,
    //     )
    //   ],
    // );
    ;
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
