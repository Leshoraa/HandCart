import 'package:flutter/foundation.dart';
import '../../home/data/models/product_model.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartController extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get totalCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get tax => subtotal * 0.11; // PPN 11%

  double get totalPrice => subtotal + tax;

  bool get isEmpty => _items.isEmpty;

  int getQuantity(String productId) {
    return _items[productId]?.quantity ?? 0;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id] = _items[product.id]!.copyWith(
        quantity: _items[product.id]!.quantity + 1,
      );
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId] = _items[productId]!.copyWith(
        quantity: _items[productId]!.quantity - 1,
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void deleteItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
