import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

class DailyIncomeExpenseBarChart extends StatelessWidget {
  const DailyIncomeExpenseBarChart({
    super.key,
    required this.income,
    required this.expense,
  });

  final List<double> income;  // day1..n
  final List<double> expense; // day1..n

  String _formatK(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final n = income.length;
    if (n == 0 || expense.length != n) {
      return const Center(child: Text('Không có dữ liệu'));
    }

    final double maxY = [
      ...income,
      ...expense,
    ].fold<double>(0.0, (m, v) => v > m ? v : m);

    final double safeMaxY = maxY <= 0 ? 10.0 : maxY * 1.25;

    return Column(
      children: [
        const _Legend(),
        const SizedBox(height: 8),
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: safeMaxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: safeMaxY / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: CupertinoColors.systemGrey4.withOpacity(0.6),
                  strokeWidth: 0.7,
                  dashArray: [6, 6],
                ),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final day = group.x + 1;
                    final isIncome = rodIndex == 0;
                    final label = isIncome ? 'Thu' : 'Chi';
                    final value = rod.toY;

                    return BarTooltipItem(
                      'Day $day\n$label: ${value.toStringAsFixed(0)}',
                      const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),

              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    interval: safeMaxY / 4,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        _formatK(value),
                        style: const TextStyle(
                          fontSize: 10,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      final day = value.toInt() + 1;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '$day',
                          style: const TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(n, (i) {
                final inc = income[i];
                final exp = expense[i];

                return BarChartGroupData(
                  x: i,
                  barsSpace: 4,
                  barRods: [
                    // rodIndex 0 => income
                    BarChartRodData(
                      toY: inc,
                      width: 6,
                      color: inc > 0
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    // rodIndex 1 => expense
                    BarChartRodData(
                      toY: exp,
                      width: 6,
                      color: exp > 0
                          ? CupertinoColors.systemRed
                          : CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget dot(Color c) => Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)),
        );

    Text label(String t) => Text(
          t,
          style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
        );

    return Row(
      children: [
        dot(CupertinoColors.activeGreen),
        const SizedBox(width: 6),
        label('Thu'),
        const SizedBox(width: 14),
        dot(CupertinoColors.systemRed),
        const SizedBox(width: 6),
        label('Chi'),
      ],
    );
  }
}
