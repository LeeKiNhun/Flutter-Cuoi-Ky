import 'package:hive/hive.dart';

import 'boxes.dart';
import '../models/category_entity.dart';
import '../models/transaction_entity.dart';
import 'default_categories.dart';

class HiveInit {
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryEntityAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TransactionEntityAdapter());
    }

    await Hive.openBox<CategoryEntity>(HiveBoxes.categories);
    await Hive.openBox<TransactionEntity>(HiveBoxes.transactions);

    final categoriesBox = Hive.box<CategoryEntity>(HiveBoxes.categories);
    if (categoriesBox.isNotEmpty) return;

    for (final c in defaultCategories) {
      await categoriesBox.put(c.id, c);
    }
  }
}
