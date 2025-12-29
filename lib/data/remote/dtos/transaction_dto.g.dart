// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionDto _$TransactionDtoFromJson(Map<String, dynamic> json) =>
    TransactionDto(
      id: json['id'] as String,
      type: json['type'] as int,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      date: json['date'] as String,
      note: json['note'] as String,
    );

Map<String, dynamic> _$TransactionDtoToJson(TransactionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'categoryId': instance.categoryId,
      'date': instance.date,
      'note': instance.note,
    };
