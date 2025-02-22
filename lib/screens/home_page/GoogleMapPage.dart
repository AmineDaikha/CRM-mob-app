import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
class GoogleMapPage extends StatefulWidget {

  final String url;
  GoogleMapPage({super.key, required this.url});


  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set icon color to white
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Itinéraire avec Google Map',
          style: Theme.of(context)
              .textTheme
              .headline4!
              .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: WebView(
        //initialUrl: 'https://www.google.com/maps/dir/?api=1&origin=36.7675962,3.7029002&destination=36.7343859,4.3667907&waypoints=36.752887,3.042048|36.7675962,3.7029002',
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
