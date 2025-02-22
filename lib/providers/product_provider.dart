import 'package:flutter/material.dart';
import 'package:mobilino_app/models/command.dart';
import 'package:mobilino_app/models/product.dart';

class ProductProvider extends ChangeNotifier {
  late List<Product> products;

  late List<Product> allProducts = [
    Product(
        id: 1.toString(),
        isChosen: false,
        name: 'produit1',
        category: 'category1',
        quantity: 0,
        price: 120.00,
        image: 'image',
        total: 0),
    Product(
        id: 2.toString(),
        isChosen: false,
        name: 'produit2',
        category: 'category2',
        quantity: 0,
        price: 420.00,
        image: 'image',
        total: 0),
    Product(
        id: 3.toString(),
        isChosen: false,
        name: 'produit3',
        category: 'category3',
        quantity: 0,
        price: 170.00,
        image: 'image',
        total: 0),
    Product(
        id: 4.toString(),
        isChosen: false,
        name: 'produit3',
        category: 'category3',
        quantity: 0,
        price: 170.00,
        image: 'image',
        total: 0),
    Product(
        id: 5.toString(),
        isChosen: false,
        name: 'produit3',
        category: 'category3',
        quantity: 0,
        price: 170.00,
        image: 'image',
        total: 0),
    Product(
        id: 6.toString(),
        isChosen: false,
        name: 'produit3',
        category: 'category3',
        quantity: 0,
        price: 170.00,
        image: 'image',
        total: 0),
  ].toList();

  late List<Product> filtredProducts = [];

  void incrementQuantity(Product product, Command command) {
      if (product.isChosen == false) {
        product.quantity = 0;
        product.isChosen = true;
        command.products.add(product);
      }

      product.quantity = product.quantity + 1;
      product.calculateTotal();
      command.calculateTotal();
      notifyListeners();
  }

  void decrementQuantity(Product product, Command command) {
    if (product.quantity > 1) {
      product.quantity = product.quantity - 1;
      product.calculateTotal();
      command.calculateTotal();
      notifyListeners();
    }
  }

  void addProduct(Product product, Command command) {
    product.quantity = 1;
    command.products.add(product);
    product.calculateTotal();
    command.calculateTotal();
    notifyListeners();
  }

  void removeProduct(Product product, Command command) {
    product.quantity = 0;
    command.products.remove(product);
    product.calculateTotal();
    command.calculateTotal();
    notifyListeners();
  }

  void incrementQuantityOnly(Product product) {
    product.quantity = product.quantity + 1;
    product.calculateTotal();
    notifyListeners();
  }

  void decrementQuantityOnley(Product product) {
    if (product.quantity > 0) {
      product.quantity = product.quantity - 1;
      product.calculateTotal();
      notifyListeners();
    }
  }

  void updayrList() {
    notifyListeners();
  }
}
