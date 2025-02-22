import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('TextFormField Example'),
        ),
        body: Column(
          children: [
            TextFormWidget(
              // Pass the callback function to TextFormWidget
              onTextChanged: (newText) {
                // Reload the other widget here
                otherWidgetKey.currentState?.reload(newText);
              },
            ),
            OtherWidget(key: otherWidgetKey),
          ],
        ),
      ),
    );
  }

  final GlobalKey<OtherWidgetState> otherWidgetKey = GlobalKey<OtherWidgetState>();
}

class TextFormWidget extends StatefulWidget {
  final Function(String) onTextChanged;

  TextFormWidget({required this.onTextChanged});

  @override
  _TextFormWidgetState createState() => _TextFormWidgetState();
}

class _TextFormWidgetState extends State<TextFormWidget> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _textController,
          onChanged: (text) {
            // Call the callback when text changes
            widget.onTextChanged(text);
          },
        ),
      ],
    );
  }
}

class OtherWidget extends StatefulWidget {
  OtherWidget({Key? key}) : super(key: key);

  @override
  OtherWidgetState createState() => OtherWidgetState();
}

class OtherWidgetState extends State<OtherWidget> {
  String? _text = '';

  // Reload the widget with new text
  void reload(String newText) {
    setState(() {
      _text = newText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Text from TextFormWidget: $_text',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
