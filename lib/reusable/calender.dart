import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'colors.dart';
import 'sized_box_hw.dart';
import 'style.dart';

class PeriodFilterCard extends StatefulWidget {
  const PeriodFilterCard({
    super.key,
    required this.fromDateController,
    required this.toDateController,
  });

  final TextEditingController fromDateController;
  final TextEditingController toDateController;

  @override
  State<PeriodFilterCard> createState() => _PeriodFilterCardState();
}

class _PeriodFilterCardState extends State<PeriodFilterCard> {
  OverlayEntry? _overlayEntry;
  static const double cellWidth = 35;
  static const double totalWidth = cellWidth * 8 + 2;

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  int _weekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirst = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirst + firstDayOfYear.weekday) / 7).ceil();
  }

  void _swapFromTo(DateTime from, DateTime to) {
    widget.fromDateController.text = DateFormat('yyyy-MM-dd').format(from);
    widget.toDateController.text = DateFormat('yyyy-MM-dd').format(to);
  }

  Widget _cell(
    String text, {
    bool bold = false,
    Color? color,
    Color textColor = Colors.black,
  }) {
    return Container(
      width: cellWidth,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: textColor,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCalendar(
    DateTime selectedDate,
    int selectedYear,
    int selectedMonth,
    Function(DateTime) onDateSelected,
  ) {
    final today = DateTime.now();
    final lastDate = today;
    final minDate = today.subtract(const Duration(days: 60));

    final firstDayOfMonth = DateTime(selectedYear, selectedMonth, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final startDate = firstDayOfMonth.subtract(Duration(days: firstWeekday - 1));

    List<Widget> rows = [];

    rows.add(
      Container(
        width: totalWidth,
        color: Colors.grey.shade300,
        child: Row(
          children: [
            _cell("wk #", bold: true),
            ...["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map((d) => _cell(d, bold: true)),
          ],
        ),
      ),
    );

    for (int week = 0; week < 6; week++) {
      final weekStart = startDate.add(Duration(days: week * 7));
      final weekNum = _weekNumber(weekStart);

      rows.add(
        Row(
          children: [
            _cell(weekNum.toString(), bold: true),
            ...List.generate(7, (day) {
              final currentDay = weekStart.add(Duration(days: day));

              final isCurrentMonth = currentDay.month == selectedMonth && currentDay.year == selectedYear;

              //hide prev/next month dates
              if (!isCurrentMonth) {
                return _cell('', color: Colors.white, textColor: Colors.transparent);
              }

              final isSelected = currentDay.year == selectedDate.year && currentDay.month == selectedDate.month && currentDay.day == selectedDate.day;

              final isFuture = currentDay.isAfter(lastDate);
              final isPastLimit = currentDay.isBefore(minDate);

              //final textColor = (isFuture || isPastLimit) ? Colors.grey : Colors.black;
              Color textColor = Colors.black;
              if (day == 5) textColor = Colors.blue;
              if (day == 6) textColor = Colors.red;
              if (isFuture || isPastLimit) {
                textColor = Colors.grey;
              }
              return InkWell(
                onTap: (isFuture || isPastLimit)
                    ? null
                    : () {
                        onDateSelected(currentDay);
                        _removeOverlay();
                      },
                child: _cell(
                  currentDay.day.toString(),
                  color: isFuture || isPastLimit
                      ? Color(0xFFEEEEEE)
                      : isSelected
                          ? Colors.amber
                          : isCurrentMonth
                              ? Colors.white
                              : Colors.grey.shade200,
                  textColor: textColor,
                ),
              );
            }),
          ],
        ),
      );
    }

    return Column(children: rows);
  }

  void _showOverlay(
    BuildContext context,
    GlobalKey triggerKey,
    DateTime initialDate,
    Function(DateTime?) onDateSelected,
  ) {
    final renderBox = triggerKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    //persistent state using ValueNotifier (no reset issue)
    final selectedDateNotifier = ValueNotifier<DateTime>(initialDate);
    final selectedYearNotifier = ValueNotifier<int>(initialDate.year);
    final selectedMonthNotifier = ValueNotifier<int>(initialDate.month);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return GestureDetector(
          // onTap: _removeOverlay,
          child: Stack(
            children: [
              Positioned.fill(child: Container(color: Colors.transparent)),
              Positioned(
                left: position.dx,
                top: position.dy - 75,
                child: Material(
                  elevation: 8,
                  child: ValueListenableBuilder(
                    valueListenable: selectedMonthNotifier,
                    builder: (context, _, __) {
                      return ValueListenableBuilder(
                        valueListenable: selectedYearNotifier,
                        builder: (context, __, ___) {
                          return ValueListenableBuilder(
                            valueListenable: selectedDateNotifier,
                            builder: (context, selectedDate, ____) {
                              final selectedYear = selectedYearNotifier.value;
                              final selectedMonth = selectedMonthNotifier.value;

                              return Container(
                                width: totalWidth,
                                decoration: BoxDecoration(
                                  color: white,
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // HEADER
                                    Container(
                                      height: 50,
                                      width: totalWidth,
                                      color: tileOrFontColor,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.arrow_left, color: Colors.white),
                                            onPressed: () {
                                              if (selectedMonth == 1) {
                                                selectedMonthNotifier.value = 12;
                                                selectedYearNotifier.value--;
                                              } else {
                                                selectedMonthNotifier.value--;
                                              }
                                            },
                                          ),
                                          Row(
                                            children: [
                                              MenuAnchor(
                                                style: MenuStyle(
                                                  backgroundColor: WidgetStateProperty.all(white),
                                                  side: WidgetStateProperty.all(BorderSide(color: black, width: 0.5)),
                                                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
                                                ),
                                                builder: (context, controller, child) {
                                                  return InkWell(
                                                    onTap: () => controller.isOpen ? controller.close() : controller.open(),
                                                    child: Container(
                                                      width: 80,
                                                      height: 28,
                                                      alignment: Alignment.center,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.grey),
                                                        color: Colors.white,
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Text('$selectedYear'),
                                                            Icon(Icons.arrow_drop_down, color: black),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                menuChildren: List.generate(
                                                  3,
                                                  (i) => DateTime.now().year - 1 + i,
                                                ).map((year) {
                                                  return SizedBox(
                                                    width: 80,
                                                    height: 28,
                                                    child: MenuItemButton(
                                                      onPressed: () {
                                                        selectedYearNotifier.value = year;
                                                      },
                                                      child: Text('$year', style: TextStyle(color: black)),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                              wb4,
                                              MenuAnchor(
                                                style: MenuStyle(
                                                  backgroundColor: WidgetStateProperty.all(white),
                                                  side: WidgetStateProperty.all(BorderSide(color: black, width: 0.5)),
                                                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
                                                ),
                                                builder: (context, controller, child) {
                                                  return InkWell(
                                                    onTap: () => controller.isOpen ? controller.close() : controller.open(),
                                                    child: Container(
                                                      width: 100,
                                                      height: 28,
                                                      alignment: Alignment.center,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.grey),
                                                        color: Colors.white,
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Text(DateFormat.MMM().format(DateTime(0, selectedMonth))),
                                                            Icon(Icons.arrow_drop_down, color: black),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                menuChildren: List.generate(12, (i) => i + 1).map((m) {
                                                  return SizedBox(
                                                    width: 100,
                                                    height: 28,
                                                    child: MenuItemButton(
                                                      onPressed: () {
                                                        selectedMonthNotifier.value = m;
                                                      },
                                                      child: Text(
                                                        DateFormat.MMM().format(DateTime(0, m)),
                                                        style: TextStyle(color: black),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.arrow_right, color: Colors.white),
                                            onPressed: () {
                                              if (selectedMonth == 12) {
                                                selectedMonthNotifier.value = 1;
                                                selectedYearNotifier.value++;
                                              } else {
                                                selectedMonthNotifier.value++;
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),

                                    // CALENDAR
                                    _buildCalendar(
                                      selectedDate,
                                      selectedYear,
                                      selectedMonth,
                                      (date) {
                                        selectedDateNotifier.value = date;
                                        onDateSelected(date);
                                      },
                                    ),

                                    // BUTTONS
                                    Container(
                                      width: totalWidth,
                                      decoration: BoxDecoration(
                                        border: Border(top: BorderSide(color: Colors.grey.shade300)),
                                      ),
                                      padding: EdgeInsets.all(4),
                                      child: Row(
                                        spacing: 5,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 80,
                                            height: 25,
                                            child: CustomOutlineButton(
                                              action: () {
                                                onDateSelected(null);
                                                _removeOverlay();
                                              },
                                              title: 'Clear',
                                            ),
                                          ),
                                          Expanded(
                                            child: SizedBox(
                                              height: 25,
                                              child: CustomOutlineButton(
                                                action: () {
                                                  final today = DateTime.now();
                                                  onDateSelected(today);
                                                  _removeOverlay();
                                                },
                                                title: 'Today',
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 80,
                                            height: 25,
                                            child: CustomOutlineButton(
                                              action: _removeOverlay,
                                              title: 'Close',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();
    final fiveDaysBefore = today.subtract(const Duration(days: 5));

    if (widget.fromDateController.text.isEmpty) {
      widget.fromDateController.text = DateFormat('yyyy-MM-dd').format(fiveDaysBefore);
    }

    if (widget.toDateController.text.isEmpty) {
      widget.toDateController.text = DateFormat('yyyy-MM-dd').format(today);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  final fromKey = GlobalKey();
  final toKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text("Period"),
        Wrap(
          children: [
            DateBox(
              key: fromKey,
              controller: widget.fromDateController,
              inputFormatters: [DateInputFormatter(isFromDate: true)],
              onTap: () {
                _showOverlay(context, fromKey, DateTime.now(), (date) {
                  if (date != null) {
                    final toText = widget.toDateController.text;

                    if (toText.isNotEmpty) {
                      final toDate = DateFormat('yyyy-MM-dd').parse(toText);
                      // if from > to → SWAP
                      if (date.isAfter(toDate)) {
                        _swapFromTo(toDate, date);
                        return;
                      }
                    }

                    widget.fromDateController.text = DateFormat('yyyy-MM-dd').format(date);
                  }
                });
              },
            ),
            wb4,
            Container(
              decoration: BoxDecoration(
                color: white.withValues(alpha: 0.5),
                border: Border.all(color: grey, width: 1),
                borderRadius: BorderRadius.circular(5),
              ),
              height: 30,
              width: 50,
              child: const Center(
                child: Text(
                  '09:00',
                  style: TextStyle(fontSize: 13, color: grey),
                ),
              ),
            ),
          ],
        ),
        const Text("to"),
        Wrap(
          children: [
            DateBox(
              key: toKey,
              controller: widget.toDateController,
              inputFormatters: [DateInputFormatter(isFromDate: false)],
              onTap: () {
                _showOverlay(context, toKey, DateTime.now(), (date) {
                  if (date != null) {
                    final fromText = widget.fromDateController.text;
                    if (fromText.isNotEmpty) {
                      final fromDate = DateFormat('yyyy-MM-dd').parse(fromText);
                      // if to < from → SWAP
                      if (date.isBefore(fromDate)) {
                        _swapFromTo(date, fromDate);
                        return;
                      }
                    }

                    widget.toDateController.text = DateFormat('yyyy-MM-dd').format(date);
                  }
                });
              },
            ),
            wb4,
            Container(
              decoration: BoxDecoration(
                color: white.withValues(alpha: 0.5),
                border: Border.all(color: grey, width: 1),
                borderRadius: BorderRadius.circular(5),
              ),
              height: 30,
              width: 50,
              child: const Center(
                child: Text(
                  '08:59',
                  style: TextStyle(fontSize: 13, color: grey),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CustomOutlineButton extends StatelessWidget {
  const CustomOutlineButton({
    super.key,
    this.action,
    required this.title,
  });
  final void Function()? action;
  final String title;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: action,
      style: ElevatedButton.styleFrom(
        backgroundColor: white,
        side: BorderSide(color: Color(0xFFC9C9C9)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: black)),
    );
  }
}

class DateBox extends StatelessWidget {
  final VoidCallback? onTap;
  final Color borderColor;
  final Color focusedColor;
  final double borderRadius;
  final double height;
  final double width;
  final double fontSize;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  const DateBox({
    super.key,
    this.onTap,
    this.borderColor = Colors.grey,
    this.focusedColor = Colors.black,
    this.borderRadius = 5,
    this.height = 30,
    this.width = 130,
    this.fontSize = 12,
    this.controller,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: inputFormatters,
        decoration: tfInputDecoration.copyWith(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          suffixIcon: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: Container(
                decoration: BoxDecoration(color: tileOrFontColor, borderRadius: BorderRadius.circular(3)),
                child: Icon(Icons.calendar_month, size: 15, color: white),
              ),
            ),
          ),
        ),
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  final bool isFromDate;

  DateInputFormatter({
    this.isFromDate = false,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) return newValue;

    if (!RegExp(r'^[0-9-]*$').hasMatch(text)) {
      return oldValue;
    }

    if (text.length > 10) {
      return oldValue;
    }

    if (text.length == 10) {
      try {
        final date = DateFormat('yyyy-MM-dd').parseStrict(text);

        final today = DateTime.now();
        final currentDay = DateTime(
          today.year,
          today.month,
          today.day,
        );

        // To Date aur From Date - future date not allowed
        if (date.isAfter(currentDay)) {
          return oldValue;
        }

        // From Date - not allow less than 60 days
        if (isFromDate) {
          final minDate = DateTime(
            currentDay.year,
            currentDay.month - 2,
            currentDay.day,
          );

          if (date.isBefore(minDate)) {
            return oldValue;
          }
        }

        return newValue;
      } catch (_) {
        return oldValue;
      }
    }

    return newValue;
  }
}

void validateAndSwapDates(
  TextEditingController from,
  TextEditingController to,
) {
  try {
    if (from.text.isEmpty || to.text.isEmpty) return;

    DateTime fromDate = DateFormat('yyyy-MM-dd').parseStrict(from.text);

    DateTime toDate = DateFormat('yyyy-MM-dd').parseStrict(to.text);

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    // From Date minimum = Today - 2 Months
    final minFromDate = DateTime(
      today.year,
      today.month - 2,
      today.day,
    );

    // Future dates not allowed
    if (fromDate.isAfter(today)) {
      fromDate = today;
    }

    if (toDate.isAfter(today)) {
      toDate = today;
    }

    // From Date cannot be older than 2 months
    if (fromDate.isBefore(minFromDate)) {
      fromDate = minFromDate;
    }

    // Always keep From <= To
    if (fromDate.isAfter(toDate)) {
      final temp = fromDate;
      fromDate = toDate;
      toDate = temp;
    }

    // After swap again check min range
    if (fromDate.isBefore(minFromDate)) {
      fromDate = minFromDate;
    }

    from.text = DateFormat('yyyy-MM-dd').format(fromDate);
    to.text = DateFormat('yyyy-MM-dd').format(toDate);
  } catch (_) {
    // Invalid date
  }
}
