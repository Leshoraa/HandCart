import 'package:flutter/foundation.dart';

import '../../stores/data/models/store_model.dart';
import '../../stores/data/store_dummy_data.dart';
import '../../stores/data/store_repository.dart';
import '../data/models/product_model.dart';
import '../data/product_repository.dart';

class ShoppingPlannerController extends ChangeNotifier {
  ShoppingPlannerController({
    StoreRepository? storeRepository,
    ProductRepository? productRepository,
  }) : _storeRepository = storeRepository ?? StoreRepository(),
       _productRepository = productRepository ?? ProductRepository();

  final StoreRepository _storeRepository;
  final ProductRepository _productRepository;
  final List<Store> _stores = [];
  final List<Product> _products = [];
  final Map<String, int> _quantities = {};
  bool _isLoading = true;
  bool _hasLoaded = false;
  Future<void>? _loadingFuture;
  Object? _loadError;

  bool get isLoading => _isLoading;

  Object? get loadError => _loadError;

  Future<void> initialize() {
    final activeLoad = _loadingFuture;
    if (activeLoad != null) return activeLoad;
    if (_hasLoaded) return Future<void>.value();

    final loading = _loadData();
    _loadingFuture = loading;
    return loading;
  }

  Future<void> _loadData() async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      await _storeRepository.seedIfEmpty(
        StoreDummyData.initialStores,
        StoreDummyData.initialProducts,
      );
      final stores = await _storeRepository.getAll();
      final products = await _productRepository.getAll();
      final quantities = await _productRepository.getAllQuantities();

      _stores
        ..clear()
        ..addAll(stores);
      _products
        ..clear()
        ..addAll(products);
      _quantities
        ..clear()
        ..addAll(quantities);
      _hasLoaded = true;
    } catch (error) {
      _loadError = error;
    } finally {
      _isLoading = false;
      _loadingFuture = null;
      notifyListeners();
    }
  }

  List<Store> get stores => List.unmodifiable(_stores);

  List<Product> get products => List.unmodifiable(_products);

  List<Product> getProductsForStore(String storeId) {
    return _products.where((product) => product.storeId == storeId).toList();
  }

  int getProductQuantity(String productId) {
    if (!_products.any((product) => product.id == productId)) {
      return 0;
    }
    return _quantities[productId] ?? 0;
  }

  int getStoreItemCount(String storeId) {
    return getProductsForStore(
      storeId,
    ).fold<int>(0, (count, product) => count + getProductQuantity(product.id));
  }

  int getStoreDistinctItemCount(String storeId) {
    return getProductsForStore(storeId)
        .where((product) => getProductQuantity(product.id) > 0)
        .length;
  }

  double getStoreTotalPrice(String storeId) {
    return getProductsForStore(storeId).fold<double>(
      0,
      (total, product) =>
          total + product.price * getProductQuantity(product.id),
    );
  }

  double getTotalPlannedExpense() {
    return _products.fold<double>(
      0,
      (total, product) =>
          total + product.price * getProductQuantity(product.id),
    );
  }

  int getTotalPlannedCount() {
    return _products.fold<int>(
      0,
      (total, product) => total + getProductQuantity(product.id),
    );
  }

  Future<void> incrementQuantity(Product product) async {
    _requireProduct(product.id);
    final quantity = await _productRepository.incrementQuantity(product.id);
    _quantities[product.id] = quantity;
    notifyListeners();
  }

  Future<void> decrementQuantity(String productId) async {
    _requireProduct(productId);
    final quantity = await _productRepository.decrementQuantity(productId);
    _quantities[productId] = quantity;
    notifyListeners();
  }

  Future<void> updateProductQuantity(String productId, int newQuantity) async {
    _requireProduct(productId);
    final quantity = newQuantity <= 0 ? 0 : newQuantity;
    await _productRepository.updateQuantity(productId, quantity);
    _quantities[productId] = quantity;
    notifyListeners();
  }

  String getStoreNote(String storeId) {
    return _requireStore(storeId).note;
  }

  Future<void> updateStoreNote(String storeId, String note) async {
    final store = _requireStore(storeId);
    await updateStore(store.copyWith(note: note.trim()));
  }

  Future<void> addStore(Store store) async {
    await _storeRepository.insert(store);
    _stores.insert(0, store);
    notifyListeners();
  }

  Future<void> updateStore(Store updatedStore) async {
    _requireStore(updatedStore.id);
    await _storeRepository.update(updatedStore);
    final index = _stores.indexWhere((store) => store.id == updatedStore.id);
    _stores[index] = updatedStore;
    notifyListeners();
  }

  Future<void> togglePinStore(String storeId) async {
    final store = _requireStore(storeId);
    await updateStore(store.copyWith(isPinned: !store.isPinned));
  }

  Future<void> deleteStore(String storeId) async {
    _requireStore(storeId);
    await _storeRepository.delete(storeId);

    _stores.removeWhere((store) => store.id == storeId);
    final removedProducts = _products
        .where((product) => product.storeId == storeId)
        .map((product) => product.id)
        .toList();
    _products.removeWhere((product) => product.storeId == storeId);
    for (final productId in removedProducts) {
      _quantities.remove(productId);
    }
    notifyListeners();
  }

  Future<void> addProduct(Product product, {int quantity = 1}) async {
    if (quantity < 1) {
      throw ArgumentError.value(quantity, 'quantity', 'Must be at least 1.');
    }
    await _productRepository.insert(product, quantity: quantity);
    _products.insert(0, product);
    _quantities[product.id] = quantity;
    notifyListeners();
  }

  Future<void> updateProduct(Product updatedProduct) async {
    _requireProduct(updatedProduct.id);
    await _productRepository.update(updatedProduct);
    final index = _products.indexWhere(
      (product) => product.id == updatedProduct.id,
    );
    _products[index] = updatedProduct;
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    _requireProduct(productId);
    await _productRepository.delete(productId);
    _products.removeWhere((product) => product.id == productId);
    _quantities.remove(productId);
    notifyListeners();
  }

  Future<void> clearStoreItems(String storeId) async {
    _requireStore(storeId);
    await _productRepository.clearStoreItems(storeId);
    for (final product in getProductsForStore(storeId)) {
      _quantities[product.id] = 0;
    }
    notifyListeners();
  }

  Store _requireStore(String storeId) {
    return _stores.firstWhere(
      (store) => store.id == storeId,
      orElse: () => throw StateError('Store $storeId does not exist.'),
    );
  }

  void _requireProduct(String productId) {
    if (!_products.any((product) => product.id == productId)) {
      throw StateError('Product $productId does not exist.');
    }
  }
}
