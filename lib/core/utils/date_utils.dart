import 'package:intl/intl.dart';

class MTDateUtils {
  static DateTime monthStart(DateTime month) => DateTime(month.year, month.month, 1);
  static DateTime monthEndExclusive(DateTime month) => DateTime(month.year, month.month + 1, 1);

  static DateTime dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  static String formatDayHeader(DateTime d) {
    // iOS-ish: Mon, 23 Dec
    return DateFormat('EEE, dd MMM').format(d);
  }

  static String formatMonthTitle(DateTime m) => DateFormat('MMMM yyyy').format(m);
}
