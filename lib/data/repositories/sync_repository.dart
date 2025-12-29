import '../../core/network/network_info.dart';
import '../remote/services/transaction_api.dart';
import 'transaction_repository.dart';
import '../remote/dtos/transaction_mapper.dart';

class SyncRepository {
  SyncRepository({
    required this.networkInfo,
    required this.api,
    required this.localRepo,
  });

  final NetworkInfo networkInfo; // ✅ đúng tên
  final TransactionApi api;
  final TransactionRepository localRepo;

  Future<void> syncFromServer() async {
    if (!await networkInfo.isConnected) return;

    final remote = await api.fetchAll();
    for (final dto in remote) {
      await localRepo.upsert(dto.toEntity());
    }
  }
}
