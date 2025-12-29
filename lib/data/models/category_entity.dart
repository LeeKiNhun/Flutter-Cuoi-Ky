import 'package:hive/hive.dart';

part 'category_entity.g.dart';

@HiveType(typeId: 1)
class CategoryEntity {
  @HiveField(0)
  final String id;

  /// 0 = expense, 1 = income
  @HiveField(1)
  final int type;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final int iconCode;

  @HiveField(4)
  final int colorValue;

  const CategoryEntity({
    required this.id,
    required this.type,
    required this.name,
    required this.iconCode,
    required this.colorValue,
  });
}
