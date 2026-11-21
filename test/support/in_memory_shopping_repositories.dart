import 'package:handcart/features/shopping_list/data/models/product_model.dart';
import 'package:handcart/features/shopping_list/data/product_repository.dart';
import 'package:handcart/features/shopping_list/state/shopping_planner_controller.dart';
import 'package:handcart/features/stores/data/models/store_model.dart';
import 'package:handcart/features/stores/data/store_repository.dart';

ShoppingPlannerController createInMemoryPlannerController() {
  late final _InMemoryProductRepository productRepository;
  final storeRepository = _InMemoryStoreRepository(
    seedProducts: (products) => productRepository.seedIfEmpty(products),
    deleteProductsForStore: (storeId) =>
        productRepository.deleteForStore(storeId),
  );
  productRepository = _InMemoryProductRepository();

  return ShoppingPlannerController(
    storeRepository: storeRepository,
    productRepository: productRepository,
  );
}

class _InMemoryStoreRepository extends StoreRepository {
  _InMemoryStoreRepository({
    required this.seedProducts,
    required this.deleteProductsForStore,
  });

  final Future<void> Function(List<Product>) seedProducts;
  final Future<void> Function(String) deleteProductsForStore;
  final List<Store> _stores = [];

  @override
  Future<void> seedIfEmpty(List<Store> stores, List<Product> products) async {
    if (_stores.isEmpty) {
      _stores.addAll(stores);
      await seedProducts(products);
    }
  }

  @override
  Future<List<Store>> getAll() async => List.of(_stores);

  @override
  Future<void> insert(Store store) async {
    _stores.add(store);
  }

  @override
  Future<void> update(Store store) async {
    final index = _stores.indexWhere((item) => item.id == store.id);
    if (index == -1) throw StateError('Store ${store.id} does not exist.');
    _stores[index] = store;
  }

  @override
  Future<void> delete(String storeId) async {
    final existed = _stores.any((store) => store.id == storeId);
    _stores.removeWhere((store) => store.id == storeId);
    await deleteProductsForStore(storeId);
    if (!existed) throw StateError('Store $storeId does not exist.');
  }
}

class _InMemoryProductRepository extends ProductRepository {
  final List<Product> _products = [];
  final Map<String, int> _quantities = {};

  Future<void> seedIfEmpty(List<Product> products) async {
    if (_products.isNotEmpty) return;
    _products.addAll(products);
    for (final product in products) {
      _quantities[product.id] = 1;
    }
  }

  @override
  Future<List<Product>> getAll() async => List.of(_products);

  @override
  Future<Map<String, int>> getAllQuantities() async => Map.of(_quantities);

  @override
  Future<void> insert(Product product, {int quantity = 1}) async {
    _products.add(product);
    _quantities[product.id] = quantity;
  }

  @override
  Future<void> update(Product product) async {
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index == -1) throw StateError('Product ${product.id} does not exist.');
    _products[index] = product;
  }

  @override
  Future<void> delete(String productId) async {
    final existed = _products.any((product) => product.id == productId);
    _products.removeWhere((product) => product.id == productId);
    _quantities.remove(productId);
    if (!existed) throw StateError('Product $productId does not exist.');
  }

  Future<void> deleteForStore(String storeId) async {
    final removedIds = _products
        .where((product) => product.storeId == storeId)
        .map((product) => product.id)
        .toList();
    _products.removeWhere((product) => product.storeId == storeId);
    for (final id in removedIds) {
      _quantities.remove(id);
    }
  }

  @override
  Future<int> incrementQuantity(String productId) async {
    final quantity = _quantities[productId];
    if (quantity == null) {
      throw StateError('Product $productId does not exist.');
    }
    return _quantities[productId] = quantity + 1;
  }

  @override
  Future<int> decrementQuantity(String productId) async {
    final quantity = _quantities[productId];
    if (quantity == null) {
      throw StateError('Product $productId does not exist.');
    }
    return _quantities[productId] = quantity <= 1 ? 0 : quantity - 1;
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) async {
    if (!_quantities.containsKey(productId)) {
      throw StateError('Product $productId does not exist.');
    }
    _quantities[productId] = quantity < 0 ? 0 : quantity;
  }

  @override
  Future<void> clearStoreItems(String storeId) async {
    for (final product in _products.where((item) => item.storeId == storeId)) {
      _quantities[product.id] = 0;
    }
  }
}
