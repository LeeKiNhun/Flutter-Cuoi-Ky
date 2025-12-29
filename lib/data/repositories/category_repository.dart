import 'package:hive/hive.dart';

import '../hive/boxes.dart';
import '../models/category_entity.dart';
import '../models/transaction_entity.dart';

class CategoryRepository {
  Box<CategoryEntity> get _catBox =>
      Hive.box<CategoryEntity>(HiveBoxes.categories);

  Box<TransactionEntity> get _txBox =>
      Hive.box<TransactionEntity>(HiveBoxes.transactions);

  /// Get all categories
  List<CategoryEntity> getAll() => _catBox.values.toList();

  /// Get categories by type
  /// type: 0 = expense, 1 = income
  List<CategoryEntity> getByType(int type) {
    return _catBox.values.where((c) => c.type == type).toList();
  }

  /// Get category by id (used in Edit Transaction)
  CategoryEntity? getById(String id) {
    return _catBox.get(id);
  }

  /// Add or update category
  Future<void> upsert(CategoryEntity category) async {
    await _catBox.put(category.id, category);
  }

  /// Check if category is used by any transaction
  bool isCategoryUsed(String categoryId) {
    for (final tx in _txBox.values) {
      if (tx.categoryId == categoryId) {
        return true;
      }
    }
    return false;
  }

  /// Delete category (caller must check isCategoryUsed first)
  Future<void> delete(String categoryId) async {
    await _catBox.delete(categoryId);
  }
}
