import '../../../core/database/app_database.dart';
import '../../../core/utils/database_icon_data.dart';
import 'models/product_model.dart';

class ProductRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  static Map<String, dynamic> toDatabaseMap(
    Product product, {
    int quantity = 1,
  }) {
    return {
      'id': product.id,
      'store_id': product.storeId,
      'name': product.name,
      'category': product.category,
      'price': product.price,
      'description': product.description,
      'icon_code_point': product.icon.codePoint,
      'icon_font_family': product.icon.fontFamily,
      'icon_font_package': product.icon.fontPackage,
      'rating': product.rating,
      'image_url': product.imageUrl,
      'image_path': product.imagePath,
      'quantity': quantity,
    };
  }

  Future<List<Product>> getAll() async {
    final db = await _appDatabase.database;

    final rows = await db.query('products', orderBy: 'rowid DESC');

    return rows.map(fromDatabaseMap).toList();
  }

  Future<List<Product>> getByStore(String storeId) async {
    final db = await _appDatabase.database;

    final rows = await db.query(
      'products',
      where: 'store_id = ?',
      whereArgs: [storeId],
      orderBy: 'rowid DESC',
    );

    return rows.map(fromDatabaseMap).toList();
  }

  Future<void> insert(Product product, {int quantity = 1}) async {
    final db = await _appDatabase.database;

    await db.insert('products', toDatabaseMap(product, quantity: quantity));
  }

  Future<void> update(Product product) async {
    final db = await _appDatabase.database;

    final updatedRows = await db.update(
      'products',
      toDatabaseMap(product)..remove('quantity'),
      where: 'id = ?',
      whereArgs: [product.id],
    );
    if (updatedRows == 0) {
      throw StateError('Product ${product.id} does not exist.');
    }
  }

  Future<void> delete(String productId) async {
    final db = await _appDatabase.database;

    final deletedRows = await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );
    if (deletedRows == 0) {
      throw StateError('Product $productId does not exist.');
    }
  }

  Future<Map<String, int>> getAllQuantities() async {
    final db = await _appDatabase.database;

    final rows = await db.query('products', columns: ['id', 'quantity']);

    return {
      for (final row in rows) row['id'] as String: row['quantity'] as int,
    };
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final db = await _appDatabase.database;

    final updatedRows = await db.update(
      'products',
      {'quantity': quantity < 0 ? 0 : quantity},
      where: 'id = ?',
      whereArgs: [productId],
    );
    if (updatedRows == 0) {
      throw StateError('Product $productId does not exist.');
    }
  }

  Future<int> incrementQuantity(String productId) async {
    final db = await _appDatabase.database;

    return db.transaction((transaction) async {
      final updatedRows = await transaction.rawUpdate(
        'UPDATE products SET quantity = quantity + 1 WHERE id = ?',
        [productId],
      );
      if (updatedRows == 0) {
        throw StateError('Product $productId does not exist.');
      }
      final rows = await transaction.query(
        'products',
        columns: ['quantity'],
        where: 'id = ?',
        whereArgs: [productId],
      );
      return rows.single['quantity'] as int;
    });
  }

  Future<int> decrementQuantity(String productId) async {
    final db = await _appDatabase.database;

    return db.transaction((transaction) async {
      final updatedRows = await transaction.rawUpdate(
        'UPDATE products '
        'SET quantity = CASE WHEN quantity <= 1 THEN 0 ELSE quantity - 1 END '
        'WHERE id = ?',
        [productId],
      );
      if (updatedRows == 0) {
        throw StateError('Product $productId does not exist.');
      }
      final rows = await transaction.query(
        'products',
        columns: ['quantity'],
        where: 'id = ?',
        whereArgs: [productId],
      );
      return rows.single['quantity'] as int;
    });
  }

  Future<void> clearStoreItems(String storeId) async {
    final db = await _appDatabase.database;

    await db.update(
      'products',
      {'quantity': 0},
      where: 'store_id = ?',
      whereArgs: [storeId],
    );
  }

  static Product fromDatabaseMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      storeId: map['store_id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      description: map['description'] as String,
      icon: DatabaseIconData.fromDatabase(map),
      rating: (map['rating'] as num).toDouble(),
      imageUrl: map['image_url'] as String?,
      imagePath: map['image_path'] as String?,
    );
  }
}
