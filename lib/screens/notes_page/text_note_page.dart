import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/file_note.dart';
import 'package:mobilino_app/models/note.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/providers/note_provider.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

import 'camera_page.dart';

class TextNotePage extends StatefulWidget {
  final Note note;
  final bool visible;
  final Client? client;

  const TextNotePage(
      {super.key, required this.note, required this.visible, this.client});

  @override
  State<TextNotePage> createState() => _TextNotePageState();
}

class _TextNotePageState extends State<TextNotePage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _email = TextEditingController();
  late Team selectedTeam = AppUrl.filtredCommandsClient.team!;
  final TextEditingController _collaborators = TextEditingController();
  late Collaborator selectedCollaborator =
      AppUrl.filtredCommandsClient.collaborateur!;
  // late Client selectedClient = AppUrl.filtredCommandsClient.clients
  //     .where((element) => element.id == widget.note.client!.id)
  //     .first;
  late Client selectedClient = widget.note.client!;

  @override
  void initState() {
    super.initState();
    if (widget.note.text != null) _email.text = widget.note.text!;
    _collaborators.text =
        '${AppUrl.filtredCommandsClient.collaborateur!.userName}';
    if (widget.note.title != null) _title.text = widget.note.title!;

  }

  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.note.files.isNotEmpty)  print('zzz:: ${AppUrl.baseUrl}${widget.note.files[0].path}');

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
                      controller: _title,
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
                      'Collaborateurs',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              // PageNavigator(ctx: context)
                              //     .nextPage(page: CollaboratorsPage())
                              //     .then((value) {
                              //   _collaborators.text = '';
                              //   for (Collaborator collaborator
                              //   in AppUrl.user.selectedCollaborator)
                              //     _collaborators.text = _collaborators.text +
                              //         collaborator.userName! +
                              //         ' | ';
                              //   _collaborators.text
                              //       .substring(
                              //       0, _collaborators.text.length - 2);
                              // });
                            },
                            icon: Icon(
                              Icons.person_outline,
                              color: primaryColor,
                            ),
                          ),
                          // Your icon
                          SizedBox(width: 16.0),
                          // Adjust the space between icon and text field
                          Expanded(
                            child: customTextField(
                              obscure: false,
                              enable: false,
                              controller: _collaborators,
                            ),
                          ),
                        ],
                      ),
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
                        '',
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
                      items: [widget.note.client!]
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
                  Visibility(
                    visible: false,
                    child: Container(
                      width: 200,
                      child: ElevatedButton(
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
                            note: widget.note,
                            callback: reload,
                          ));
                          //PageNavigator(ctx: context).nextPage(page: CameraScreen());
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PRISE DE PHOTO',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(color: Colors.white),
                            ),
                            Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 210,
                    child:  ListView.builder(
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
                      if (AppUrl.user.selectedCollaborator.length == 0) {
                        showAlertDialog(context,
                            'Il faut choisir les collaborateurs d\'abord');
                        return;
                      }
                      if (formKey.currentState != null &&
                          formKey.currentState!.validate()) {
                        final provider =
                            Provider.of<NoteProvider>(context, listen: false);
                        widget.note.text = _email.text.trim();
                        widget.note.title = _title.text.trim();
                        showLoaderDialog(context);
                        //provider.noteList.add(widget.note);
                        sendNote(context, widget.note).then((value) {
                          if (value) {
                            showMessage(
                                message: 'Note créé avec succès',
                                context: context,
                                color: primaryColor);
                          } else {
                            showMessage(
                                message: 'Échec de creation de la note',
                                context: context,
                                color: Colors.red);
                          }
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        });
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
      "usersNotes": users
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
      return true;
    } else {
      return false;
    }
  }
}


class ItemFileNote extends StatefulWidget {
  const ItemFileNote({
    super.key,
    required this.fileNote,
  });

  final FileNote fileNote;

  @override
  State<ItemFileNote> createState() => _ItemFileNoteState();
}

class _ItemFileNoteState extends State<ItemFileNote> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    print('typeee: ${widget.fileNote.type}');
    if (widget.fileNote.type == 'vid') {
      Uri uri = Uri.parse('${AppUrl.baseUrl}${widget.fileNote.path}');
      print('zzzeee:: ${AppUrl.baseUrl}${widget.fileNote.path}');
      // Uri uri = Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4');
      // print('zzzeee:: https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4');
      _controller = VideoPlayerController.networkUrl(uri);
      _initializeVideoPlayerFuture = _controller.initialize();
      _controller.setLooping(true); // Loop the video
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fileNote.type == 'img') {
      return Container(
        margin: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 250,
              height: 150,
              child: (widget.fileNote.path == '' || widget.fileNote.path == null)
                  ? Image.asset(
                'assets/noimage.jpg',
                fit: BoxFit.cover,
              )
                  : Image.network(
                '${AppUrl.baseUrl}${widget.fileNote.path}',
                fit: BoxFit.cover,
                width: 200,
                height: 150,
              ),
            ),
            SizedBox(width: 5),
          ],
        ),
      );
    }
    else if (widget.fileNote.type == 'vid') {
      return Container(
        margin: EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  _buildControls(),
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      );
    } else {
      return Container(); // Return an empty container for other file types
    }
  }

  Widget _buildControls() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.all(8),
          color: Colors.black.withOpacity(0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: _togglePlayPause,
              ),
              VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: Colors.white,
                  bufferedColor: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _togglePlayPause() {
    if (_isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }
  @override
  void dispose() {
    super.dispose();
    _controller
        .dispose(); // Dispose the video controller when the widget is disposed
  }
}

Future<void> uploadFile(String id) async {
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
  var file =
      File('AppUrl.imageUrl'); // Replace with the actual path to your file
  file.exists().then((value) async {
    print('the file is exists ? $value');
    if (value) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      // Send the request
      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          print('File uploaded successfully');
        } else {
          print('Failed to upload file. Status code: ${response.statusCode}');
        }
      } catch (error) {
        print('Error uploading file: $error');
      }
    }
  });
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
