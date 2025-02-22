import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
//import 'package:flutter_background_service/flutter_background_service.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:mobilino_app/config/theme.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/providers/activity_provider.dart';
import 'package:mobilino_app/providers/command_provider.dart';
import 'package:mobilino_app/providers/itinerary_provider.dart';
import 'package:mobilino_app/providers/note_provider.dart';
import 'package:mobilino_app/providers/payment_provider.dart';
import 'package:mobilino_app/providers/project_provider.dart';
import 'package:mobilino_app/providers/salon_provider.dart';
import 'package:mobilino_app/providers/ticket_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/app_router.dart';
import 'constants/http_request.dart';
import 'database/database_helper.dart';
import 'database/db_provider.dart';
import 'providers/notif_provider.dart';
import 'screens/authentication/login_page.dart';
import 'providers/providers.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import flutter_localizations
//import 'package:background_fetch/background_fetch.dart';

// void backgroundFetchHeadlessTask() async {
//   print('[BackgroundFetch] Headless event received.');
//   HttpRequestApp().sendItinerary('CPT');
//   // Timer.periodic(Duration(seconds: 10), (timer) {
//   //   showToast('This is a toast message');
//   //   //print('Hello, world!');
//   //   //HttpRequestApp().sendItinerary('CPT');
//   // });
//   //BackgroundFetch.finish('');
// }
//
// void initBackgroundFetch() async {
//   print('ghhhhg');
//   BackgroundFetch.configure(
//     BackgroundFetchConfig(
//       minimumFetchInterval: 15,
//       stopOnTerminate: false,
//       enableHeadless: true,
//       requiresBatteryNotLow: false,
//       requiresCharging: false,
//       requiresStorageNotLow: false,
//       requiresDeviceIdle: false,
//       requiredNetworkType: NetworkType.NONE,
//       startOnBoot: true,
//       forceAlarmManager: true,
//     ),
//     backgroundFetchHeadlessTask,
//   );
//   BackgroundFetch.start();
// }
//
// void showToast(String message) {
//   print(message);
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  // initBackgroundFetch();

  //initialization(null);
  //FlutterNativeSplash.remove();
  // WidgetsFlutterBinding.ensureInitialized();
  // await Future.delayed(const Duration(seconds: 3));
  // FlutterNativeSplash.remove();

  Timer.periodic(Duration(minutes: AppUrl.syncroTime), (timer) {
    //print('Hello, world!');
    HttpRequestApp().sendItinerary('CPT');
  });

  runApp(const MyApp());
}
//
// final FlutterLocalNotificationsPlugin flutterLocalPlugin =
//     FlutterLocalNotificationsPlugin();
// const AndroidNotificationChannel notificationChannel =
//     AndroidNotificationChannel(
//         "coding is life foreground", "coding is life foreground service",
//         description: "This is channel des....", importance: Importance.high);
//
// Future<void> initservice() async {
//   var service = FlutterBackgroundService();
//   //set for ios
//   if (Platform.isIOS) {
//     await flutterLocalPlugin.initialize(
//         const InitializationSettings(iOS: DarwinInitializationSettings()));
//   }
//
//   await flutterLocalPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(notificationChannel);
//
//   //service init and start
//   await service.configure(
//       iosConfiguration:
//           IosConfiguration(onBackground: iosBackground, onForeground: onStart),
//       androidConfiguration: AndroidConfiguration(
//           onStart: onStart,
//           autoStart: true,
//           isForegroundMode: true,
//           notificationChannelId: "coding is life",
//           initialNotificationTitle: "Coding is life",
//           initialNotificationContent: "Awsome Content",
//           foregroundServiceNotificationId: 90));
//   service.startService();
//
//   //for ios enable background fetch from add capability inside background mode
// }
//
// //onstart method
// @pragma("vm:enry-point")
// void onStart(ServiceInstance service) {
//   DartPluginRegistrant.ensureInitialized();
//
//   service.on("setAsForeground").listen((event) {
//     print("foreground ===============");
//   });
//
//   service.on("setAsBackground").listen((event) {
//     print("background ===============");
//   });
//
//   service.on("stopService").listen((event) {
//     service.stopSelf();
//   });
//
//   //display notification as service
//   Timer.periodic(Duration(seconds: 2), (timer) {
//     flutterLocalPlugin.show(
//         90,
//         "Cool Service",
//         "Awsome ${DateTime.now()}",
//         NotificationDetails(
//             android: AndroidNotificationDetails(
//                 "coding is life", "coding is life service",
//                 ongoing: true, icon: "app_icon")));
//   });
//   print("Background service ${DateTime.now()}");
// }
//
// //iosbackground
// @pragma("vm:enry-point")
// Future<bool> iosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();
//
//   return true;
// }

Future initialization(BuildContext? context) async {
  await Future.delayed(Duration(seconds: 3));
}

// void requestLocationPermission() async {
//   final permissionStatus = await Permission.location.request();
//   if (permissionStatus.isGranted) {
//     // Permission granted, you can now access the location
//   } else if (permissionStatus.isDenied) {
//     // Permission denied, handle accordingly
//   } else if (permissionStatus.isPermanentlyDenied) {
//     // Permission permanently denied, show a dialog to guide the user to settings
//     openAppSettings();
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //requestLocationPermission();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClientsMapProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => DepotProvider()),
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
        ChangeNotifierProvider(create: (_) => DepotProvider()),
        ChangeNotifierProvider(create: (_) => CommandProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => ItineraryProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => SalonProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => NotifProvider()),
      ],
      child: MaterialApp(
        title: 'CRM_MOBILINO',
        locale: Locale('fr'),
        supportedLocales: [
          const Locale('en', 'US'), // English
          const Locale('fr', 'FR'), // French
          // Add more locales as needed
        ],
        localizationsDelegates: [
          // Add other localization delegates as needed
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],// Set the locale to French
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.onGenerateRoute,
        theme: customTheme,
        initialRoute: LoginPage.routeName,
        home: LoginPage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
