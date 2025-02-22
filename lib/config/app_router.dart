//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobilino_app/screens/activities_pages/activity_list_page.dart';
import 'package:mobilino_app/screens/catalog_page/store_page.dart';
import 'package:mobilino_app/screens/chargement/chargement_page.dart';
import 'package:mobilino_app/screens/clients_page/add_client_page1.dart';
import 'package:mobilino_app/screens/clients_page/add_client_page2.dart';
import 'package:mobilino_app/screens/clients_page/clients_list_page.dart';
import 'package:mobilino_app/screens/home_page/client_page.dart';
import 'package:mobilino_app/screens/home_page/home_page.dart';
import 'package:mobilino_app/screens/itinerary_pages/itinerary_page.dart';
import 'package:mobilino_app/screens/my_commands_page/my_commands_page.dart';
import 'package:mobilino_app/screens/my_delivery_page/my_delivery_page.dart';
import 'package:mobilino_app/screens/new_command_page/command_list_page.dart';
import 'package:mobilino_app/screens/notes_page/note_liste_page.dart';
import 'package:mobilino_app/screens/payment_page/payment_client_list_page.dart';
import 'package:mobilino_app/screens/payment_page/payment_list_page.dart';
import 'package:mobilino_app/screens/projects_page/projects_liste_page.dart';
import 'package:mobilino_app/screens/return_page/return_list_page.dart';
import 'package:mobilino_app/screens/salon_page/salon_liste_page.dart';

import 'package:mobilino_app/screens/screens.dart';
//import 'package:mobilino_app/screens/ticket_page/tickets_liste_page.dart';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    print('This is route: ${settings.name}');

    switch (settings.name) {
      case '/':
        return LoginPage.route();
      case LoginPage.routeName:
        return LoginPage.route();
      case HomePage.routeName:
        return HomePage.route();
      case NoteListPage.routeName:
        return NoteListPage.route();
      case ItineraryPage.routeName:
        return ItineraryPage.route();
      case ProjectsListPage.routeName:
        return ProjectsListPage.route();
      case SalonListPage.routeName:
        return SalonListPage.route();
      // case TicketsListPage.routeName:
      //   return TicketsListPage.route();
      // case CommandPage.routeName:
      //   return CommandPage.route();
      // case ClientPage.routeName:
      //   return ClientPage.route();
      case ClientsListPage.routeName:
        return ClientsListPage.route();
      case AddClientPage1.routeName:
        return AddClientPage1.route();
      case AddClientPage2.routeName:
        return AddClientPage2.route();
      case StorePage.routeName:
        return StorePage.route();
      case ActivityListPage.routeName:
        return ActivityListPage.route();
      case MyDelivryPage.routeName:
        return MyDelivryPage.route();
      case CommandListPage.routeName:
        return CommandListPage.route();
      case ReturnListPage.routeName:
        return ReturnListPage.route();
      case PaymentListPage.routeName:
        return PaymentListPage.route();
      case ChargPage.routeName:
        return ChargPage.route();
      case MyCommandsPage.routeName:
        return MyCommandsPage.route();
      default:
        return _errorRoute();
    }
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
      settings: RouteSettings(name: '/error'),
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('Error')),
      ),
    );
  }
}
