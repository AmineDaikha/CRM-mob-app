import 'package:flutter/material.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/providers/notif_provider.dart';
import 'package:mobilino_app/screens/notifs_pages/notifs_list_page.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:provider/provider.dart';

import 'test_widget.dart';

class NotificationDrawerHeader extends StatefulWidget {
  @override
  _NotificationDrawerHeaderState createState() =>
      _NotificationDrawerHeaderState();
}

class _NotificationDrawerHeaderState extends State<NotificationDrawerHeader> {
  int _notificationCount = 45; // Set your initial notification count here

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<NotifProvider>(context, listen: false);
    // provider.countNotif = AppUrl.nbNotif;
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/background_drawer.PNG"),
          fit: BoxFit.cover,
        ),
      ),
      accountEmail: Text('${AppUrl.user.email}'),
      accountName: Row(
        children: [
          Text('${AppUrl.user.role}: '),
          Text('${AppUrl.user.userId}'),
        ],
      ),
      currentAccountPicture: CircleAvatar(
        foregroundImage: NetworkImage('${AppUrl.baseUrl}${AppUrl.user.image}'),
      ),
      otherAccountsPictures: [
        GestureDetector(
          onTap: () {
            PageNavigator(ctx: context).nextPage(page: NotifsListPage()).then((value) {
              setState(() {

              });
            });
          },
          child: Consumer<NotifProvider>(
            builder: (context, provider, child) {
              // Update the provider's countNotif here if needed
              provider.countNotif = AppUrl.nbNotif;
              return Stack(
                children: <Widget>[
                  Icon(
                    Icons.notifications,
                    size: 36.0,
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '${provider.countNotif}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
