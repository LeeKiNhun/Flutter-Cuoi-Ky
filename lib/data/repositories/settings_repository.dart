import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../hive/boxes.dart';
import '../models/category_entity.dart';
import '../models/transaction_entity.dart';

class SettingsRepository {
  Box<CategoryEntity> get _catBox => Hive.box<CategoryEntity>(HiveBoxes.categories);
  Box<TransactionEntity> get _txBox => Hive.box<TransactionEntity>(HiveBoxes.transactions);

  Future<void> resetAll({required List<CategoryEntity> defaultCategories}) async {
    await _txBox.clear();
    await _catBox.clear();
    for (final c in defaultCategories) {
      await _catBox.put(c.id, c);
    }
  }

  Future<void> seedDemoData({
    required DateTime month,
    required List<CategoryEntity> expenseCategories,
    required List<CategoryEntity> incomeCategories,
    int count = 25,
  }) async {
    final rng = _SimpleRng(DateTime.now().millisecondsSinceEpoch);
    final uuid = const Uuid();

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    for (int i = 0; i < count; i++) {
      final isIncome = rng.nextInt(100) < 35; // ~35% income
      final type = isIncome ? 1 : 0;

      final day = 1 + rng.nextInt(daysInMonth);
      final date = DateTime(month.year, month.month, day, rng.nextInt(23), rng.nextInt(59));

      final catList = isIncome ? incomeCategories : expenseCategories;
      if (catList.isEmpty) continue;
      final cat = catList[rng.nextInt(catList.length)];

      final amountBase = isIncome ? 200000 : 50000;
      final amount = (amountBase + rng.nextInt(700000)).toDouble();

      final tx = TransactionEntity(
        id: uuid.v4(),
        type: type,
        amount: amount,
        categoryId: cat.id,
        date: date,
        note: isIncome ? 'Demo thu' : 'Demo chi',
      );

      await _txBox.put(tx.id, tx);
    }
  }
}

// RNG đơn giản để không cần dart:math (web build đôi khi ok, nhưng giữ gọn)
class _SimpleRng {
  int _state;
  _SimpleRng(this._state);

  int nextInt(int max) {
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return _state % max;
  }
}
