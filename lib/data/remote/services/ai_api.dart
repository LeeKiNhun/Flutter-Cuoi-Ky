import '../../../core/network/api_client.dart';
import '../dtos/ai_suggest_request.dart';
import '../dtos/ai_suggest_response.dart';

class AiApi {
  AiApi(this._client);

  final ApiClient _client;

  Future<AiSuggestResponse> suggestCategory(AiSuggestRequest req) async {
    final res = await _client.dio.post('/ai/suggest-category', data: req.toJson());
    return AiSuggestResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
