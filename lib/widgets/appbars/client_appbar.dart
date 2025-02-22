import 'package:flutter/material.dart';
import 'package:mobilino_app/models/client.dart';

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
        'Client Name',
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
                  text: 'Historique commandes',
                ),
                Tab(
                  text: 'Historique versements',
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
