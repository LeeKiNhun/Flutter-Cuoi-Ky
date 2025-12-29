import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../features/stats/state/stats_vm.dart';
import '../features/transactions/state/transactions_vm.dart';
import '../data/repositories/sync_repository.dart';

class AppBootstrap {
  static Future<void> init(BuildContext context) async {
    final syncRepo = context.read<SyncRepository>();
    final txVm = context.read<TransactionsVm>();
    final statsVm = context.read<StatsVm>();

    await syncRepo.syncFromServer();
    await txVm.loadMonth(txVm.selectedMonth);
    await statsVm.loadMonth(statsVm.selectedMonth);
  }
}
