import 'package:flutter/foundation.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/models/transaction_entity.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/sync_repository.dart';


class DaySection {
  final DateTime day;
  final List<TransactionEntity> items;
  DaySection({required this.day, required this.items});
}

class TransactionsVm extends ChangeNotifier {
  TransactionsVm(this._repo,this._syncRepo) {
    loadMonth(DateTime.now());
  }

  final TransactionRepository _repo;
  final SyncRepository _syncRepo;
  Future<void> syncAndReload() async {
    await _syncRepo.syncFromServer();
    await loadMonth(_selectedMonth);
  }
  
  DateTime _selectedMonth = DateTime.now();
  DateTime get selectedMonth => _selectedMonth;

  // Filters
String _query = '';
int _typeFilter = -1; // -1 all, 0 expense, 1 income
String? _categoryIdFilter; // null = all

String get query => _query;
int get typeFilter => _typeFilter;
String? get categoryIdFilter => _categoryIdFilter;

void setQuery(String value) {
  _query = value;
  _applySearchAndFilter();
  notifyListeners();
}

/// type: -1 all, 0 expense, 1 income
/// categoryId: null => all
void setFilters({required int type, String? categoryId}) {
  _typeFilter = type;

  // Nếu user chọn All type thì category filter cũng nên reset (đơn giản & đúng UX)
  if (_typeFilter == -1) {
    _categoryIdFilter = null;
  } else {
    // Với type cụ thể: cho phép categoryId null (All categories)
    _categoryIdFilter = categoryId;
  }

  _applySearchAndFilter();
  notifyListeners();
}

void clearFilters() {
  _typeFilter = -1;
  _categoryIdFilter = null;
  _applySearchAndFilter();
  notifyListeners();
}

  // Data
  List<TransactionEntity> _rawMonthly = [];
  List<TransactionEntity> _visible = [];

  List<DaySection> _sections = [];
  List<DaySection> get sections => _sections;

  double _totalIncome = 0;
  double _totalExpense = 0;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _totalIncome - _totalExpense;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadMonth(DateTime month) async {
    _isLoading = true;
    notifyListeners();

    _selectedMonth = DateTime(month.year, month.month, 1);
    _rawMonthly = _repo.getByMonth(_selectedMonth);

    _applySearchAndFilter();

    _isLoading = false;
    notifyListeners();
  }

  // void setQuery(String value) {
  //   _query = value;
  //   _applySearchAndFilter();
  //   notifyListeners();
  // }

  // void setFilters({int? type, String? categoryId, bool clearCategory = false}) {
  //   if (type != null) _typeFilter = type;
  //   if (clearCategory) _categoryIdFilter = null;
  //   if (!clearCategory) _categoryIdFilter = categoryId ?? _categoryIdFilter;
  //   _applySearchAndFilter();
  //   notifyListeners();
  // }

  Future<void> addOrUpdate(TransactionEntity tx) async {
    await _repo.upsert(tx);
    await loadMonth(_selectedMonth);
  }

  Future<void> deleteById(String id) async {
    await _repo.deleteById(id);
    await loadMonth(_selectedMonth);
  }

  void _applySearchAndFilter() {
    Iterable<TransactionEntity> data = _rawMonthly;

    // search note (case-insensitive)
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      data = data.where((t) => t.note.toLowerCase().contains(q));
    }

    // type filter
    if (_typeFilter == 0 || _typeFilter == 1) {
      data = data.where((t) => t.type == _typeFilter);
    }

    // category filter
    if (_categoryIdFilter != null) {
      data = data.where((t) => t.categoryId == _categoryIdFilter);
    }

    _visible = data.toList();

    _computeTotals();
    _buildSections();
  }

  void _computeTotals() {
    double income = 0;
    double expense = 0;

    // Totals should be for whole month (not only visible) OR visible?
    // Spec: header totals của tháng => use _rawMonthly
    for (final tx in _rawMonthly) {
      if (tx.type == 1) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }

    _totalIncome = income;
    _totalExpense = expense;
  }

  void _buildSections() {
    // Group based on _visible (because list is filtered/searched)
    final map = <DateTime, List<TransactionEntity>>{};
    for (final tx in _visible) {
      final key = MTDateUtils.dayKey(tx.date);
      (map[key] ??= []).add(tx);
    }

    final days = map.keys.toList()..sort((a, b) => b.compareTo(a)); // newest day first
    final sections = <DaySection>[];
    for (final day in days) {
      final items = map[day]!..sort((a, b) => b.date.compareTo(a.date));
      sections.add(DaySection(day: day, items: items));
    }
    _sections = sections;
  }

  void nextMonth() => loadMonth(DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1));
  void prevMonth() => loadMonth(DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1));
}
