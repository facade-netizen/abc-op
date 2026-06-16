import 'package:flutter/material.dart';

import '../../../../reusable/colors.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/highlighted_text_widget.dart';

/// Global expansion manager using ValueNotifier
class ExpansionManager {
  static final ExpansionManager _instance = ExpansionManager._internal();
  factory ExpansionManager() => _instance;
  ExpansionManager._internal();

  final ValueNotifier<String?> _expandedTileId = ValueNotifier(null);

  ValueNotifier<String?> get expandedTileId => _expandedTileId;

  bool isExpanded(String id) => _expandedTileId.value == id;

  void toggle(String id) {
    if (_expandedTileId.value == id) {
      _expandedTileId.value = null;
    } else {
      _expandedTileId.value = id;
    }
  }

  void dispose() {
    _expandedTileId.dispose();
  }
}

// Modified GroupedBetTile
class GroupedBetTile<TDate, TEvent> extends StatefulWidget {
  const GroupedBetTile({
    super.key,
    required this.sportName,
    required this.dates,
    required this.getEvents,
    required this.getDate,
    required this.eventRowBuilder,
    this.expandedSectionBuilder,
    required this.tileType,
    this.sportAction,
  });
  final void Function()? sportAction;
  final String sportName;
  final List<TDate> dates;
  final List<TEvent> Function(TDate date) getEvents;
  final String Function(TDate date) getDate;
  final String tileType;

  final Widget Function(
    BuildContext context,
    TEvent event,
    bool isLastEventOfDate,
    bool isExpanded,
    void Function()? onExpandToggle,
  ) eventRowBuilder;

  final Widget? Function(
    BuildContext context,
    TEvent event,
    bool isExpanded,
  )? expandedSectionBuilder;

  @override
  State<GroupedBetTile<TDate, TEvent>> createState() => _GroupedBetTileState<TDate, TEvent>();
}

class _GroupedBetTileState<TDate, TEvent> extends State<GroupedBetTile<TDate, TEvent>> {
  static const double rowHeight = 40;
  static const double expandedHeight = 200; // Fixed expanded height

  late final ExpansionManager _expansionManager = ExpansionManager();

  String _getExpansionId(int globalIndex) => '${widget.tileType}_${widget.sportName}_${widget.hashCode}_$globalIndex';
  bool _isExpanded(int globalIndex) => _expansionManager.isExpanded(_getExpansionId(globalIndex));

  void _toggleExpansion(int globalIndex) {
    _expansionManager.toggle(_getExpansionId(globalIndex));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _expansionManager.expandedTileId,
      builder: (context, expandedId, _) {
        int dateColumnIndex = 0;

        return Container(
          color: white,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// SPORT NAME COLUMN
                InkWell(
                  onTap: widget.sportAction,
                  child: Container(
                    width: 150,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: borderColor),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: HighlightText(
                        widget.sportName,
                        style: const TextStyle(
                          color: blue,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: blue,
                        ),
                      ),
                    ),
                  ),
                ),

                /// DATE COLUMN
                Container(
                  width: 150,
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: borderColor),
                      right: BorderSide(color: borderColor),
                    ),
                  ),
                  child: Column(
                    children: widget.dates.map((date) {
                      final events = widget.getEvents(date);
                      double totalHeight = 0;

                      for (int i = 0; i < events.length; i++) {
                        final index = dateColumnIndex++;
                        totalHeight += rowHeight;

                        if (_isExpanded(index)) {
                          totalHeight += expandedHeight; // Add fixed expanded height
                        }
                      }

                      return Container(
                        height: totalHeight > 0 ? totalHeight : null,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: borderColor),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: HighlightText(
                            formattedDateFromISO(
                              widget.getDate(date),
                              formateForRiskTable: formateForRiskTable,
                            ),
                            style: const TextStyle(
                              color: black,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                /// EVENTS COLUMN
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (var date in widget.dates)
                          for (var eventIndex = 0; eventIndex < widget.getEvents(date).length; eventIndex++)
                            ..._buildEventRow(
                              date: date,
                              eventIndex: eventIndex,
                              events: widget.getEvents(date),
                            ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildEventRow({
    required TDate date,
    required int eventIndex,
    required List<TEvent> events,
  }) {
    final globalIndex = _getGlobalIndex(date, eventIndex);
    final event = events[eventIndex];
    final isLast = eventIndex == events.length - 1;
    final isExpanded = _isExpanded(globalIndex);

    return [
      /// EVENT ROW
      SizedBox(
        height: rowHeight,
        child: widget.eventRowBuilder(
          context,
          event,
          isLast,
          isExpanded,
          () => _toggleExpansion(globalIndex),
        ),
      ),

      /// EXPANDED SECTION - Fixed height 170
      if (isExpanded && widget.expandedSectionBuilder != null)
        SizedBox(
          height: expandedHeight, // Fixed height
          child: widget.expandedSectionBuilder!(
                context,
                event,
                isExpanded,
              ) ??
              const SizedBox.shrink(),
        ),
    ];
  }

  int _getGlobalIndex(TDate targetDate, int targetEventIndex) {
    int index = 0;
    for (var date in widget.dates) {
      final events = widget.getEvents(date);
      if (date == targetDate) {
        return index + targetEventIndex;
      }
      index += events.length;
    }
    return -1;
  }
}
