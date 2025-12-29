import 'package:flutter/foundation.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/models/transaction_entity.dart';
import '../../../data/repositories/sync_repository.dart';
import '../../../data/repositories/transaction_repository.dart';

class DaySection {
  final DateTime day;
  final List<TransactionEntity> items;
  DaySection({required this.day, required this.items});
}

class TransactionsVm extends ChangeNotifier {
  TransactionsVm(this._repo, this._syncRepo) {
    loadMonth(DateTime.now());
  }

  final TransactionRepository _repo;
  final SyncRepository _syncRepo;

  DateTime _selectedMonth = DateTime.now();
  DateTime get selectedMonth => _selectedMonth;

  // ===== Filters =====
  String _query = '';
  int _typeFilter = -1; // -1 all, 0 expense, 1 income
  String? _categoryIdFilter; // null = all

  String get query => _query;
  int get typeFilter => _typeFilter;
  String? get categoryIdFilter => _categoryIdFilter;

  bool get hasActiveFilters => _typeFilter != -1 || _categoryIdFilter != null;
  bool get hasQuery => _query.trim().isNotEmpty;

  void setQuery(String value) {
    _query = value;
    _applySearchAndFilter();
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _applySearchAndFilter();
    notifyListeners();
  }

  /// type: -1 all, 0 expense, 1 income
  /// categoryId: null => all
  void setFilters({required int type, String? categoryId}) {
    _typeFilter = type;

    // All type -> reset category filter
    if (_typeFilter == -1) {
      _categoryIdFilter = null;
    } else {
      _categoryIdFilter = categoryId; // can be null (All categories)
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

  // ===== Data =====
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

  // ===== Actions =====
  Future<void> loadMonth(DateTime month) async {
    _isLoading = true;
    notifyListeners();

    // normalize to month start
    _selectedMonth = DateTime(month.year, month.month, 1);
    _rawMonthly = _repo.getByMonth(_selectedMonth);

    _applySearchAndFilter();

    _isLoading = false;
    notifyListeners();
  }

  /// Sync from server (if available) then reload current month.
  Future<void> syncAndReload() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _syncRepo.syncFromServer(); // ✅ dùng đúng repo + đúng method bạn đang có
      _rawMonthly = _repo.getByMonth(_selectedMonth);
      _applySearchAndFilter();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Auto sync after login/register.
  /// Alias cho syncAndReload nhưng nuốt lỗi để không làm fail flow login.
  Future<void> syncNow() async {
    try {
      await syncAndReload();
    } catch (e) {
      debugPrint('Auto sync failed: $e');
    }
  }

  Future<void> addOrUpdate(TransactionEntity tx) async {
    await _repo.upsert(tx);

    // Reload current selected month (spec: month đang xem refresh ngay)
    _rawMonthly = _repo.getByMonth(_selectedMonth);
    _applySearchAndFilter();
    notifyListeners();
  }

  Future<void> deleteById(String id) async {
    await _repo.deleteById(id);

    _rawMonthly = _repo.getByMonth(_selectedMonth);
    _applySearchAndFilter();
    notifyListeners();
  }

  void nextMonth() =>
      loadMonth(DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1));

  void prevMonth() =>
      loadMonth(DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1));

  // ===== Internals =====
  void _applySearchAndFilter() {
    Iterable<TransactionEntity> data = _rawMonthly;

    // Search note (case-insensitive)
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      data = data.where((t) => t.note.toLowerCase().contains(q));
    }

    // Type filter
    if (_typeFilter == 0 || _typeFilter == 1) {
      data = data.where((t) => t.type == _typeFilter);
    }

    // Category filter
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

    // Totals for whole month (not filtered list)
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
    final map = <DateTime, List<TransactionEntity>>{};

    for (final tx in _visible) {
      final key = MTDateUtils.dayKey(tx.date);
      (map[key] ??= []).add(tx);
    }

    final days = map.keys.toList()..sort((a, b) => b.compareTo(a));
    final sections = <DaySection>[];

    for (final day in days) {
      final items = map[day]!..sort((a, b) => b.date.compareTo(a.date));
      sections.add(DaySection(day: day, items: items));
    }

    _sections = sections;
  }
}
