import 'package:flutter/foundation.dart';

import '../../../data/models/category_entity.dart';
import '../../../data/repositories/ai_repository.dart';

class AiVm extends ChangeNotifier {
  AiVm(this._repo);

  final AiRepository _repo;

  bool _busy = false;
  bool get busy => _busy;

  String? _lastReason;
  String? get lastReason => _lastReason;

  double? _lastConfidence;
  double? get lastConfidence => _lastConfidence;

  Future<String?> suggestCategoryId({
    required int type,
    required String note,
    required List<CategoryEntity> categories,
  }) async {
    final trimmed = note.trim();
    if (trimmed.isEmpty) return null;
    if (categories.isEmpty) return null;

    _busy = true;
    notifyListeners();

    try {
      final res = await _repo.suggestCategory(
        type: type,
        note: trimmed,
        categories: categories,
      );

      _lastReason = res.reason;
      _lastConfidence = res.confidence;
      return res.categoryId;
    } catch (_) {
      _lastReason = null;
      _lastConfidence = null;
      return null;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
