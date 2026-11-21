import '../../../core/database/app_database.dart';
import '../../../core/utils/database_icon_data.dart';
import '../../shopping_list/data/models/product_model.dart';
import '../../shopping_list/data/product_repository.dart';
import 'models/store_model.dart';

class StoreRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  Future<List<Store>> getAll() async {
    final db = await _appDatabase.database;

    final rows = await db.query(
      'stores',
      orderBy: 'created_at DESC, rowid ASC',
    );

    return rows.map(_fromMap).toList();
  }

  Future<void> seedIfEmpty(List<Store> stores, List<Product> products) async {
    final db = await _appDatabase.database;

    await db.transaction((transaction) async {
      final existingStores = await transaction.query(
        'stores',
        columns: ['id'],
        limit: 1,
      );
      if (existingStores.isNotEmpty) {
        return;
      }

      final batch = transaction.batch();
      for (final store in stores) {
        batch.insert('stores', _toMap(store));
      }
      for (final product in products.reversed) {
        batch.insert('products', ProductRepository.toDatabaseMap(product));
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> insert(Store store) async {
    final db = await _appDatabase.database;

    await db.insert('stores', _toMap(store));
  }

  Future<void> update(Store store) async {
    final db = await _appDatabase.database;

    final updatedRows = await db.update(
      'stores',
      _toMap(store),
      where: 'id = ?',
      whereArgs: [store.id],
    );
    if (updatedRows == 0) {
      throw StateError('Store ${store.id} does not exist.');
    }
  }

  Future<void> delete(String storeId) async {
    final db = await _appDatabase.database;

    final deletedRows = await db.delete(
      'stores',
      where: 'id = ?',
      whereArgs: [storeId],
    );
    if (deletedRows == 0) {
      throw StateError('Store $storeId does not exist.');
    }
  }

  Map<String, dynamic> _toMap(Store store) {
    return {
      'id': store.id,
      'name': store.name,
      'category': store.category,
      'description': store.description,
      'icon_code_point': store.icon.codePoint,
      'icon_font_family': store.icon.fontFamily,
      'icon_font_package': store.icon.fontPackage,
      'image_url': store.imageUrl,
      'image_path': null,
      'note': store.note,
      'created_at': store.createdAt?.toIso8601String(),
      'is_pinned': store.isPinned ? 1 : 0,
    };
  }

  Store _fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      icon: DatabaseIconData.fromDatabase(map),
      imageUrl: map['image_url'] as String?,
      note: map['note'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      isPinned: (map['is_pinned'] as int? ?? 0) == 1,
    );
  }
}
