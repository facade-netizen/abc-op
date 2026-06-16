import 'package:flutter/material.dart';

import '../../../../model/racing_event_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/highlighted_text_widget.dart';

class HorseAndGreyhoundTable extends StatelessWidget {
  const HorseAndGreyhoundTable({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    final tableData = [];

    return Container(
      width: size.width * 0.4 - 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Section
          Container(
            color: tileOrFontColor,
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            child: HighlightText(
              "Horse Racing & Greyhound Racing",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),

          // Table Header
          Container(
            height: 26,
            color: const Color(0xFFCED5DA),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildHeaderCell('Type'),
                ),
                Expanded(
                  flex: 1,
                  child: _buildHeaderCell('Country'),
                ),
                Expanded(
                  flex: 2,
                  child: _buildHeaderCell('Events'),
                ),
                Expanded(
                  flex: 1,
                  child: _buildHeaderCell(
                    'Matched Amount',
                    alignRight: true,
                  ),
                ),
              ],
            ),
          ),

          // Table Body
          Container(
            color: white,
            height: 130,
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  tableData.isEmpty ? 5 : (tableData.length > 10 ? 10 : tableData.length),
                  (index) {
                    if (tableData.isEmpty) {
                      return _buildEmptyRow(index);
                    } else {
                      return _buildTableRow(tableData[index], index);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
    String title, {
    bool alignRight = false,
  }) {
    return Container(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: HighlightText(
        title,
        style: const TextStyle(
          color: black,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyRow(int index) {
    return Container(
      height: 26,
      decoration: BoxDecoration(
        color: white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: const Row(
        children: [
          Expanded(flex: 1, child: SizedBox()),
          Expanded(flex: 1, child: SizedBox()),
          Expanded(flex: 2, child: SizedBox()),
          Expanded(flex: 1, child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildTableRow(RacingEventData event, int index) {
    return Container(
      height: 26,
      decoration: BoxDecoration(
        color: white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Type Column
          Expanded(
            flex: 1,
            child: _buildTypeChip(event.type),
          ),

          // Country Column
          Expanded(
            flex: 1,
            child: HighlightText(
              event.country,
              style: const TextStyle(
                color: black,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          // Events Column
          Expanded(
            flex: 2,
            child: HighlightText(
              event.events,
              style: const TextStyle(
                color: black,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          // Matched Amount Column
          Expanded(
            flex: 1,
            child: HighlightText(
              formattedAmounts(event.matchedAmount),
              style: TextStyle(
                color: getAmountColor(event.matchedAmount),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final bool isHorseRacing = type.toLowerCase().contains('horse');

    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 3, bottom: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isHorseRacing ? Colors.orange.shade50 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isHorseRacing ? Colors.orange.shade200 : Colors.blue.shade200,
            width: 0.5,
          ),
        ),
        child: HighlightText(
          type,
          style: TextStyle(
            color: isHorseRacing ? Colors.orange.shade800 : Colors.blue.shade800,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Color getAmountColor(double amount) {
    if (amount >= 500000) {
      return Colors.green.shade700;
    } else if (amount >= 100000) {
      return Colors.blue.shade700;
    } else if (amount >= 50000) {
      return Colors.orange.shade700;
    }
    return Colors.grey.shade700;
  }
}
