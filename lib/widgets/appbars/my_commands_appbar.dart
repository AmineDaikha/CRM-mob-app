import 'package:flutter/material.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/screens/payment_page/dialog_filtred_commands_clients.dart';
//import 'package:mobilino_app/screens/clients_page/dialog_filtred_commands_clients.dart';

class MyCommandsAppBar extends StatelessWidget implements PreferredSizeWidget {

  final VoidCallback voidCallback;
  MyCommandsAppBar({
    Key? key,
    required this.voidCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(

      iconTheme: IconThemeData(
        color: Colors.white, // Set icon color to white
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes devis / Mes commandes',
            style: Theme.of(context)
                .textTheme
                .headline4!
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            'Client : ${AppUrl.filtredCommandsClient.client!.name}',
            style: Theme.of(context)
                .textTheme
                .bodyText2!
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            'Collaborateur : ${AppUrl.filtredCommandsClient.collaborateur!.userName}',
            style: Theme.of(context)
                .textTheme
                .bodyText2!
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
            onPressed: () {
              //_showDatePicker(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return FiltredCommandsClientDialog();
                },
              ).then((value){
                voidCallback();
              });
            },
            icon: Icon(
              Icons.sort,
              color: Colors.white,
            ))
        // IconButton(
        //   icon: Icon(
        //     Icons.search,
        //     color: Colors.white,
        //   ),
        //   onPressed: () {
        //     showSearch(
        //         context: context,
        //         delegate: ClientSearchDelegate(),
        //         query: '');
        //   },
        // ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(48.0), // Adjust this as needed
        child: Container(
          color: Colors.white,
          child: TabBar(
              isScrollable: false,
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
                  text: 'Mes Devis',
                ),
                Tab(
                  text: 'Mes commandes',
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
