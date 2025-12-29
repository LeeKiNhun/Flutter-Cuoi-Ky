import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../data/models/transaction_entity.dart';
import '../../../stats/state/stats_vm.dart';
import '../../state/transactions_vm.dart';
import 'transaction_form_page.dart';
import '../widgets/filter_sheet.dart';


class TransactionsHomePage extends StatelessWidget {
  const TransactionsHomePage({super.key});

  String _formatMoney(double v) {
    final f = NumberFormat.decimalPattern();
    return f.format(v);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionsVm>();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(MTDateUtils.formatMonthTitle(vm.selectedMonth)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: vm.prevMonth,
          child: const Icon(CupertinoIcons.chevron_left),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const TransactionFormPage(),
                  ),
                );
              },
              child: const Icon(CupertinoIcons.add),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: vm.nextMonth,
              child: const Icon(CupertinoIcons.chevron_right),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _HeaderTotals(
              income: vm.totalIncome,
              expense: vm.totalExpense,
              balance: vm.balance,
              formatMoney: _formatMoney,
            ),
            Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoSearchTextField(
                    placeholder: 'Tìm kiếm...',
                    onChanged: vm.setQuery,
                  ),
                ),
                const SizedBox(width: 10),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    final result = await Navigator.of(context).push<TxFilterResult>(
                      CupertinoPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => FilterSheet(
                          initialType: vm.typeFilter,
                          initialCategoryId: vm.categoryIdFilter,
                        ),
                      ),
                    );

                    if (result != null) {
                      vm.setFilters(type: result.type, categoryId: result.categoryId);
                    }
                  },
                  child: Icon(
                    CupertinoIcons.line_horizontal_3_decrease_circle,
                    color: (vm.typeFilter != -1 || vm.categoryIdFilter != null)
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),

            Expanded(
              child: vm.isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : vm.sections.isEmpty
                      ? const _EmptyState()
                      : CupertinoScrollbar(
                          child: ListView.builder(
                            itemCount: vm.sections.length,
                            itemBuilder: (context, index) {
                              final section = vm.sections[index];
                              return _DaySection(
                                section: section,
                                formatMoney: _formatMoney,
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderTotals extends StatelessWidget {
  const _HeaderTotals({
    required this.income,
    required this.expense,
    required this.balance,
    required this.formatMoney,
  });

  final double income;
  final double expense;
  final double balance;
  final String Function(double) formatMoney;

  @override
  Widget build(BuildContext context) {
    Widget tile(String label, double value, Color color) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
              const SizedBox(height: 6),
              Text(
                formatMoney(value),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      );
    }

    final balColor = balance >= 0 ? CupertinoColors.activeGreen : CupertinoColors.systemRed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Row(
        children: [
          tile('Thu:', income, CupertinoColors.activeGreen),
          const SizedBox(width: 10),
          tile('Chi:', expense, CupertinoColors.systemRed),
          const SizedBox(width: 10),
          tile('Số dư:', balance, balColor),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({required this.section, required this.formatMoney});

  final DaySection section;
  final String Function(double) formatMoney;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MTDateUtils.formatDayHeader(section.day),
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.systemGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: CupertinoColors.systemGrey4.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                for (int i = 0; i < section.items.length; i++) ...[
                  _TxRow(tx: section.items[i], formatMoney: formatMoney),
                  if (i != section.items.length - 1)
                    Container(height: 0.5, color: CupertinoColors.systemGrey4.withOpacity(0.5)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  const _TxRow({required this.tx, required this.formatMoney});

  final TransactionEntity tx;
  final String Function(double) formatMoney;

  Future<bool> _showDeleteDialog(BuildContext context) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false), // ✅ close dialog
            child: const Text('Hủy'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true), // ✅ close dialog
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == 1;
    final color = isIncome ? CupertinoColors.activeGreen : CupertinoColors.systemRed;
    final sign = isIncome ? '+' : '-';
    final title = tx.note.trim().isNotEmpty ? tx.note : tx.categoryId;

    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,

      // ✅ CHỈ hỏi confirm ở đây, KHÔNG delete ở đây
      confirmDismiss: (_) => _showDeleteDialog(context),

      // ✅ delete sau khi dismiss confirmed
      onDismissed: (_) async {
        final vm = context.read<TransactionsVm>();
        final statsVm = context.read<StatsVm>();

        await vm.deleteById(tx.id);
        await statsVm.loadMonth(statsVm.selectedMonth);
      },

      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemRed,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white),
      ),

      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              fullscreenDialog: true,
              builder: (_) => TransactionFormPage(editing: tx),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(CupertinoIcons.tag, size: 18, color: CupertinoColors.systemGrey),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$sign${formatMoney(tx.amount)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Không có giao dịch nào.\nThêm một với +.',
        textAlign: TextAlign.center,
        style: TextStyle(color: CupertinoColors.systemGrey),
      ),
    );
  }
}
