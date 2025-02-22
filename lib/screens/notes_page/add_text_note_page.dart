import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/contact.dart';
import 'package:mobilino_app/models/file_note.dart';
import 'package:mobilino_app/models/note.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/providers/note_provider.dart';
import 'package:mobilino_app/screens/home_page/clients_list_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/alert.dart';
import 'package:mobilino_app/widgets/collaborator_page.dart';
import 'package:mobilino_app/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

import 'camera_page.dart';
import 'video_page.dart';

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
  final TextEditingController _client = TextEditingController();
  late Stream<List<int>> _audioStream;
  late StreamSubscription<List<int>>? _audioStreamSubscription;
  bool isRecording = false;


  Stream<List<int>> convertUint8ListToStreamListInt(Stream<Uint8List>? stream) {
    if (stream == null) {
      return Stream.empty();
    }
    return stream.transform(StreamTransformer.fromHandlers(
      handleData: (Uint8List data, EventSink<List<int>> sink) {
        sink.add(data.toList());
      },
      handleError: (dynamic error, StackTrace stackTrace, EventSink<List<int>> sink) {
        // Handle error if needed
      },
      handleDone: (EventSink<List<int>> sink) {
        sink.close();
      },
    ));
  }

  @override
  void initState() {
    super.initState();
    if (widget.note.text != null) _email.text = widget.note.text!;
    _collaborators.text = 'Ajouter des Collaborators';
    //AppUrl.imageUrl = '';
    widget.note.files = [];
    _client.text = 'Ajouter un Tiers';
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   initVocal();
    // });
  }

  Future<void> initVocal() async{
    try{
      if(_audioStreamSubscription == null){
        isRecording = false;
      }else{
        isRecording = true;
      }
    }catch(_){
      isRecording = false;
    }
    try{
    MicStream.microphone(sampleRate: 44100, audioSource: AudioSource.DEFAULT).then((value){
      _audioStream = convertUint8ListToStreamListInt(value);
    });
    }catch (_) {
      showAlertDialog(context, 'Problème de enregistrement d\'un voacal !');
    }
  }

  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      //future: initVocal(),
        future: null,
      builder: (context, snapshot) {

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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 17),
                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                PageNavigator(ctx: context)
                                    .nextPage(
                                        page: ClientsListForAddClientPage(
                                  callback: reload,
                                ))
                                    .then((value) async {
                                  print('finish add ${AppUrl.selectedClient}');
                                  if (AppUrl.selectedClient == null) return;
                                  if (AppUrl.selectedClient!.id == null) return;
                                  widget.client!.name = AppUrl.selectedClient!.name;
                                  widget.client!.id = AppUrl.selectedClient!.id;
                                  _client.text = widget.client!.name!;
                                  // get contacts
                                  final Map<String, String> headers = {
                                    "Accept": "application/json",
                                    "content-type":
                                        "application/json; charset=UTF-8",
                                    "Referer": "http://" +
                                        AppUrl.user.company! +
                                        ".localhost:4200/",
                                    'Authorization': 'Bearer ${AppUrl.user.token}',
                                  };
                                  String url =
                                      AppUrl.getContacts + widget.client!.id!;
                                  print('url of getContacts $url');
                                  http.Response req = await http.get(Uri.parse(url),
                                      headers: headers);
                                  print("res contacts code : ${req.statusCode}");
                                  print("res contacts body: ${req.body}");
                                  if (req.statusCode == 200 ||
                                      req.statusCode == 201) {
                                    widget.client!.contacts = [];
                                    List<dynamic> data = json.decode(req.body);
                                    data.forEach((element) {
                                      widget.client!.contacts.add(Contact(
                                        code: element['code'],
                                        num: element['numero'],
                                        origin: element['origin'],
                                        famillyName: element['nom'],
                                        firstName: element['prenom'],
                                      ));
                                    });
                                  }
                                  reload();
                                });
                              },
                              icon: Icon(
                                Icons.person_add_alt,
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
                                controller: _client,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ListTile(
                      //   title: Text(
                      //     'Collaborateurs',
                      //     style: Theme.of(context).textTheme.headline6,
                      //   ),
                      //   subtitle: Padding(
                      //     padding: const EdgeInsets.symmetric(horizontal: 0),
                      //     child: Row(
                      //       //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //       children: [
                      //         IconButton(
                      //           onPressed: () {
                      //             PageNavigator(ctx: context)
                      //                 .nextPage(page: CollaboratorsPage())
                      //                 .then((value) {
                      //               _collaborators.text = '';
                      //               for (Collaborator collaborator
                      //                   in AppUrl.user.selectedCollaborator)
                      //                 _collaborators.text = _collaborators.text +
                      //                     collaborator.userName! +
                      //                     ' | ';
                      //               _collaborators.text.substring(
                      //                   0, _collaborators.text.length - 2);
                      //             });
                      //           },
                      //           icon: Icon(
                      //             Icons.group_add_outlined,
                      //             color: primaryColor,
                      //           ),
                      //         ),
                      //         // Your icon
                      //         SizedBox(width: 16.0),
                      //         // Adjust the space between icon and text field
                      //         Expanded(
                      //           child: customTextField(
                      //             obscure: false,
                      //             enable: false,
                      //             controller: _collaborators,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // ListTile(
                      //   title: Text(
                      //     'Tiers : ',
                      //     style: Theme.of(context).textTheme.headline6,
                      //   ),
                      //   subtitle: DropdownButtonFormField<Client>(
                      //     decoration: InputDecoration(
                      //         fillColor: Colors.white,
                      //         filled: true,
                      //         focusedBorder: OutlineInputBorder(
                      //           borderRadius: BorderRadius.circular(12),
                      //           borderSide:
                      //               BorderSide(width: 2, color: primaryColor),
                      //         ),
                      //         enabledBorder: OutlineInputBorder(
                      //           borderRadius: BorderRadius.circular(12),
                      //           borderSide:
                      //               BorderSide(width: 2, color: primaryColor),
                      //         )),
                      //     hint: Text(
                      //       'Selectioner l\'équipe',
                      //       style: Theme.of(context)
                      //           .textTheme
                      //           .headline4!
                      //           .copyWith(color: Colors.grey),
                      //     ),
                      //     value: selectedClient,
                      //     onChanged: (newValue) {
                      //       setState(() {
                      //         selectedClient = newValue!;
                      //       });
                      //     },
                      //     items: AppUrl.filtredCommandsClient.clients
                      //         .where((element) => element.id != '-1')
                      //         .toList()
                      //         .map<DropdownMenuItem<Client>>((Client value) {
                      //       return DropdownMenuItem<Client>(
                      //         value: value,
                      //         child: Text(
                      //           value.name!,
                      //           style: Theme.of(context).textTheme.headline4,
                      //         ),
                      //       );
                      //     }).toList(),
                      //   ),
                      // ),
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
                          // ElevatedButton(
                          //   style: ElevatedButton.styleFrom(
                          //       primary: Theme.of(context).primaryColor,
                          //       elevation: 0,
                          //       shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(5))),
                          //   onPressed: () {
                          //     if (isRecording != false) {
                          //       // Stop recording
                          //       _audioStreamSubscription!.cancel();
                          //       widget.note.files.add(FileNote(type: 'audio', path: '', ));
                          //       setState(() {
                          //         _audioStreamSubscription = null;
                          //         isRecording = false;
                          //
                          //       });
                          //     } else {
                          //       // Start recording
                          //       _audioStreamSubscription = _audioStream.listen((audioData) {
                          //         // Process audio data here
                          //         print('Received audio data: $audioData');
                          //         isRecording = true;
                          //       });
                          //       setState(() {});
                          //     }
                          //   },
                          //   child: (isRecording == false)
                          //       ? Icon(Icons.play_arrow)
                          //       : Icon(Icons.stop),
                          // ),
                        ],
                      ),
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
    );
  }

  @override
  void dispose() {
    _audioStreamSubscription?.cancel();
    super.dispose();
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
      "pcfCode": "${widget.client!.id}",
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
      var res = json.decode(req.body);
      bool addNote = false;
      if(note.files.length == 0) return true;
      for (int i = 0; i < note.files.length; i++)
        await uploadFile(res['id'].toString(), note.files[i]).then((value) {
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
  late Stream<List<int>> _audioStream;
  late StreamSubscription<List<int>> _audioStreamSubscription;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    if (widget.fileNote.type == 'vid') {
      _controller = VideoPlayerController.file(File('${widget.fileNote.path}'));
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
                  : Image.file(
                      File(widget.fileNote.path),
                      fit: BoxFit.cover,
                      width: 200,
                      height: 150,
                    ),
            ),
            SizedBox(height: 5),
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
      return Container(
      ); // Return an empty container for other file types
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

// class _ItemFileNoteState extends State<ItemFileNote> {
//   late VideoPlayerController _controller;
//   late Future<void> _initializeVideoPlayerFuture;
//   // @override
//   // Future<void> initState() {
//   //   // TODO: implement initState
//   //   super.initState();
//   //   if(widget.fileNote.type == 'vid'){
//   //     _controller = VideoPlayerController.file(File('${widget.fileNote.path}'));
//   //     _initializeVideoPlayerFuture = _controller.initialize();
//   //     _controller.setLooping(true); // Loop the video
//   //   }
//   // }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     if(widget.fileNote.type == 'vid'){
//       _controller = VideoPlayerController.file(File('${widget.fileNote.path}'));
//       _initializeVideoPlayerFuture = _controller.initialize();
//       _controller.setLooping(true); // Loop the video
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if(widget.fileNote.type == 'img')
//     return Column(
//       children: [
//         Container(
//           width: 250,
//           height: 150,
//           child: (widget.fileNote.path == '' ||
//               widget.fileNote.path == null)
//               ? Image.asset(
//                   'assets/noimage.jpg',
//                   fit: BoxFit
//                       .cover, // Adjust the image fit property as needed
//                 )
//               : Image.file(
//                   File(widget.fileNote.path),
//                   fit: BoxFit.cover,
//                   width: 200,
//                   height: 150,
//                 ),
//         ),
//         SizedBox(
//           height: 5,
//         )
//       ],
//     );
//     else if(widget.fileNote.type == 'vid'){
//       return FutureBuilder(
//         future: _initializeVideoPlayerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             // If the VideoPlayerController has finished initialization, use it to display the video
//             return AspectRatio(
//               aspectRatio: _controller.value.aspectRatio,
//               child: VideoPlayer(_controller),
//             );
//           } else {
//             // If the VideoPlayerController is still initializing, display a loading spinner
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       );
//     }
//     else return Container();
//       // return _controller.value.isInitialized
//       //     ? AspectRatio(
//       //   aspectRatio: _controller.value.aspectRatio,
//       //   child: VideoPlayer(_controller),
//       // )
//       //     : CircularProgressIndicator();
//   }
// }

Future<bool> uploadFile(String id, FileNote fileNote) async {
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
  var file = File(fileNote.path); // Replace with the actual path to your file
  await file.exists().then((value) async {
    print('the file is exists ? $value');
    if (value) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      print('fdfdfdf! ${fileNote.type}');
      request.fields['type'] = '${fileNote.type}';
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
