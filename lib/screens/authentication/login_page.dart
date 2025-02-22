import 'dart:convert';
import 'dart:io';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/http_request.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/database/database_helper.dart';
import 'package:mobilino_app/database/db_provider.dart';
import 'package:mobilino_app/models/depot.dart';
import 'package:mobilino_app/models/etablissement.dart';
import 'package:mobilino_app/models/user.dart';
import 'package:mobilino_app/providers/auth_provider.dart';
import 'package:mobilino_app/screens/authentication/parameter_page.dart';
import 'package:mobilino_app/screens/clients_page/add_client_page1.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/widgets/button.dart';
import 'package:mobilino_app/widgets/text_field.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = '/';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => LoginPage(),
    );
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _company = TextEditingController();
  bool isLoading = false;

  List<User> options = [];

  @override
  void initState() {
    super.initState();
    //checkToken();
    try {
      _getCurrentLocation();
      checkUser();
    } on SocketException catch (_) {
      _showAlertDialog(context, 'Pas de connecxion !');
    } catch (_) {
      print('fkkkkkkk');
    }
  }

  @override
  void dispose() {
    _email.clear();
    _password.clear();
    _company.clear();
    super.dispose();
  }

  Future<void> getAllUsers() async {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> rows = await dbHelper.queryAllUserRows();
    print('rows:: ${rows.length}');
    for (int i = 0; i < rows.length; i++) {
      options.add(User(
          userId: rows[i][DatabaseHelper.columnUserId],
          password: rows[i][DatabaseHelper.columnUserPassword],
          company: rows[i][DatabaseHelper.columnUserSociete]));
    }
  }

  @override
  Widget build(BuildContext context) {
    getAllUsers();
    CustomUserNameTextField field = CustomUserNameTextField(
      controller: _email,
      passwordController: _password,
      comapanyController: _company,
      options: options,
    );
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          )
        : Material(
            child: Stack(
              children: [
                Image.asset(
                  'assets/authentification.jpg',
                  // Replace with your actual image path
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover, // Adjust the image fit property as needed
                ),
                Scaffold(
                  backgroundColor: Colors.transparent,
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
                    child: AutofillGroup(
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
                                    Image(
                                      width: 200,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      image: AssetImage(
                                        'assets/icon.png',
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Text('se connecter',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor)),
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
                                          field,
                                          // customTextField(
                                          //     obscure: false,
                                          //     controller: _email,
                                          //     hint: 'Utilisateur',
                                          //     icon: Icon(
                                          //       Icons.person_outline,
                                          //       color: Theme.of(context)
                                          //           .primaryColor,
                                          //     )),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          CustomPasswordTextField(
                                            controller: _password,
                                          ),
                                          // customTextField(
                                          //     obscure: true,
                                          //     controller: _password,
                                          //     hint: 'Mot de passe',
                                          //     icon: Icon(
                                          //       Icons.lock_outline,
                                          //       color: Theme.of(context)
                                          //           .primaryColor,
                                          //     )),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          customTextField(
                                              obscure: false,
                                              controller: _company,
                                              hint: 'Société',
                                              icon: Icon(
                                                Icons.business_outlined,
                                                color: Theme.of(context)
                                                    .primaryColor,
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
                                                primary: Theme.of(context)
                                                    .primaryColor,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30))),
                                            onPressed: () {
                                              if (field.controller.text.isEmpty)
                                                return;
                                              if (formKey.currentState !=
                                                      null &&
                                                  formKey.currentState!
                                                      .validate()) {
                                                setState(() {
                                                  print('validation!');
                                                  final user = User(
                                                      userId: field
                                                          .controller.text
                                                          .trim(),
                                                      password:
                                                          _password.text.trim(),
                                                      company:
                                                          _company.text.trim());
                                                  showLoaderDialog(context);
                                                  auth
                                                      .loginUser(
                                                    user: user,
                                                    context: context,
                                                  )
                                                      .then((int value) {
                                                    Navigator.pop(context);
                                                    print('value inr $value');
                                                    if (value == 0) {
                                                      print(
                                                          'user::: ${AppUrl.user.userId} ${AppUrl.user.password} ${AppUrl.user.company}');
                                                      insertUser();
                                                      if (AppUrl
                                                              .etabList.length >
                                                          1)
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return EtablissmentDialog();
                                                          },
                                                        ).then((value) => Navigator
                                                            .pushNamedAndRemoveUntil(
                                                                context,
                                                                '/activities',
                                                                (route) =>
                                                                    false));
                                                      else {
                                                        AppUrl.user.etblssmnt = AppUrl.etabList.first;
                                                        final provider = DatabaseProvider();
                                                        provider.saveEtablissements(AppUrl.etabList.first);
                                                        getLocalDepot().then((value) {
                                                          print('ffefef');
                                                          provider.saveDepotAndRep(
                                                              AppUrl.user.localDepot, AppUrl.user.repCode);
                                                          Navigator
                                                              .pushNamedAndRemoveUntil(
                                                              context,
                                                              '/activities',
                                                                  (route) =>
                                                              false);
                                                        });
                                                      }
                                                    } else if (value == 1) {
                                                      // dialog not internet connnexion
                                                      _showAlertDialog(context,
                                                          'Pas de connecxion !');
                                                    } else if (value == 2) {
                                                      // dialog not internet connnexion
                                                      _showAlertDialog(context,
                                                          'nom d\'utilisateur, mot de passe ou nom de société incorrect !');
                                                    }
                                                  });
                                                });
                                              }
                                            },
                                            child: const Text(
                                              "CONNEXION",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
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
                ),
                Positioned(
                    right: 10.0,
                    top: 30.0,
                    child: Container(
                      height: 36,
                      width: 36,
                      child: Visibility(
                        visible: false,
                        child: IconButton(
                          onPressed: () {
                            print('gggggg');
                            PageNavigator(ctx: context)
                                .nextPage(page: ParameterPage());
                          },
                          icon: Icon(
                            Icons.settings_outlined,
                            size: 36.0,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
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
                                context, '/activities', (route) => false);
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
      print('user equipeId: ${value.equipeId}');
      if (AppUrl.user.token != null) {
        String company = AppUrl.user.company!;
        //String url = AppUrl.baseUrl + AppUrl.auth;
        String url =
            'http://' + company + '.my-crm.net:5188/api/Auth/Authenticate';
        AppUrl.baseUrlApi = 'http://' + company + '.my-crm.net:5188/api/';
        ;
        AppUrl.baseUrl = 'http://' + company + '.my-crm.net:5188/';
        print('urls??: ${url}');
        print('urls??: ${AppUrl.baseUrlApi}');
        print('urls??: ${AppUrl.baseUrl}');
        showLoaderDialog(context);
        final provider = Provider.of<AuthProvider>(context, listen: false);
        // provider.getMenuAcces(AppUrl.user).then((value) {
        //
        // });
        provider.getTeams(AppUrl.user).then((value) {
          if (value) {
            provider.getCollaborateurs(AppUrl.user).then((value) {
              provider.getPipelines(AppUrl.user).then((value) {
                provider.getStartEnd(AppUrl.user).then((value) {
                  provider.getUpdate().then((value) {
                    HttpRequestApp().sendItinerary('CNX');
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/activities', (route) => false);
                  });
                });
              });
            });
          } else {
            _showAlertDialog(context, 'pas de connexion !');
          }
        });
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

class CustomUserNameTextField extends StatefulWidget {
  TextEditingController controller;
  TextEditingController passwordController;
  TextEditingController comapanyController;
  List<User> options;

  CustomUserNameTextField({
    super.key,
    required this.controller,
    required this.options,
    required this.passwordController,
    required this.comapanyController,
  });

  @override
  State<CustomUserNameTextField> createState() =>
      _CustomUserNameTextFieldState();
}

class _CustomUserNameTextFieldState extends State<CustomUserNameTextField> {
  bool _isUsernameValid = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return Future.value(
                  widget.options.map((user) => user.userId!).toSet().toList());
            } else
              return Future.value(widget.options
                  .where((option) => option.userId!
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()))
                  .map((user) => user.userId!)
                  .toSet()
                  .toList());
          },
          onSelected: (selectedOption) {
            print('Selected: $selectedOption');
            User user = widget.options
                .where((element) => element.userId == selectedOption)
                .first;
            widget.passwordController.text = user.password!;
            widget.comapanyController.text = user.company!;
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            widget.controller = textEditingController;
            return TextField(
                // validator: (value) {
                //   if (value == null || value.isEmpty) return "champs vide !";
                // },
                //controller: widget.controller,
                controller: widget.controller,
                focusNode: focusNode,
                onEditingComplete: onFieldSubmitted,
                // onChanged: (String value) {
                //   print('efeefe');
                //   onFieldSubmitted();
                // },
                onChanged: (value) {
                  setState(() {
                    print('rgrgr : ${widget.controller.text.trim()}');
                    print('rgrgr : ${textEditingController.text.isEmpty}');
                    _isUsernameValid = value.isNotEmpty;
                  });
                },
                maxLines: 1,
                decoration: txtInputDecoration.copyWith(
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                  labelText: 'Utilisateur',
                  errorText: _isUsernameValid ? null : 'champs vide !',
                ));
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<String> onSelected, options) {
            return Material(
              elevation: 4.0,
              child: SizedBox(
                height: 20 * options.length.toDouble(),
                child: ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = options.elementAt(index);
                    return GestureDetector(
                      onTap: () {
                        onSelected(option);
                      },
                      child: ListTile(
                        title: Text(
                          '$option',
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          displayStringForOption: (item) {
            return item;
          },
        ),
      ],
    );
  }
}

class CustomPasswordTextField extends StatefulWidget {
  final TextEditingController controller;

  const CustomPasswordTextField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  _CustomPasswordTextFieldState createState() =>
      _CustomPasswordTextFieldState();
}

class _CustomPasswordTextFieldState extends State<CustomPasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) return "champs vide !";
            },
            cursorColor: primaryColor,
            //autofillHints: [AutofillHints.password],
            onEditingComplete: () => TextInput.finishAutofillContext(),
            obscureText: _obscureText,
            controller: widget.controller,
            maxLines: 1,
            decoration: txtInputDecoration.copyWith(
              prefixIcon: Icon(
                Icons.lock_outline,
                color: Theme.of(context).primaryColor,
              ),
              labelText: 'Mot de passe',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            )
            // InputDecoration(hintText: hint, border: InputBorder.none, prefixIcon: icon),
            )
      ],
    );
    // return TextFormField(
    //   obscureText: widget.obscure ? _obscureText : false,
    //   controller: widget.controller,
    //   decoration: InputDecoration(
    //     labelText: widget.hint,
    //     suffixIcon: widget.obscure
    //         ? IconButton(
    //       icon: _obscureText
    //           ? Icon(Icons.visibility)
    //           : Icon(Icons.visibility_off),
    //       color: Theme.of(context).primaryColor,
    //       onPressed: () {
    //         setState(() {
    //           _obscureText = !_obscureText;
    //         });
    //       },
    //     )
    //         : null,
    //     prefixIcon: widget.icon,
    //   ),
    // );
  }
}

showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Container(
        width: 200, height: 100, child: Image.asset('assets/CRM-Loader.gif')),
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
              DatabaseProvider().logOutExp(context);
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

class EtablissmentDialog extends StatefulWidget {
  const EtablissmentDialog({super.key});

  @override
  State<EtablissmentDialog> createState() => _EtablissmentDialogState();
}

Future<void> insertUser() async {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  Map<String, dynamic> row = {
    DatabaseHelper.columnUserId: '${AppUrl.user.userId}',
    DatabaseHelper.columnUserPassword: '${AppUrl.user.password}',
    DatabaseHelper.columnUserSociete: '${AppUrl.user.company}',
  };
  int id = await dbHelper.insertUser(row);
  print('inserted!! ${id}');
}

class _EtablissmentDialogState extends State<EtablissmentDialog> {
  late Etablissement selectedEtabl = AppUrl.etabList.first;

  @override
  Widget build(BuildContext context) {
    AppUrl.user.etblssmnt = selectedEtabl;
    return SimpleDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Choix d\'établissement',
        style: Theme.of(context).textTheme.headline3,
      ),
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            // Set desired border radius
            color: Colors.white,
          ),
          width: 550,
          height: 200,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: Text(
                    'Choix d\'établissement',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle: DropdownButtonFormField<Etablissement>(
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2, color: primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2, color: primaryColor),
                        )),
                    hint: Text(
                      'Selectioner l\'établissement',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.grey),
                    ),
                    value: selectedEtabl,
                    onChanged: (newValue) async {
                      selectedEtabl = newValue!;
                      setState(() {});
                    },
                    items: AppUrl.etabList.map<DropdownMenuItem<Etablissement>>(
                        (Etablissement value) {
                      return DropdownMenuItem<Etablissement>(
                        value: value,
                        child: Text(
                          value.name!,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onPressed: () async {
                    showLoaderDialog(context);
                    AppUrl.user.etblssmnt = selectedEtabl;
                    final provider = DatabaseProvider();
                    provider.saveEtablissements(selectedEtabl);
                    AppUrl.user.etblssmnt = selectedEtabl;
                    await getLocalDepot();
                    provider.saveDepotAndRep(
                        AppUrl.user.localDepot, AppUrl.user.repCode);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Confirmer",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
Future<void> getLocalDepot() async {
  String url = AppUrl.getLocalDepot +
      '${AppUrl.user.salCode}/${AppUrl.user.etblssmnt!.code}';
  print('url depot');
  http.Response req = await http.get(Uri.parse(url), headers: {
    "Accept": "application/json",
    "content-type": "application/json; charset=UTF-8",
    "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/",
    'Authorization': 'Bearer ${AppUrl.user.token}',
  });

  print("res depot code is : ${req.statusCode}");
  print("res depot body: ${req.body}");
  if (req.statusCode == 200) {
    List<dynamic> data = json.decode(req.body);
    data.toList().forEach((element) {
      AppUrl.user.localDepot =
          Depot(id: element['depCode'], name: element['depNom']);
      AppUrl.user.repCode = element['repCode'];
    });
  }
}
