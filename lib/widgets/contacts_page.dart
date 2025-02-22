import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/constants/utils.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/collaborator.dart';
import 'package:mobilino_app/models/contact.dart';
import 'package:mobilino_app/models/payment.dart';
import 'package:mobilino_app/models/team.dart';
import 'package:mobilino_app/providers/payment_provider.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/snack_message.dart';
import 'package:mobilino_app/widgets/text_field.dart';
import 'package:provider/provider.dart';

import 'confirmation_dialog.dart';

class ContactsPage extends StatefulWidget {
  final List<Contact> contacts;
  final Client client;
  ContactsPage({
    super.key,
    required this.contacts,
    required this.client,
  });

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    AppUrl.user.selectedContact = [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Future is still running, return a loading indicator or some placeholder.
            return Center(
              child: Row(
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                  ),
                  Center(
                    child: Container(
                      color: Colors.white,
                      margin: EdgeInsets.only(left: 15),
                      child: Text(
                        'Loading...',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // There was an error in the future, handle it.
            return Text('Error: ${snapshot.error}');
          }
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.white, // Set icon color to white
              ),
              backgroundColor: Theme.of(context).primaryColor,
              title: ListTile(
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contacts de tiers : ',
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    (widget.client.name != null)?Text(
                      '${widget.client.name}',
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ): Container(),
                  ],
                ),
              ),
            ),
            body: Form(
              key: formKey,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: (widget.contacts.length == 0)
                            ? Center(
                                child: Text(
                                  'Aucun contact!',
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                              )
                            : ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) => EchItem(
                                      contact: widget.contacts[index],
                                    ),
                                itemCount: widget.contacts.length),
                      ))
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class EchItem extends StatefulWidget {
  final Contact contact;

  //final String paymentVal;

  const EchItem({super.key, required this.contact});

  @override
  State<EchItem> createState() => _EchItemState();
}

class _EchItemState extends State<EchItem> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                activeColor: primaryColor,
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      AppUrl.user.selectedContact.add(widget.contact);
                    } else {
                      AppUrl.user.selectedContact
                          .remove(widget.contact);
                    }
                    isSelected = value;
                  });
                  Navigator.of(context).pop();
                },
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                //crossAxisAlignment: CrossAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.contact.famillyName} ${widget.contact.firstName}',
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(color: primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.grey,
        )
      ],
    );
  }
}
