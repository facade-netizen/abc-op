import 'package:flutter/material.dart';

import '../../../model/bet_list_model.dart';
import '../../../model/player_bet_history_model.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/highlighted_text_widget.dart';

/// Header config for expanded details
class BettingDetailsHeader {
  final String label;
  final double flex;
  final bool alignRight;
  final String Function(PlayerBetHistory bet) valueGetter;

  const BettingDetailsHeader({required this.label, this.flex = 1, required this.valueGetter, this.alignRight = true});
}

List<BettingDetailsHeader> bettingDetailsHeaders = [
  BettingDetailsHeader(label: 'Bet Taken', valueGetter: (bet) => formatDateString(bet.updatedTime)),
  BettingDetailsHeader(label: 'Odds Req.', valueGetter: (bet) => bet.bettingType == BettingType.line ? '${bet.line}/${bet.price}' : formattedAmounts(bet.price)),
  BettingDetailsHeader(label: 'Stake', valueGetter: (bet) => formattedAmounts(bet.stake)),
  BettingDetailsHeader(label: 'Liability', valueGetter: (bet) => bet.liability == 0 ? '-' : formattedAmounts(bet.liability)),
  BettingDetailsHeader(
    label: 'Odds Matched',
    valueGetter: (bet) => bet.filledPrice == 0
        ? '-'
        : bet.bettingType == BettingType.line
        ? '${bet.line}/${bet.filledPrice}'
        : formattedAmounts(bet.filledPrice),
  ),
];

class BettingHistoryDetails extends StatelessWidget {
  const BettingHistoryDetails({super.key, required this.bet});
  final PlayerBetHistory bet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double leftSpacerWidth = availableWidth * 0.3;
        final double detailsWidth = (availableWidth - leftSpacerWidth - 2).clamp(0.0, double.infinity);

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFe0e9ee),
            border: Border(
              top: BorderSide(color: borderColor),
              bottom: BorderSide(color: borderColor),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: leftSpacerWidth),
                VerticalDivider(color: borderColor, width: 2),
                SizedBox(
                  width: detailsWidth,
                  child: Column(
                    children: [
                      // Header Row
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8ED),
                          border: Border(bottom: BorderSide(color: borderColor)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Row(
                            children: bettingDetailsHeaders.map((header) {
                              return Expanded(
                                flex: (header.flex * 10).toInt(),
                                child: Align(
                                  alignment: header.alignRight ? Alignment.centerRight : Alignment.centerLeft,
                                  child: HighlightText(
                                    header.label,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: headerTextColor),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      // Data Row
                      Container(
                        height: 30,
                        color: const Color(0xFFF2F4F7),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Row(
                            children: bettingDetailsHeaders.map((header) {
                              return Expanded(
                                flex: (header.flex * 10).toInt(),
                                child: Align(
                                  alignment: header.alignRight ? Alignment.centerRight : Alignment.centerLeft,
                                  child: HighlightText(
                                    header.valueGetter(bet),
                                    style: const TextStyle(fontSize: 12, color: black, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
