import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class ExpensePieChart extends StatefulWidget {
  const ExpensePieChart({
    super.key,
    required this.data,
    required this.getCategoryName,
  });

  /// key = categoryId, value = total amount
  final Map<String, double> data;

  /// categoryId -> display name
  final String Function(String categoryId) getCategoryName;

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int? _touchedIndex;
  Offset? _touchPos; // local position in chart widget

  String _money(double v) => NumberFormat.decimalPattern().format(v);

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text(
          'No expense data',
          style: TextStyle(color: CupertinoColors.systemGrey),
        ),
      );
    }

    final entries = widget.data.entries.toList();
    final total = entries.fold<double>(0, (s, e) => s + e.value);

    final colors = <Color>[
      CupertinoColors.systemRed,
      CupertinoColors.activeBlue,
      CupertinoColors.systemGreen,
      CupertinoColors.systemOrange,
      CupertinoColors.systemPurple,
      CupertinoColors.systemPink,
      CupertinoColors.systemTeal,
      CupertinoColors.systemIndigo,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        Widget tooltip() {
          final idx = _touchedIndex;
          final pos = _touchPos;
          if (idx == null || pos == null || idx < 0 || idx >= entries.length) {
            return const SizedBox.shrink();
          }

          final e = entries[idx];
          final name = widget.getCategoryName(e.key);
          final percent = total <= 0 ? 0 : (e.value / total * 100);

          // Clamp tooltip position to stay inside chart bounds
          const tipW = 190.0;
          const tipH = 64.0;
          final left = math.max(8.0, math.min(pos.dx - tipW / 2, w - tipW - 8.0));
          final top = math.max(8.0, math.min(pos.dy - tipH - 10, h - tipH - 8.0));

          return Positioned(
            left: left,
            top: top,
            child: Container(
              width: tipW,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: CupertinoColors.black.withOpacity(0.82),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: DefaultTextStyle(
                style: const TextStyle(color: CupertinoColors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_money(e.value)}  •  ${percent.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey2),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Stack(
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 42,
                sections: List.generate(entries.length, (i) {
                  final isTouched = _touchedIndex == i;
                  return PieChartSectionData(
                    value: entries[i].value,
                    title: '',
                    color: colors[i % colors.length],
                    radius: isTouched ? 78 : 70,
                  );
                }),
                pieTouchData: PieTouchData(
                  enabled: true,
                  mouseCursorResolver: (event, response) {
                    final idx = response?.touchedSection?.touchedSectionIndex;
                    if (idx == null) return SystemMouseCursors.basic;
                    return SystemMouseCursors.click;
                  },
                  touchCallback: (event, response) {
                    // event.localPosition có trên hover/tap/drag
                    final idx = response?.touchedSection?.touchedSectionIndex;

                    // Khi rời chart (exit) hoặc không chạm vào section -> clear
                    if (!event.isInterestedForInteractions || idx == null) {
                      if (_touchedIndex != null || _touchPos != null) {
                        setState(() {
                          _touchedIndex = null;
                          _touchPos = null;
                        });
                      }
                      return;
                    }

                    setState(() {
                      _touchedIndex = idx;
                      _touchPos = event.localPosition;
                    });
                  },
                ),
              ),
              swapAnimationDuration: const Duration(milliseconds: 250),
              swapAnimationCurve: Curves.easeOut,
            ),

            // Popup overlay (hover)
            tooltip(),
          ],
        );
      },
    );
  }
}
