import 'package:flutter/material.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/widgets/text_field.dart';

import 'add_client_page2.dart';

class AddClientPage1 extends StatefulWidget {
  const AddClientPage1({super.key});

  static const String routeName = '/clients/add1';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => AddClientPage1(),
    );
  }

  @override
  State<AddClientPage1> createState() => _AddClientPage1State();
}

final List<String> options = ['Prospect', 'Client'];

class _AddClientPage1State extends State<AddClientPage1> {
  final TextEditingController nameRs = TextEditingController();
  final TextEditingController namRS2 = TextEditingController();
  final TextEditingController tel1 = TextEditingController();
  final TextEditingController tel2 = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController sold = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  String currentOption = options[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set icon color to white
        ),
        backgroundColor: primaryColor,
        title: Text(
          'Ajouter un client',
          style: Theme.of(context)
              .textTheme
              .headline2!
              .copyWith(color: Colors.white),
        ),
      ),
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset(
                  'assets/addclient.png',
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: customTextField(
                        obscure: false,
                        controller: nameRs,
                        hint: 'Nom',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: customTextFieldEmpty(
                        obscure: false,
                        controller: namRS2,
                        hint: 'Nom 2',
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: customTextField(
                        obscure: false,
                        controller: tel1,
                        hint: 'Téléphone 1',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: customTextFieldEmpty(
                        obscure: false,
                        controller: tel2,
                        hint: 'Téléphone 2',
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                customTextField(
                  obscure: false,
                  controller: email,
                  hint: 'Adresse e-mail ',
                ),
                Row(
                  children: [
                    Expanded(
                      child: customTextFieldEmpty(
                        obscure: false,
                        controller: sold,
                        hint: 'Solde',
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              options[0],
                              style: TextStyle(color: primaryColor),
                            ),
                            leading: Radio(
                              activeColor: primaryColor,
                              value: options[0],
                              groupValue: currentOption,
                              onChanged: (value) {
                                setState(() {
                                  currentOption = value.toString();
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: Text(
                              options[1],
                              style: TextStyle(color: primaryColor),
                            ),
                            leading: Radio(
                              value: options[1],
                              activeColor: primaryColor,
                              groupValue: currentOption,
                              onChanged: (value) {
                                setState(() {
                                  currentOption = value.toString();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    width: 200,
                    height: 45,
                    // todo 7
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      onPressed: () {
                        if (_formkey.currentState != null &&
                            _formkey.currentState!.validate()) {
                          String type = '';
                          if(options.indexOf(currentOption) == 0)
                            type = 'P';
                          else
                            type = 'C';
                          print('type: $type');
                          AppUrl.client = Client(
                              name: nameRs.text.trim(),
                              name2: namRS2.text.trim(),
                              phone: tel1.text.trim(),
                              phone2: tel2.text.trim(),
                              email: email.text.trim(),
                              total: sold.text.trim(),
                            type: type,
                          );
                          Navigator.pushNamed(
                              context, AddClientPage2.routeName);
                        }
                      },
                      child: const Text(
                        "Continuer",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
