import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/models/command.dart';
import 'package:mobilino_app/models/product.dart';

import '../models/client.dart';

class ClientsMapProvider extends ChangeNotifier {
  List<Client> clientsList = [];
  List<Client> filtredClients = [];
  List<Client> mapClientsCalander = [];
  List<Client> mapClientsWithCommands = [
    // Client(
    //   name: 'Client1',
    //   city: 'city1',
    //   phone: '0123',
    //   stat: 1,
    //   total: '1500000.00',
    //   command: Command(
    //       paid: 0,
    //       date: DateTime.now(),
    //       nbProduct: 0,
    //       total: 0,
    //       products: [
    //         Product(
    //             id: 1.toString(),
    //             isChosen: true,
    //             total: 0,
    //             name: 'produit1',
    //             category: 'category1',
    //             quantity: 2,
    //             price: 120.00,
    //             image: 'image'),
    //         Product(
    //             id: 2.toString(),
    //             isChosen: true,
    //             total: 0,
    //             name: 'produit2',
    //             category: 'category2',
    //             quantity: 3,
    //             price: 420.00,
    //             image: 'image'),
    //         Product(
    //             id: 3.toString(),
    //             isChosen: true,
    //             total: 0,
    //             name: 'produit3',
    //             category: 'category3',
    //             quantity: 1,
    //             price: 170.00,
    //             image: 'image'),
    //       ].toList()),
    //   location: LatLng(1.354474457244855, 1.849465150689236),
    // ),
    // Client(
    //   name: 'Client2',
    //   city: 'city2',
    //   phone: '0123',
    //   stat: 2,
    //   total: '1500000.00',
    //   command: Command(
    //       paid: 0,
    //       date: DateTime.now(),
    //       nbProduct: 0,
    //       total: 0,
    //       products: [
    //         Product(
    //             id: 4.toString(),
    //             isChosen: true,
    //             total: 0,
    //             name: 'produit1',
    //             category: 'category1',
    //             quantity: 2,
    //             price: 120.00,
    //             image: 'image'),
    //         Product(
    //             id: 5.toString(),
    //             isChosen: true,
    //             total: 0,
    //             name: 'produit2',
    //             category: 'category2',
    //             quantity: 3,
    //             price: 420.00,
    //             image: 'image'),
    //         Product(
    //             id: 6.toString(),
    //             isChosen: true,
    //             total: 0,
    //             name: 'produit3',
    //             category: 'category3',
    //             quantity: 1,
    //             price: 170.00,
    //             image: 'image'),
    //       ].toList()),
    //   location: LatLng(33.36076703354525, 6.859727831944034),
    // ),
    // Client(
    //   name: 'Client3',
    //   city: 'city3',
    //   phone: '0123',
    //   stat: 2,
    //   total: '-90000.00',
    //   command: Command(
    //       paid: 0,
    //       date: DateTime.now(),
    //       nbProduct: 0,
    //       total: 0,
    //       products: [
    //         Product(
    //             id: 7.toString(),
    //             isChosen: true,
    //             total: 0,
    //             name: 'produit1',
    //             category: 'category1',
    //             quantity: 2,
    //             price: 120.00,
    //             image: 'image'),
    //         Product(
    //             id: 8.toString(),
    //             isChosen: true,
    //             total: 0,
    //             name: 'produit2',
    //             category: 'category2',
    //             quantity: 3,
    //             price: 420.00,
    //             image: 'image'),
    //         Product(
    //             id: 9.toString(),
    //             isChosen: true,
    //             total: 0,
    //             name: 'produit3',
    //             category: 'category3',
    //             quantity: 1,
    //             price: 170.00,
    //             image: 'image'),
    //       ].toList()),
    //   location: LatLng(33.38518474994279, 6.841680955607564),
    // ),
    // Client(
    //   name: 'Client4',
    //   city: 'city4',
    //   phone: '0123',
    //   stat: 1,
    //   total: '00.00',
    //   command: Command(
    //       paid: 0,
    //       date: DateTime.now(),
    //       nbProduct: 0,
    //       total: 0,
    //       products: [
    //         Product(
    //             id: 10.toString(),
    //             isChosen: true,
    //             total: 0,
    //             name: 'produit1',
    //             category: 'category1',
    //             quantity: 2,
    //             price: 120.00,
    //             image: 'image'),
    //         Product(
    //             id: 11.toString(),
    //             isChosen: true,
    //             total: 0,
    //             name: 'produit2',
    //             category: 'category2',
    //             quantity: 3,
    //             price: 420.00,
    //             image: 'image'),
    //         Product(
    //             id: 12.toString(),
    //             isChosen: true,
    //             total: 0,
    //             name: 'produit3',
    //             category: 'category3',
    //             quantity: 1,
    //             price: 170.00,
    //             image: 'image'),
    //       ].toList()),
    //   location: LatLng(33.39481372338867, 6.857192386619292),
    // ),
    // Client(
    //   name: 'Client5',
    //   city: 'city5',
    //   phone: '0123',
    //   stat: 1,
    //   total: '1500000.00',
    //   command: Command(
    //       paid: 0,
    //       date: DateTime.now(),
    //       nbProduct: 0,
    //       total: 0,
    //       products: [
    //         Product(
    //             id: 13.toString(),
    //             isChosen: true,
    //             total: 0,
    //             name: 'produit1',
    //             category: 'category1',
    //             quantity: 2,
    //             price: 120.00,
    //             image: 'image'),
    //         Product(
    //             id: 14.toString(),
    //             isChosen: true,
    //             total: 0,
    //             name: 'produit2',
    //             category: 'category2',
    //             quantity: 3,
    //             price: 420.00,
    //             image: 'image'),
    //         Product(
    //             id: 15.toString(),
    //             isChosen: true,
    //             total: 0,
    //             name: 'produit3',
    //             category: 'category3',
    //             quantity: 1,
    //             price: 170.00,
    //             image: 'image'),
    //       ].toList()),
    //   location: LatLng(33.39403066031248, 6.871912376401954),
    // ),
  ];

  List<Client> mapClients = [
    Client(
      name: 'Client1',
      city: 'city1',
      phone: '0123',
      stat: 1,
      total: '1500000.00',
    ),
    Client(
      name: 'Client2',
      city: 'city2',
      phone: '0123',
      stat: 2,
      total: '1500000.00',
    ),
    Client(
      name: 'Client3',
      city: 'city3',
      phone: '0123',
      stat: 2,
      total: '-90000.00',
    ),
    Client(
      name: 'Client4',
      city: 'city4',
      phone: '0123',
      stat: 1,
      total: '00.00',
    ),
    Client(
      name: 'Client5',
      city: 'city5',
      phone: '0123',
      stat: 1,
      total: '1500000.00',
    ),
  ];

  List<Client> getOppoByStat(int stat){
    return mapClientsWithCommands.where((client) => client.stat == stat).toList();
  }

  List<Client> get visitedClients =>
      mapClientsWithCommands.where((client) => client.stat == 2).toList();

  List<Client> get toVisitedClients =>
      mapClientsWithCommands.where((client) => client.stat == 1).toList();

  List<Client> get delivredClients =>
      mapClientsWithCommands.where((client) => client.stat == 3).toList();
  List<Client> get paymentedClients =>
      mapClientsWithCommands.where((client) => client.stat == 4).toList();
  List<Client> get delivredAndPaymentedClients =>
      mapClientsWithCommands.where((client) => client.stat == 5).toList();
  List<Client> get canceledClients =>
      mapClientsWithCommands.where((client) => client.stat == 6).toList();
  void updateList() {
    print('list updated');
    notifyListeners();
  }
}
