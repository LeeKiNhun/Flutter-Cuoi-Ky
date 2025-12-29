import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/date_utils.dart';
import '../../state/stats_vm.dart';
import '../widgets/daily_expense_bar_chart.dart';

class MonthlyStatsPage extends StatelessWidget {
  const MonthlyStatsPage({super.key});

  String _money(double v) => NumberFormat.decimalPattern().format(v);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StatsVm>();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(MTDateUtils.formatMonthTitle(vm.selectedMonth)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: vm.prevMonth,
          child: const Icon(CupertinoIcons.chevron_left),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: vm.nextMonth,
          child: const Icon(CupertinoIcons.chevron_right),
        ),
      ),
      child: SafeArea(
        child: vm.isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _SummaryCard(
                    income: vm.totalIncome,
                    expense: vm.totalExpense,
                    balance: vm.balance,
                    money: _money,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 260,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: CupertinoColors.systemGrey4.withOpacity(0.4)),
                    ),
                    child: DailyIncomeExpenseBarChart(income: vm.dailyIncome, expense: vm.dailyExpense),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Chi tiêu và thu nhập hàng ngày',
                    style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.income,
    required this.expense,
    required this.balance,
    required this.money,
  });

  final double income;
  final double expense;
  final double balance;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, double value, Color color) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: CupertinoColors.systemGrey)),
          Text(
            money(value),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      );
    }

    final balColor = balance >= 0 ? CupertinoColors.activeGreen : CupertinoColors.systemRed;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          row('Tổng thu', income, CupertinoColors.activeGreen),
          const SizedBox(height: 8),
          row('Tổng chi', expense, CupertinoColors.systemRed),
          const SizedBox(height: 10),
          Container(height: 0.5, color: CupertinoColors.systemGrey4.withOpacity(0.6)),
          const SizedBox(height: 10),
          row('Số dư', balance, balColor),
        ],
      ),
    );
  }
}
