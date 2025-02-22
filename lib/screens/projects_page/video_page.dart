import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mobilino_app/models/file_note.dart';
import 'package:mobilino_app/models/note.dart';



class VideoPage extends StatefulWidget {
  const VideoPage({
    super.key,
    required this.camera,
    required this.callback,
    required this.note
  });

  final VoidCallback callback;
  final CameraDescription camera;
  final Note note;
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      //cameras[0], // Use the first available camera
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enregistrer une vidéo'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(_isRecording ? Icons.stop : Icons.videocam),
        onPressed: () async {
          if (!_isRecording) {
            await startRecording();
          } else {
            await stopRecording();
          }
        },
      ),
    );
  }

  Future<void> startRecording() async {
    try {
      await _initializeControllerFuture;
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = '$timestamp.mp4';
      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      _controller.stopVideoRecording().then((value){
        print('path of video ${value.path}');
        widget.note.files.add(FileNote(type: 'vid', path: value.path));
        widget.callback();
        Navigator.pop(context);
      });
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
