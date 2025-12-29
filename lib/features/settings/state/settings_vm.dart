import 'package:flutter/foundation.dart';

import '../../../data/models/category_entity.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../stats/state/stats_vm.dart';
import '../../transactions/state/transactions_vm.dart';

class SettingsVm extends ChangeNotifier {
  SettingsVm(this._settingsRepo, this._catRepo);

  final SettingsRepository _settingsRepo;
  final CategoryRepository _catRepo;

  bool _busy = false;
  bool get busy => _busy;

  // Dùng lại defaults giống HiveInit (bạn có thể refactor chung sau)
  List<CategoryEntity> get defaultCategories => _catRepo.getAll(); 
  // NOTE: nếu bạn muốn “defaults cứng”, mình sẽ đưa hẳn list giống HiveInit.

  Future<void> seedDemo({
    required DateTime month,
    required TransactionsVm txVm,
    required StatsVm statsVm,
    int count = 25,
  }) async {
    _busy = true;
    notifyListeners();

    final expense = _catRepo.getByType(0);
    final income = _catRepo.getByType(1);

    await _settingsRepo.seedDemoData(
      month: month,
      expenseCategories: expense,
      incomeCategories: income,
      count: count,
    );

    await txVm.loadMonth(txVm.selectedMonth);
    await statsVm.loadMonth(statsVm.selectedMonth);

    _busy = false;
    notifyListeners();
  }

  Future<void> reset({
    required TransactionsVm txVm,
    required StatsVm statsVm,
    required List<CategoryEntity> defaults,
  }) async {
    _busy = true;
    notifyListeners();

    await _settingsRepo.resetAll(defaultCategories: defaults);

    await txVm.loadMonth(txVm.selectedMonth);
    await statsVm.loadMonth(statsVm.selectedMonth);

    _busy = false;
    notifyListeners();
  }
}
