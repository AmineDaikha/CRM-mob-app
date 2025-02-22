import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/screens/clients_page/new_command_page.dart';
import 'package:mobilino_app/screens/clients_page/store_page.dart';
import 'package:mobilino_app/screens/home_page/delivred_history_fragment.dart';
import 'package:mobilino_app/screens/home_page/commands_history_fragment.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:mobilino_app/widgets/add_payment_dialog.dart';



class ClientPage extends StatefulWidget {
  final Client client;
  const ClientPage({super.key, required this.client});


  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
                      return AddPaymentDialog(client: widget.client,);
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
              onTap: () {},
              label: 'Nouvelle livraison',
            ),
            SpeedDialChild(
              backgroundColor: primaryColor,
              child: Icon(
                Icons.file_open_outlined,
                color: Colors.white,
              ),
              onTap: () {
                PageNavigator(ctx: context).nextPage(page: StorePage(client: widget.client,));
              },
              label: 'Nouvelle commande',
            ),
          ],
        ),
        appBar: ClientAppBar(client: widget.client,),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  CommandsHistoryFragment(client: widget.client,),
                  DelivredHistoryFragment(client: widget.client,),
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
  const ClientAppBar({
    Key? key,
    required this.client
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: Colors.white, // Set icon color to white
      ),
      title: Text(
        '${client.name}',
        style: Theme.of(context)
            .textTheme
            .headline2!
            .copyWith(color: Colors.white),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(48.0), // Adjust this as needed
        child: Container(
          color: Colors.white,
          child: TabBar(

              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).primaryColor),
              labelColor:  Theme.of(context).primaryColor,
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
                  text: 'Historique livraisons',
                ),
                Tab(
                  text: 'Historique commandes',
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


