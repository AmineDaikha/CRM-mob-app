import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/client.dart';

//import 'package:mobilino_app/screens/clients_page/new_command_page.dart';
//import 'package:mobilino_app/screens/clients_page/store_page.dart';
import 'package:mobilino_app/screens/home_page/delivred_history_fragment.dart';
import 'package:mobilino_app/screens/home_page/commands_history_fragment.dart';
import 'package:mobilino_app/screens/home_page/payment_history_fragment.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/widgets/add_payment_dialog.dart';
import 'package:mobilino_app/screens/notes_page/title_note_dialog.dart';
import 'package:mobilino_app/widgets/payment_page.dart';

import '../new_command_page/store_page.dart';
import 'dialog_filtred_commands_clients.dart';
//import 'package:mobilino_app/screens/home_page/init_store_page.dart';

class ClientHistoryPage extends StatefulWidget {
  final Client client;

  const ClientHistoryPage({super.key, required this.client});

  @override
  State<ClientHistoryPage> createState() => _ClientHistoryPageState();
}

class _ClientHistoryPageState extends State<ClientHistoryPage> {
  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: primaryColor,
          children: [
            SpeedDialChild(
              backgroundColor: primaryColor,
              child: Icon(
                Icons.payment_outlined,
                color: Colors.white,
              ),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PaymentPage(
                          client: widget.client); // client: widget.client,
                    });
              },
              label: 'Nouveau versement',
            ),
            SpeedDialChild(
              backgroundColor: primaryColor,
              child: Icon(
                Icons.delivery_dining_outlined,
                color: Colors.white,
              ),
              onTap: () {
                PageNavigator(ctx: context).nextPage(
                    page: StorePage(
                  client: widget.client,
                ));
              },
              label: 'Nouvelle livraison',
            ),
            SpeedDialChild(
              backgroundColor: primaryColor,
              child: Icon(
                Icons.file_open_outlined,
                color: Colors.white,
              ),
              onTap: () {
                PageNavigator(ctx: context).nextPage(
                    page: StorePage(
                  client: widget.client,
                ));
              },
              label: 'Nouvelle commande',
            ),
          ],
        ),
        appBar: ClientAppBar(
          client: widget.client,
          callback: reload,
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  DelivredHistoryFragment(
                    client: widget.client,
                  ),
                  CommandsHistoryFragment(
                    client: widget.client,
                  ),
                  PaymentHistoryFragment(
                    client: widget.client,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Client client;
  final VoidCallback callback;

  const ClientAppBar({Key? key, required this.client, required this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        IconButton(
            onPressed: () {
              //_showDatePicker(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return FiltredCommandsClientDialog();
                },
              ).then((value) {
                callback();
              });
            },
            icon: Icon(
              Icons.sort,
              color: Colors.white,
            ))
      ],
      iconTheme: IconThemeData(
        color: Colors.white, // Set icon color to white
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${client.name}',
            style: Theme.of(context)
                .textTheme
                .headline3!
                .copyWith(color: Colors.white),
          ),
          Container(
            child: (AppUrl.filtredCommandsClient.allCollaborators)
                ? Text(
                    'Collaborateurs: Tout',
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: Colors.white),
                  )
                : Text(
                    'Collaborateurs: ${AppUrl.filtredCommandsClient.collaborateur!.userName}',
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: Colors.white),
                  ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(48.0), // Adjust this as needed
        child: Container(
          color: Colors.white,
          child: TabBar(
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).primaryColor),
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              indicator: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                width: 2.5,
                color: Theme.of(context).primaryColor,
              ))),
              tabs: [
                Tab(
                  text: 'Historique\n livraisons',
                ),
                Tab(
                  text: ' Historique\ncommandes',
                ),
                Tab(
                  text: 'Historique\npaiements',
                ),
              ]),
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(100.0);
}
