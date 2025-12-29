import 'package:cuoi_ky/core/utils/app_theme_mode.dart';
import 'package:flutter/foundation.dart';

import '../../../data/models/category_entity.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../stats/state/stats_vm.dart';
import '../../transactions/state/transactions_vm.dart';

class SettingsVm extends ChangeNotifier {
  SettingsVm(this._settingsRepo, this._catRepo) {
    _loadTheme();
  }

  final SettingsRepository _settingsRepo;
  final CategoryRepository _catRepo;

  // ===== Theme =====
  AppThemeMode _themeMode = AppThemeMode.system;
  AppThemeMode get themeMode => _themeMode;

  Future<void> _loadTheme() async {
    final v = await _settingsRepo.getThemeMode();
    _themeMode = AppThemeModeX.fromString(v);
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _settingsRepo.setThemeMode(mode.toValue());
  }

  // ===== Busy =====
  bool _busy = false;
  bool get busy => _busy;

  List<CategoryEntity> get defaultCategories => _catRepo.getAll();

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
