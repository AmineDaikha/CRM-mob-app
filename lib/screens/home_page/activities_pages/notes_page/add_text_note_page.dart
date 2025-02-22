import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/note.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/providers/note_provider.dart';
import 'package:mobilino_app/screens/notes_page/add_text_note_page.dart';
import 'package:mobilino_app/screens/notes_page/video_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/collaborator_page.dart';
import 'package:mobilino_app/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'dart:io';

import 'camera_page.dart';

class AddTextNotePage extends StatefulWidget {
  final Note note;
  final bool visible;
  final Client? client;

  const AddTextNotePage(
      {super.key, required this.note, required this.visible, this.client});

  @override
  State<AddTextNotePage> createState() => _AddTextNotePageState();
}

class _AddTextNotePageState extends State<AddTextNotePage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _email = TextEditingController();
  late Team selectedTeam = AppUrl.filtredCommandsClient.team!;
  final TextEditingController _collaborators = TextEditingController();
  late Collaborator selectedCollaborator =
      AppUrl.filtredCommandsClient.collaborateur!;
  late Client selectedClient = widget.client!;


  @override
  void initState() {
    super.initState();
    if (widget.note.text != null) _email.text = widget.note.text!;
    _collaborators.text = 'Ajouter des Collaborators';
  }

  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set icon color to white
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Note textuelle',
          style: Theme.of(context)
              .textTheme
              .headline3!
              .copyWith(color: Colors.white),
        ),
      ),
      body: Form(
        key: formKey,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: txtInputDecoration.copyWith(
                          labelText: 'titre', hintText: 'titre'),
                      controller: _numberController,
                      //            keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Svp, entrer le titre';
                        }
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Tiers : ',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: DropdownButtonFormField<Client>(
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(width: 2, color: primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(width: 2, color: primaryColor),
                          )),
                      hint: Text(
                        'Selectioner l\'équipe',
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(color: Colors.grey),
                      ),
                      value: selectedClient,
                      onChanged: (newValue) {
                        setState(() {
                          selectedClient = newValue!;
                        });
                      },
                      items: [selectedClient].toList()
                          .map<DropdownMenuItem<Client>>((Client value) {
                        return DropdownMenuItem<Client>(
                          value: value,
                          child: Text(
                            value.name!,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: customTextField(
                      obscure: false,
                      controller: _email,
                      maxLines: null,
                      hint: 'Écrivez la note',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        onPressed: () async {
                          // Ensure that plugin services are initialized so that `availableCameras()`
                          // can be called before `runApp()`
                          WidgetsFlutterBinding.ensureInitialized();

                          // Obtain a list of the available cameras on the device.
                          final cameras = await availableCameras();

                          // Get a specific camera from the list of available cameras.
                          final firstCamera = cameras.first;
                          PageNavigator(ctx: context).nextPage(
                              page: TakePictureScreen(
                                camera: firstCamera,
                                callback: reload,
                                note: widget.note,
                              ));
                          // PageNavigator(ctx: context).nextPage(
                          //     page: VideoPage(
                          //       camera: firstCamera,
                          //       callback: reload,
                          //       note: widget.note,
                          //     ));
                          //PageNavigator(ctx: context).nextPage(page: CameraScreen());
                        },
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        onPressed: () async {
                          print('length: ${widget.note.files.length}');
                          // Ensure that plugin services are initialized so that `availableCameras()`
                          // can be called before `runApp()`
                          WidgetsFlutterBinding.ensureInitialized();

                          // Obtain a list of the available cameras on the device.
                          final cameras = await availableCameras();

                          // Get a specific camera from the list of available cameras.
                          final firstCamera = cameras.first;
                          PageNavigator(ctx: context).nextPage(
                              page: VideoPage(
                                camera: firstCamera,
                                callback: reload,
                                note: widget.note,
                              ));
                        },
                        child: Icon(
                          Icons.video_call_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // Container(
                  //   height: 180,
                  //   child: ListView.builder(
                  //     itemCount: widget.note.files.length,
                  //     itemBuilder: (BuildContext context, int index) {
                  //       return Column(
                  //         children: [
                  //           Container(
                  //             width: 250,
                  //             height: 150,
                  //             child: (widget.note.files[index] == '' ||
                  //                 widget.note.files[index] == null)
                  //                 ? Image.asset(
                  //               'assets/noimage.jpg',
                  //               fit: BoxFit
                  //                   .cover, // Adjust the image fit property as needed
                  //             )
                  //                 : Image.file(
                  //               File(widget.note.files[index].path),
                  //               fit: BoxFit.cover,
                  //               width: 200,
                  //               height: 150,
                  //             ),
                  //           ),
                  //           SizedBox(height: 5,)
                  //         ],
                  //       );
                  //     },
                  //   ),
                  // ),
                  Container(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.note.files.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            child: ItemFileNote(fileNote: widget.note.files[index]));
                      },
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                child: Visibility(
                  visible: widget.visible,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    onPressed: () {
                      if (formKey.currentState != null &&
                          formKey.currentState!.validate()) {
                        final provider =
                            Provider.of<NoteProvider>(context, listen: false);
                        widget.note.text = _email.text.trim();
                        widget.note.title = _numberController.text.trim();
                        widget.note.client = widget.client;
                        //showLoaderDialog(context);
                        provider.noteList.add(widget.note);
                        Navigator.of(context).pop();
                        // sendNote(context, widget.note).then((value) {
                        //   if (value) {
                        //     showMessage(
                        //         message: 'Note créé avec succès',
                        //         context: context,
                        //         color: primaryColor);
                        //   } else {
                        //     showMessage(
                        //         message: 'Échec de creation de la note',
                        //         context: context,
                        //         color: Colors.red);
                        //   }
                        //   Navigator.of(context).pop();
                        //   Navigator.of(context).pop();
                        // });
                      }
                    },
                    child: const Text(
                      "Ajouter",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool> sendNote(BuildContext context, Note note) async {
    List<Map<String, dynamic>> users = [];
    for (Collaborator collaborator in AppUrl.user.selectedCollaborator) {
      if (collaborator.userName == '${AppUrl.user.userId}')
        collaborator.userName = AppUrl.user.userId;
      Map<String, dynamic> jsonUser = {
        "salCode": "${collaborator.salCode}",
        "visible": true,
        // "ID": "${collaborator.userName}",
        // "UserName": "${collaborator.userName}",
      };
      users.add(jsonUser);
    }
    // Map<String, dynamic> jsonUser = {
    //   "salCode": "${selectedCollaborator.salCode}",
    //   "visible": true
    // };
    // List<Map<String, dynamic>> users = [];
    // users.add(jsonUser);
    Map<String, dynamic> jsonObject = {
      "nom": note.title,
      "type": "txt",
      "path": "string",
      "pcfCode": "${selectedClient.id}",
      "description": note.text,
      "dateCreation": DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
      "userCreate": AppUrl.user.userId,
      "usersNotes": users,
      "opportuniteId" : '${widget.client!.idOpp}',
    };

    print('jsonNote: ${jsonObject}');
    http.Response req = await http.post(Uri.parse(AppUrl.NotesOpp),
        body: jsonEncode(jsonObject),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
    print("res note code : ${req.statusCode}");
    print("res note body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      var res = json.decode(req.body);
      bool addNote = false;
      for(int i = 0; i< note.files.length; i++)
      await uploadFile(res['id'].toString(), note.files[i].path).then((value) {
        if (value)
          addNote = true;
        else
          addNote = false;
      });
      return addNote;
    } else {
      return false;
    }
  }
  Future<bool> uploadFile(String id, String path) async {
    // Replace with your API endpoint
    final String apiUrl = '${AppUrl.uploadFileNote}$id';

    // Create a new http.MultipartRequest
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(apiUrl),
    );
    request.headers['Accept'] = 'application/json';
    request.headers['content-type'] = 'application/json; charset=UTF-8';
    request.headers['Referer'] =
        "http://" + AppUrl.user.company! + ".localhost:4200/";
    // Add your file to the request
    var file = File(path); // Replace with the actual path to your file
    await file.exists().then((value) async {
      print('the file is exists ? $value');
      if (value) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
        // Send the request
        try {
          var response = await request.send();
          if (response.statusCode == 200) {
            print('File uploaded successfully');
            return true;
          } else {
            print('Failed to upload file. Status code: ${response.statusCode}');
            return false;
          }
        } catch (error) {
          print('Error uploading file: $error');
        }
      }
    });
    return true;
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
