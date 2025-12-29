import 'package:hive/hive.dart';

import '../hive/boxes.dart';
import '../models/transaction_entity.dart';

class TransactionRepository {
  Box<TransactionEntity> get _box => Hive.box<TransactionEntity>(HiveBoxes.transactions);

  Future<void> upsert(TransactionEntity tx) async {
    await _box.put(tx.id, tx);
  }

  Future<void> deleteById(String id) async {
    await _box.delete(id);
  }

  TransactionEntity? getById(String id) => _box.get(id);

  List<TransactionEntity> getAll() => _box.values.toList();

  /// Returns transactions that fall within [month] (same year & month).
  List<TransactionEntity> getByMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1); // exclusive
    final all = _box.values;

    final result = <TransactionEntity>[];
    for (final tx in all) {
      final d = tx.date;
      if (!d.isBefore(start) && d.isBefore(end)) {
        result.add(tx);
      }
    }

    // sort newest first (optional)
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }
}
