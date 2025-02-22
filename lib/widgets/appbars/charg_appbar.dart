import 'package:flutter/material.dart';

class ChargAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChargAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: Colors.white, // Set icon color to white
      ),
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(
        'Chargement / Déchargement',
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

              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColor),
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
                  text: 'Chargement',
                ),
                Tab(
                  text: 'Déchargement',
                ),
              ]),
        ),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(100.0);
}
