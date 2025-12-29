import '../../models/transaction_entity.dart';
import 'transaction_dto.dart';

extension TransactionDtoMapper on TransactionDto {
  TransactionEntity toEntity() => TransactionEntity(
        id: id,
        type: type,
        amount: amount,
        categoryId: categoryId,
        date: DateTime.parse(date),
        note: note,
      );
}

extension TransactionEntityMapper on TransactionEntity {
  TransactionDto toDto() => TransactionDto(
        id: id,
        type: type,
        amount: amount,
        categoryId: categoryId,
        date: date.toIso8601String(),
        note: note,
      );
}
