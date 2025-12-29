import 'package:flutter/foundation.dart';

import '../../../data/models/category_entity.dart';
import '../../../data/repositories/category_repository.dart';

class CategoriesVm extends ChangeNotifier {
  CategoriesVm(this._repo);

  final CategoryRepository _repo;

  int _type = 0; // 0 expense, 1 income
  List<CategoryEntity> _items = [];

  int get type => _type;
  List<CategoryEntity> get items => _items;

  void loadByType(int type) {
    _type = type;
    _items = _repo.getByType(type);
    notifyListeners();
  }

  Future<void> add(CategoryEntity c) async {
    await _repo.upsert(c);
    loadByType(_type);
  }

  bool canDelete(String categoryId) {
    return !_repo.isCategoryUsed(categoryId);
  }

  Future<void> delete(String categoryId) async {
    await _repo.delete(categoryId);
    loadByType(_type);
  }
}
