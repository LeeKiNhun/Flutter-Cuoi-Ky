import '../../../core/network/api_client.dart';
import '../dtos/transaction_dto.dart';

class TransactionApi {
  TransactionApi(this._client);

  final ApiClient _client;

  Future<List<TransactionDto>> fetchAll() async {
    final res = await _client.dio.get('/transactions');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(TransactionDto.fromJson).toList();
  }
}
