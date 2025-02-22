import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/database/db_provider.dart';
import 'package:mobilino_app/models/user.dart';
import 'package:mobilino_app/providers/auth_provider.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/widgets/button.dart';
import 'package:mobilino_app/widgets/text_field.dart';
import 'package:provider/provider.dart';

class ParameterPage extends StatefulWidget {
  const ParameterPage({super.key});

  static const String routeName = '/';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => ParameterPage(),
    );
  }

  @override
  State<ParameterPage> createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _company = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // _email.clear();
    // _password.clear();
    // _company.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          )
        : Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                    backgroundColor: primaryColor,
                    title: Text(
                      'Paramèters',
                      style: Theme.of(context)
                          .textTheme
                          .headline3!
                          .copyWith(color: Colors.white),
                    )),
                backgroundColor: Colors.white,
                bottomNavigationBar: Container(
                    // decoration: BoxDecoration(
                    //   image: DecorationImage(
                    //     image: AssetImage("assets/authentification.jpg"),
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                    height: 100,
                    margin: EdgeInsets.only(bottom: 5),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'DSSI',
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(color: Theme.of(context).primaryColor),
                      ),
                    )),
                body: Form(
                  key: formKey,
                  child: Container(
                    // width: double.infinity,
                    // height: double.infinity,
                    // decoration: BoxDecoration(
                    //   image: DecorationImage(
                    //     image: AssetImage("assets/authentification.jpg"),
                    //     fit: BoxFit.fill,
                    //   ),
                    // ),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 80),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      'Configuration de la connexion de votre',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      'aaplication au serveur de données.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 2,
                                  width: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  child: Column(
                                    children: [
                                      customTextFieldParameter(
                                          obscure: false,
                                          controller: _email,
                                          hint: 'Addresse de serveur',
                                          icon: Icon(
                                            Icons.person_outline,
                                            color:
                                                Theme.of(context).primaryColor,
                                          )),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      customTextFieldParameter(
                                          obscure: false,
                                          controller: _password,
                                          hint: 'Serveur IP',
                                          icon: Icon(
                                            Icons.lock_outline,
                                            color:
                                                Theme.of(context).primaryColor,
                                          )),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      customTextFieldParameter(
                                          obscure: false,
                                          controller: _company,
                                          hint: 'Société',
                                          icon: Icon(
                                            Icons.business_outlined,
                                            color:
                                                Theme.of(context).primaryColor,
                                          )),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      customTextFieldParameter(
                                          obscure: false,
                                          controller: _company,
                                          hint: 'Société',
                                          icon: Icon(
                                            Icons.business_outlined,
                                            color:
                                                Theme.of(context).primaryColor,
                                          )),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      customTextFieldParameter(
                                          obscure: false,
                                          controller: _company,
                                          hint: 'Société',
                                          icon: Icon(
                                            Icons.business_outlined,
                                            color:
                                                Theme.of(context).primaryColor,
                                          )),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                SizedBox(
                                    width: 200,
                                    height: 45,
                                    // todo 7
                                    child: Consumer<AuthProvider>(
                                        builder: (context, auth, child) {
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary:
                                                Theme.of(context).primaryColor,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30))),
                                        onPressed: () {
                                          if (formKey.currentState != null &&
                                              formKey.currentState!
                                                  .validate()) {
                                            setState(() {
                                              print('validation!');
                                              final user = User(
                                                  userId: _email.text.trim(),
                                                  password:
                                                      _password.text.trim(),
                                                  company:
                                                      _company.text.trim());
                                              showLoaderDialog(context);
                                            });
                                          }
                                        },
                                        child: const Text(
                                          "TEST DE CONNECTIVITÉ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      );
                                    })),

                                // customButton(
                                //     text: "Connexion", tap: () {}, context: context, status: false),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  void checkToken() {
    String token = '';
    final provider = DatabaseProvider();

    provider.getToken().then((String value) {
      token = value;
      print('token ${token}');
      if (token != '') {
        AppUrl.user.token = value;
        provider.getUserId().then((String value) {
          token = value;
          print('getUserId ${token}');
          if (token != '') {
            AppUrl.user.userId = value;
            provider.getRoleCRM().then((String value) {
              token = value;
              print('getRoleCRM ${token}');
              if (token != '') {
                AppUrl.user.roleCRM = value;
                provider.getRoleValue().then((String value) {
                  token = value;
                  print('getRoleValue ${token}');
                  if (token != '') {
                    AppUrl.user.role = value;
                    provider.getRoleId().then((String value) {
                      token = value;
                      print('getRoleId ${token}');
                      if (token != '') {
                        AppUrl.user.salCode = value;
                        provider.getImage().then((String value) {
                          token = value;
                          print('getImage ${token}');
                          if (token != '') {
                            AppUrl.user.image = value;
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/home', (route) => false);
                          }
                        });
                      }
                    });
                  }
                });
              }
            });
          }
        });
      }
    });
  }

  void checkUser() {
    isLoading = true;
    DatabaseProvider().getUser().then((value) {
      AppUrl.user = value;
      print('user token: ${value.token}');
      if (AppUrl.user.token != null) {
        showLoaderDialog(context);
        final provider = Provider.of<AuthProvider>(context, listen: false);
        provider.getMenuAcces(AppUrl.user).then((value) {
          Navigator.pop(context);
        });
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        LatLng(position.latitude, position.longitude);
        print('latLng: ${position.latitude} ${position.longitude}');
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }
}

showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: primaryColor,
        ),
        Container(margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void _showAlertDialog(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.yellow,
              size: 50.0,
            ),
          ],
        ),
        content: Text(
          '$text',
          style: Theme.of(context).textTheme.headline6!,
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(primaryColor)),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Ok',
                style: Theme.of(context)
                    .textTheme
                    .headline3!
                    .copyWith(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
