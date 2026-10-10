import 'package:flutter/foundation.dart';
import '../../stores/data/models/store_model.dart';
import '../../stores/data/store_dummy_data.dart';
import '../data/models/product_model.dart';

class ShoppingPlannerController extends ChangeNotifier {
  final List<Store> _stores = [];
  final List<Product> _products = [];
  final Map<String, int> _quantities = {};
  final Map<String, String> _storeNotes = {};

  ShoppingPlannerController() {
    _initData();
  }

  void _initData() {
    _stores.addAll(StoreDummyData.initialStores);
    _products.addAll(StoreDummyData.initialProducts);
    for (final store in _stores) {
      _storeNotes[store.id] = store.note;
    }
  }

  List<Store> get stores => List.unmodifiable(_stores);

  List<Product> get products => List.unmodifiable(_products);

  List<Product> getProductsForStore(String storeId) {
    return _products.where((p) => p.storeId == storeId).toList();
  }

  int getProductQuantity(String productId) {
    return _quantities[productId] ?? 0;
  }

  int getStoreItemCount(String storeId) {
    int count = 0;
    for (final product in getProductsForStore(storeId)) {
      count += getProductQuantity(product.id);
    }
    return count;
  }

  double getStoreTotalPrice(String storeId) {
    double total = 0.0;
    for (final product in getProductsForStore(storeId)) {
      final qty = getProductQuantity(product.id);
      total += product.price * qty;
    }
    return total;
  }

  double getTotalPlannedExpense() {
    double total = 0.0;
    for (final product in _products) {
      final qty = getProductQuantity(product.id);
      total += product.price * qty;
    }
    return total;
  }

  int getTotalPlannedCount() {
    int total = 0;
    for (final qty in _quantities.values) {
      total += qty;
    }
    return total;
  }

  void incrementQuantity(Product product) {
    final currentQty = _quantities[product.id] ?? 0;
    _quantities[product.id] = currentQty + 1;
    notifyListeners();
  }

  void decrementQuantity(String productId) {
    final currentQty = _quantities[productId] ?? 0;
    if (currentQty <= 1) {
      _quantities.remove(productId);
    } else {
      _quantities[productId] = currentQty - 1;
    }
    notifyListeners();
  }

  void updateProductQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      _quantities.remove(productId);
    } else {
      _quantities[productId] = newQuantity;
    }
    notifyListeners();
  }

  String getStoreNote(String storeId) {
    return _storeNotes[storeId] ?? '';
  }

  void updateStoreNote(String storeId, String note) {
    _storeNotes[storeId] = note.trim();
    notifyListeners();
  }

  void addStore(Store store) {
    _stores.insert(0, store);
    _storeNotes[store.id] = store.note;
    notifyListeners();
  }

  void updateStore(Store updatedStore) {
    final index = _stores.indexWhere((s) => s.id == updatedStore.id);
    if (index != -1) {
      _stores[index] = updatedStore;
      _storeNotes[updatedStore.id] = updatedStore.note;
      notifyListeners();
    }
  }

  void togglePinStore(String storeId) {
    final index = _stores.indexWhere((s) => s.id == storeId);
    if (index != -1) {
      final current = _stores[index];
      _stores[index] = current.copyWith(isPinned: !current.isPinned);
      notifyListeners();
    }
  }

  void deleteStore(String storeId) {
    _stores.removeWhere((s) => s.id == storeId);
    _storeNotes.remove(storeId);
    final storeProducts = getProductsForStore(storeId);
    for (final p in storeProducts) {
      _quantities.remove(p.id);
    }
    _products.removeWhere((p) => p.storeId == storeId);
    notifyListeners();
  }

  void addProduct(Product product) {
    _products.insert(0, product);
    notifyListeners();
  }

  void clearStoreItems(String storeId) {
    final storeProducts = getProductsForStore(storeId);
    for (final p in storeProducts) {
      _quantities.remove(p.id);
    }
    notifyListeners();
  }
}
