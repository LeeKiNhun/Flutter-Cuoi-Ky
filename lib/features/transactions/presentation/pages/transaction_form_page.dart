import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/models/category_entity.dart';
import '../../../../data/models/transaction_entity.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../state/transactions_vm.dart';
import '../widgets/category_picker_sheet.dart';
import '../../../stats/state/stats_vm.dart';
import '../../../ai/ai_vm.dart';
import '../../../settings/state/categories_vm.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key, this.editing});

  final TransactionEntity? editing;

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _uuid = const Uuid();

  int _type = 0; // 0 expense, 1 income
  DateTime _date = DateTime.now();
  CategoryEntity? _category;

  bool _saving = false;

  bool get _isValid {
    final amount = double.tryParse(_amountCtrl.text.trim());
    return amount != null && amount > 0 && _category != null && !_saving;
  }

  @override
  void initState() {
    super.initState();

    final e = widget.editing;
    if (e != null) {
      _type = e.type;
      _date = e.date;
      _amountCtrl.text = e.amount.toString();
      _noteCtrl.text = e.note;
    }

    // When editing: load selected category from repository
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final editing = widget.editing;

      // ensure CategoriesVm loaded for current type (important for AI + picker)
      context.read<CategoriesVm>().loadByType(_type);

      if (editing == null) return;

      final catRepo = context.read<CategoryRepository>();
      final cat = catRepo.getById(editing.categoryId);
      if (cat != null && mounted) {
        setState(() => _category = cat);
      }
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _pickCategory() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CategoryPickerSheet(
        type: _type,
        onSelected: (c) => setState(() => _category = c),
      ),
    );
  }

  void _pickDate() {
    DateTime temp = _date;

    showCupertinoModalPopup(
      context: context,
      builder: (popupContext) => Container(
        height: 320,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() => _date = temp);
                  Navigator.of(popupContext).pop(); // ✅ close popup only
                },
                child: const Text('Xong'),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _date,
                onDateTimeChanged: (d) => temp = d,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _suggestCategory() async {
    final aiVm = context.read<AiVm>();
    final catVm = context.read<CategoriesVm>();

    // ensure categories loaded for this type
    catVm.loadByType(_type);

    final id = await aiVm.suggestCategoryId(
      type: _type,
      note: _noteCtrl.text,
      categories: catVm.items,
    );

    if (!mounted) return;

    if (id == null) {
      await showCupertinoDialog(
        context: context,
        builder: (c) => CupertinoAlertDialog(
          title: const Text('AI'),
          content: const Text('Không gợi ý được danh mục. Hãy thử ghi chú rõ hơn.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(c).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final found = catVm.items.where((x) => x.id == id).toList();
    if (found.isNotEmpty) {
      setState(() => _category = found.first);
    }

    final reason = aiVm.lastReason ?? '';
    final conf = aiVm.lastConfidence;

    if (reason.isNotEmpty) {
      await showCupertinoDialog(
        context: context,
        builder: (c) => CupertinoAlertDialog(
          title: const Text('AI gợi ý'),
          content: Text(
            conf == null
                ? reason
                : '$reason\n\nĐộ tin cậy: ${(conf * 100).toStringAsFixed(0)}%',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(c).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_isValid) return;

    setState(() => _saving = true);

    try {
      final vm = context.read<TransactionsVm>();
      final amount = double.parse(_amountCtrl.text.trim());

      final tx = TransactionEntity(
        id: widget.editing?.id ?? _uuid.v4(),
        type: _type,
        amount: amount,
        categoryId: _category!.id,
        date: _date,
        note: _noteCtrl.text.trim(),
      );

      await vm.addOrUpdate(tx);

      // refresh stats for current selected month
      final statsVm = context.read<StatsVm>();
      await statsVm.loadMonth(statsVm.selectedMonth);

      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editing != null;
    final aiVm = context.watch<AiVm>();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(isEditing ? 'Chỉnh sửa giao dịch' : 'Thêm giao dịch'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isValid ? _save : null,
          child: _saving
              ? const CupertinoActivityIndicator()
              : Text(
                  'Lưu',
                  style: TextStyle(
                    color: _isValid
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey,
                  ),
                ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CupertinoSlidingSegmentedControl<int>(
              groupValue: _type,
              children: const {
                0: Text('Chi'),
                1: Text('Thu'),
              },
              onValueChanged: (v) async {
                if (v == null) return;
                setState(() {
                  _type = v;
                  _category = null; // reset because type changed
                });
                // load categories for new type (important for picker & AI)
                context.read<CategoriesVm>().loadByType(_type);
              },
            ),
            const SizedBox(height: 16),

            CupertinoTextField(
              controller: _amountCtrl,
              placeholder: 'Số tiền',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _pickCategory,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _category?.name ?? 'Chọn danh mục',
                  style: TextStyle(
                    fontSize: 16,
                    color: _category == null
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.label,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ✅ AI Suggest button
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: aiVm.busy ? null : _suggestCategory,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    aiVm.busy
                        ? const CupertinoActivityIndicator(radius: 8)
                        : const Icon(CupertinoIcons.sparkles, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      aiVm.busy ? 'Đang gợi ý...' : 'Gợi ý danh mục',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _pickDate,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_date.day}/${_date.month}/${_date.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),

            CupertinoTextField(
              controller: _noteCtrl,
              placeholder: 'Ghi chú (tùy chọn)',
            ),
          ],
        ),
      ),
    );
  }
}
