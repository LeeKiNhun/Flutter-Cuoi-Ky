import '../models/category_entity.dart';
import '../remote/dtos/ai_suggest_request.dart';
import '../remote/dtos/ai_suggest_response.dart';
import '../remote/services/ai_api.dart';

class AiRepository {
  AiRepository(this._api);

  final AiApi _api;

  Future<AiSuggestResponse> suggestCategory({
    required int type,
    required String note,
    required List<CategoryEntity> categories,
  }) async {
    final req = AiSuggestRequest(
      type: type,
      note: note,
      categories: categories
          .map((c) => {'id': c.id, 'name': c.name})
          .toList(),
    );

    return _api.suggestCategory(req);
  }
}
