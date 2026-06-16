enum DateFilterType {
  today,
  yesterday,
  last7Days,
  last30Days,
  last2Months,
  custom,
}

class DateRange {
  final DateTime from;
  final DateTime to;

  DateRange({required this.from, required this.to});
}

DateRange getDateRange(DateFilterType type) {
  final now = DateTime.now();

  switch (type) {
    case DateFilterType.today:
      return DateRange(from: now, to: now);

    case DateFilterType.yesterday:
      final y = now.subtract(const Duration(days: 1));
      return DateRange(from: y, to: y);

    case DateFilterType.last7Days:
      return DateRange(
        from: now.subtract(const Duration(days: 6)), // 7 days incl today
        to: now,
      );

    case DateFilterType.last30Days:
      return DateRange(
        from: now.subtract(const Duration(days: 29)), // 30 days incl today
        to: now,
      );

    case DateFilterType.last2Months:
      return DateRange(
        from: now.subtract(const Duration(days: 59)), // ~60 days incl today
        to: now,
      );

    case DateFilterType.custom:
      throw Exception("Use manual date selection for custom");
  }
}
