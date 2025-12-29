import 'package:flutter/foundation.dart';

import '../../../data/models/transaction_entity.dart';
import '../../../data/repositories/transaction_repository.dart';

class StatsVm extends ChangeNotifier {
  StatsVm(this._txRepo) {
    loadMonth(DateTime.now());
  }

  final TransactionRepository _txRepo;

  DateTime _selectedMonth = DateTime.now();
  DateTime get selectedMonth => _selectedMonth;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double _totalIncome = 0;
  double _totalExpense = 0;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _totalIncome - _totalExpense;

  /// index 0 => day 1
  List<double> _dailyExpense = const [];
  List<double> _dailyIncome = const [];
  List<double> get dailyExpense => _dailyExpense;
  List<double> get dailyIncome => _dailyIncome;

  Future<void> loadMonth(DateTime month) async {
    _isLoading = true;
    notifyListeners();

    _selectedMonth = DateTime(month.year, month.month, 1);

    final items = _txRepo.getByMonth(_selectedMonth);
    _computeSummary(items);
    _computeDailyIncomeExpense(items);

    _isLoading = false;
    notifyListeners();
  }

  void nextMonth() =>
      loadMonth(DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1));
  void prevMonth() =>
      loadMonth(DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1));

  void _computeSummary(List<TransactionEntity> items) {
    double inc = 0;
    double exp = 0;

    for (final tx in items) {
      if (tx.type == 1) {
        inc += tx.amount;
      } else {
        exp += tx.amount;
      }
    }

    _totalIncome = inc;
    _totalExpense = exp;
  }

  void _computeDailyIncomeExpense(List<TransactionEntity> items) {
    final y = _selectedMonth.year;
    final m = _selectedMonth.month;
    final daysInMonth = DateTime(y, m + 1, 0).day;

    final income = List<double>.filled(daysInMonth, 0);
    final expense = List<double>.filled(daysInMonth, 0);

    for (final tx in items) {
      final d = tx.date;
      if (d.year != y || d.month != m) continue;

      final idx = d.day - 1;
      if (tx.type == 1) {
        income[idx] += tx.amount;
      } else {
        expense[idx] += tx.amount;
      }
    }

    _dailyIncome = income;
    _dailyExpense = expense;
  }
}
