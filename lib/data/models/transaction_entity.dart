/// SPEC (MoneyTrack MVP) - TransactionEntity
/// - Hive object stored in transactionsBox
/// - Fields: id, type(0 expense,1 income), amount(double), categoryId, date(DateTime), note(String)
/// - Use HiveType + HiveField annotations
/// - Provide copyWith for edit update
///
/// NOTE: Ensure unique typeId for TransactionEntity.
import 'package:hive/hive.dart';

part 'transaction_entity.g.dart';

@HiveType(typeId: 2)
class TransactionEntity {
  @HiveField(0)
  final String id;

  /// 0 = expense, 1 = income
  @HiveField(1)
  final int type;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String categoryId;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String note;

  const TransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.note,
  });

  TransactionEntity copyWith({
    int? type,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
  }) {
    return TransactionEntity(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
