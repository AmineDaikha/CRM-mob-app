import 'package:equatable/equatable.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/product.dart';

class Command extends Equatable {
  String? id;
  DateTime date;
  double total = 0;
  double totalTVA = 0;
  double totalWitoutTaxes = 0;
  double paid = 0;
  int nbProduct = 0;
  bool confirm = false;
  String? type;
  String? deliver;
  Client? client;
  Map<String, dynamic>? res;
  List<Product> products = [
    // Product(
    //     id: 1.toString(),
    //     isChosen: true,
    //     total: 0,
    //     name: 'produit1',
    //     category: 'category1',
    //     quantity: 2,
    //     price: 120.00,
    //     image: 'image'),
    // Product(
    //     id: 2.toString(),
    //     isChosen: true,
    //     total: 0,
    //     name: 'produit2',
    //     category: 'category2',
    //     quantity: 3,
    //     price: 420.00,
    //     image: 'image'),
    // Product(
    //     id: 3.toString(),
    //     isChosen: true,
    //     total: 0,
    //     name: 'produit3',
    //     category: 'category3',
    //     quantity: 1,
    //     price: 170.00,
    //     image: 'image'),
  ];

  Command({
    this.id,
    required this.date,
    required this.total,
    required this.paid,
    required this.products,
    required this.nbProduct,
    this.type,
    this.deliver,
    this.res,
    this.client
  }) {
    this.nbProduct = products.length;
    if (total == 0) calculateTotal();
    //date = DateTime.now();
  }

  void calculateTotal() {
    print('nbProd: $nbProduct');
    total = 0;
    totalWitoutTaxes = 0;
    totalTVA = 0;
    for (Product product in products) {
      //total = total + (product.quantity * product.price);
      total = total + product.total;
      totalTVA = totalTVA + product.priceTVA!;
      totalWitoutTaxes = totalWitoutTaxes + product.totalWitoutTaxes!;
    }
    nbProduct = products.length;
  }

  Command copyClone() {
    List<Product> listProduct = [];
    for (Product product in products) {
      listProduct.add(product);
    }
    Command cmd = Command(
        date: date,
        total: total,
        paid: paid,
        products: listProduct,
        nbProduct: nbProduct);
    cmd.date = date;
    return cmd;
  }

  @override
  List<Object?> get props => [date, total, paid, products, nbProduct];
}
