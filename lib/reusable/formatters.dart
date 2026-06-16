import 'package:intl/intl.dart';

String stringDateToDateTimeString(String dateString, {bool startOfDay = true}) {
  // Parse the string to DateTime
  final date = DateTime.parse(dateString);

  // Format as "YYYY-MM-DD HH:MM:SS.SSS"
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  final time = startOfDay ? '00:00:00.000' : '23:59:59.999';

  return "$year-$month-$day $time";
}

String fromToDateTimeString(String dateString, {bool startOfDay = true}) {
  // Parse the string to DateTime
  final date = DateTime.parse(dateString);

  // Format as "YYYY-MM-DD HH:MM:SS.SSS"
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  if (startOfDay) {
    return "$year-$month-$day 09:00:00.000";
  }

  final nextDay = date.add(const Duration(days: 1));
  final nextYear = nextDay.year.toString().padLeft(4, '0');
  final nextMonth = nextDay.month.toString().padLeft(2, '0');
  final nextDayOfMonth = nextDay.day.toString().padLeft(2, '0');

  return "$nextYear-$nextMonth-$nextDayOfMonth 08:59:59.000";
}

String formatDateString(String dateStr, {bool endOfDay = false}) {
  // Parse the incoming string into DateTime
  DateTime date = DateTime.parse(dateStr);

  // If you want the end of the day, set time to 23:59:59
  if (endOfDay) {
    date = DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  // Format it into yyyy-MM-dd HH:mm:ss
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
}

String formattedDateFromISO(String? isoString, {DateFormat? formateForRiskTable}) {
  if (isoString == null || isoString.isEmpty) {
    return DateFormat("dd-MM-yyyy hh:mm:ss a").format(DateTime.now());
  }
  try {
    final dateTime = DateTime.parse(isoString).toLocal();
    final customFormat = formateForRiskTable ?? DateFormat("dd-MM-yyyy hh:mm:ss a");
    return customFormat.format(dateTime);
  } catch (e) {
    return "Invalid date format";
  }
}

final formateForRiskTable = DateFormat("yyyy-MM-dd");

String toNonEmptyString(dynamic value) {
  return (((value ?? "").toString().isEmpty || value.toString().toLowerCase().contains("null")) ? "-" : value.toString()).trim();
}

String formattedAmounts(double value) {
  final formatter = NumberFormat('#,##0.00');
  final formattedValue = formatter.format(value.abs());
  if (value < 0) {
    return '($formattedValue)';
  }
  return formattedValue;
}

String formattedOnlyDate(dynamic date) {
  if (date == null) return '-';

  try {
    DateTime dateTime;

    if (date is DateTime) {
      dateTime = date;
    } else {
      // Try ISO first (fastest & most common)
      try {
        dateTime = DateTime.parse(date.toString());
      } catch (_) {
        // Fallback formats
        final formats = ['M/d/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd', 'yyyy-MM-ddT', 'yyyy-MM-ddT', 'dd-MM-yyyy', 'dd/MM/yyyy'];

        DateTime? parsed;

        for (var format in formats) {
          try {
            parsed = DateFormat(format).parse(date.toString());
            break;
          } catch (_) {}
        }

        if (parsed == null) return date.toString();
        dateTime = parsed;
      }
    }

    return DateFormat('yyyy-MM-dd').format(dateTime);
  } catch (e) {
    return date.toString();
  }
}

String formatMinMaxValues({double? min, double? max}) {
  final formatter = NumberFormat('#,##0.00');

  final minStr = min != null ? formatter.format(min) : "";
  final maxStr = max != null ? formatter.format(max) : "";

  // Both null
  if (minStr.isEmpty && maxStr.isEmpty) return "";

  // Only one exists
  if (minStr.isEmpty) return maxStr;
  if (maxStr.isEmpty) return minStr;

  // Both exist
  return "$minStr / $maxStr";
}

String formattedDate(dynamic date) {
  if (date == null) return '-';

  try {
    String dateStr = date.toString().trim();

    if (dateStr.isEmpty) return '-';

    // If already in required format: yyyy-MM-dd HH:mm:ss
    if (RegExp(
      r'^\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}$',
    ).hasMatch(dateStr)) {
      return dateStr;
    }

    RegExpMatch? match;

    // --------------------------------------------------
    // 1. dd:MM:yyyy HH:mm:ss
    // Example: 28:04:2026 12:05:05
    // --------------------------------------------------
    match = RegExp(
      r'^(\d{2}):(\d{2}):(\d{4})\s(\d{2}:\d{2}:\d{2})$',
    ).firstMatch(dateStr);

    if (match != null) {
      return '${match.group(3)}-${match.group(2)}-${match.group(1)} ${match.group(4)}';
    }

    // --------------------------------------------------
    // 2. dd-MM-yyyy HH:mm:ss
    // Example: 28-04-2026 12:05:05
    // --------------------------------------------------
    match = RegExp(
      r'^(\d{2})-(\d{2})-(\d{4})\s(\d{2}:\d{2}:\d{2})$',
    ).firstMatch(dateStr);

    if (match != null) {
      return '${match.group(3)}-${match.group(2)}-${match.group(1)} ${match.group(4)}';
    }

    // --------------------------------------------------
    // 3. dd/MM/yyyy HH:mm:ss
    // Example: 28/04/2026 12:05:05
    // --------------------------------------------------
    match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})\s(\d{2}:\d{2}:\d{2})$').firstMatch(dateStr);

    if (match != null) {
      return '${match.group(3)}-${match.group(2)}-${match.group(1)} ${match.group(4)}';
    }

    // --------------------------------------------------
    // 4. dd.MM.yyyy HH:mm:ss
    // Example: 28.04.2026 12:05:05
    // --------------------------------------------------
    match = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})\s(\d{2}:\d{2}:\d{2})$').firstMatch(dateStr);

    if (match != null) {
      return '${match.group(3)}-${match.group(2)}-${match.group(1)} ${match.group(4)}';
    }

    // --------------------------------------------------
    // 5. MM/dd/yyyy h:mm:ss a
    // Example:
    // 4/25/2026 12:24:37 AM
    // 04/17/2026 9:47:04 PM
    // --------------------------------------------------
    match = RegExp(
      r'^(\d{1,2})\/(\d{1,2})\/(\d{4})\s(\d{1,2}):(\d{2}):(\d{2})\s?(AM|PM)?$',
      caseSensitive: false,
    ).firstMatch(dateStr);

    if (match != null) {
      String month = match.group(1)!.padLeft(2, '0');
      String day = match.group(2)!.padLeft(2, '0');
      String year = match.group(3)!;

      int hour = int.parse(match.group(4)!);
      String minute = match.group(5)!;
      String second = match.group(6)!;
      String? ampm = match.group(7);

      if (ampm != null) {
        if (ampm.toUpperCase() == 'PM' && hour < 12) {
          hour += 12;
        }
        if (ampm.toUpperCase() == 'AM' && hour == 12) {
          hour = 0;
        }
      }

      String finalHour = hour.toString().padLeft(2, '0');

      return '$year-$month-$day $finalHour:$minute:$second';
    }

    // --------------------------------------------------
    // 6. yyyy-MM-ddTHH:mm:ss
    // Example: 2026-04-28T12:05:05
    // --------------------------------------------------
    match = RegExp(r'^(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})').firstMatch(dateStr);

    if (match != null) {
      return '${match.group(1)} ${match.group(2)}';
    }

    // --------------------------------------------------
    // 7. yyyy-MM-ddTHH:mm:ss.SSS
    // Example: 2026-04-28T12:05:05.000
    // --------------------------------------------------
    match = RegExp(r'^(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})\.\d+').firstMatch(dateStr);

    if (match != null) {
      return '${match.group(1)} ${match.group(2)}';
    }

    // If no format matched, return original string
    return dateStr;
  } catch (e) {
    return date.toString();
  }
}
