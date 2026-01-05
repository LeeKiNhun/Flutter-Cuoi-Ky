import 'package:hive/hive.dart';

import '../hive/boxes.dart';
import '../models/category_entity.dart';
import '../models/transaction_entity.dart';

class CategoryRepository {
  Box<CategoryEntity> get _catBox =>
      Hive.box<CategoryEntity>(HiveBoxes.categories);

  Box<TransactionEntity> get _txBox =>
      Hive.box<TransactionEntity>(HiveBoxes.transactions);

  
  List<CategoryEntity> getAll() => _catBox.values.toList();


  List<CategoryEntity> getByType(int type) {
    return _catBox.values.where((c) => c.type == type).toList();
  }

  
  CategoryEntity? getById(String id) {
    return _catBox.get(id);
  }

  
  Future<void> upsert(CategoryEntity category) async {
    await _catBox.put(category.id, category);
  }

  
  bool isCategoryUsed(String categoryId) {
    for (final tx in _txBox.values) {
      if (tx.categoryId == categoryId) {
        return true;
      }
    }
    return false;
  }

  
  Future<void> delete(String categoryId) async {
    await _catBox.delete(categoryId);
  }
}
