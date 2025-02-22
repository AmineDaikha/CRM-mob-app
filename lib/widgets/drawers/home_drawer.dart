import 'package:flutter/material.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/database/db_provider.dart';
import 'package:mobilino_app/styles/colors.dart';
 import 'package:mobilino_app/widgets/confirmation_dialog.dart';
import 'package:mobilino_app/widgets/drawer_notif.dart';

class DrawerHomePage extends StatefulWidget {
  const DrawerHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<DrawerHomePage> createState() => _DrawerHomePageState();
}

class _DrawerHomePageState extends State<DrawerHomePage> {
  bool isVisible = false;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        height: double.infinity,
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.9,
              child: ListView(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //padding: EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0),
                children: [
                  UserAccountsDrawerHeader(
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
                      backgroundColor: primaryColor,
                      foregroundImage:
                          NetworkImage('${AppUrl.baseUrl}${AppUrl.user.image}'),
                      //AssetImage('assets/delivery.png'),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Icon(Icons.local_activity_outlined,
                                color: Theme.of(context).primaryColor),
                            Text(
                              'Mes activités',
                              style: Theme.of(context).textTheme.headline4,
                            )
                          ]),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/activities', (route) => false);
                      }),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Icon(Icons.map_outlined,
                                color: Theme.of(context).primaryColor),
                            Text(
                              'Opportunités / Tournées',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(color: primaryColor),
                            )
                          ]),
                      onTap: () {
                        Navigator.pop(context);
                      }),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Icon(Icons.note_outlined,
                                color: Theme.of(context).primaryColor),
                            Text(
                              'Mes Notes',
                              style: Theme.of(context).textTheme.headline4,
                            )
                          ]),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/notes', (route) => false);
                      }),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Icon(Icons.lightbulb_circle_outlined,
                                color: Theme.of(context).primaryColor),
                            Text(
                              'Projets',
                              style: Theme.of(context).textTheme.headline4,
                            )
                          ]),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/projects', (route) => false);
                      }),
                  SizedBox(
                    height: 15,
                  ),
                  Column(
                    children: [
                      InkWell(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Icon(Icons.storefront,
                                    color: Theme.of(context).primaryColor),
                                Text(
                                  'Marketing',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .copyWith(),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                (!isVisible)
                                    ? Icon(
                                  Icons.arrow_drop_down,
                                  color: primaryColor,
                                )
                                    : Icon(
                                  Icons.arrow_drop_up,
                                  color: primaryColor,
                                )
                              ]),
                          onTap: () {
                            setState(() {
                              print('viss: $isVisible');
                              isVisible = !isVisible;
                              print('viss: $isVisible');
                            });
                          }),
                      Visibility(
                          visible: isVisible,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            width: double.infinity,
                            color: primaryColor,
                            height: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/salon', (route) => false);
                                  },
                                  child: Container(
                                    color: primaryColor,
                                    child: Text(
                                      'Foires et Salons',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/salon', (route) => false);
                                  },
                                  child: Container(
                                    color: primaryColor,
                                    child: Text(
                                      'Compagne marketing',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/salon', (route) => false);
                                  },
                                  child: Container(
                                    color: primaryColor,
                                    child: Text(
                                      'Promotions',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 15),
                            Icon(Icons.location_on_outlined,
                                color: Theme.of(context).primaryColor),
                            Text(
                              'Mes Itinéraires',
                              style: Theme.of(context).textTheme.headline4,
                            )
                          ]),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/itinerary', (route) => false);
                      }),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 15),
                            Icon(
                              Icons.groups_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text(
                              'Prospects / Clients',
                              style: Theme.of(context).textTheme.headline4,
                            )
                          ]),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/clients', (route) => false);
                      }),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 15),
                            Icon(
                              Icons.image_search_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text(
                              'Catalogue',
                              style: Theme.of(context).textTheme.headline4,
                            )
                          ]),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/catalog', (route) => false);
                      }),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 15),
                            Icon(
                              Icons.shopping_cart_checkout,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text('Prise de Commande',
                                style: Theme.of(context).textTheme.headline4),
                          ]),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/command', (route) => false);
                      }),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 15),
                            Icon(
                              Icons.work_outline,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text(
                              'Mes devis / Mes commandes',
                              style: Theme.of(context).textTheme.headline4,
                            )
                          ]),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/mycommands', (route) => false);
                      }),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 15),
                            Icon(
                              Icons.delivery_dining_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text(
                              'Mes livraisons',
                              style: Theme.of(context).textTheme.headline4,
                            )
                          ]),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/mydelivery', (route) => false);
                      }),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 15),
                            Icon(
                              Icons.keyboard_return,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text(
                              'Retours',
                              style: Theme.of(context).textTheme.headline4,
                            )
                          ]),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/return', (route) => false);
                      }),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 15),
                            Icon(
                              Icons.money_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text(
                              'Encaissements',
                              style: Theme.of(context).textTheme.headline4,
                            )
                          ]),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/payment', (route) => false);
                      }),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 15),
                            Icon(
                              Icons.receipt_long_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text(
                              'Tickets',
                              style: Theme.of(context).textTheme.headline4,
                            )
                          ]),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/tickets', (route) => false);
                      }),
                  SizedBox(
                    height: 15,
                  ),
                  // ListTile(
                  //     leading: Icon(
                  //       Icons.swap_vert_outlined,
                  //       color: Theme.of(context).primaryColor,
                  //     ),
                  //     title: Text(
                  //       'Chargement / Déchargement',
                  //       style: Theme.of(context).textTheme.headline4,
                  //     ),
                  //     onTap: () {
                  //       Navigator.pushNamedAndRemoveUntil(
                  //           context, '/charg', (route) => false);
                  //     }),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Divider(
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'version 1.0.0',
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.grey),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(Icons.logout_outlined,
                                  color: Theme.of(context).primaryColor),
                              InkWell(
                                onTap: () async {
                                  ConfirmationDialog confirmationDialog =
                                      ConfirmationDialog();
                                  bool confirmed = await confirmationDialog
                                      .showConfirmationDialog(
                                          context, 'logout');
                                  if (confirmed) {
                                    DatabaseProvider().logOut(context);
                                  }
                                },
                                child: Text(
                                  'Déconnexion',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(
                                          color:
                                              Theme.of(context).primaryColor),
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
