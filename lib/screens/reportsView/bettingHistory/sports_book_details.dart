import 'package:flutter/material.dart';

import '../../../../model/sports_book_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/highlighted_text_widget.dart';
import '../profitAndLoss/profit_and_loss_widgets.dart';

class SportsBookDetailsHeader {
  final String label;
  final double flex;
  final bool alignRight;
  final String Function(SportsBookModel bet) valueGetter;

  const SportsBookDetailsHeader({required this.label, this.flex = 1, required this.valueGetter, this.alignRight = true});
}

List<SportsBookDetailsHeader> sportsBookDetailsHeaders({bool showResult = false}) {
  return [
    SportsBookDetailsHeader(label: 'Bet Taken', valueGetter: (bet) => formatDateString(bet.createdDate)),
    SportsBookDetailsHeader(label: 'Odds Req.', valueGetter: (bet) => bet.odds == 0 ? '-' : formattedAmounts(bet.odds)),
    SportsBookDetailsHeader(label: 'Stake', valueGetter: (bet) => bet.debitAmount == 0 ? '-' : formattedAmounts(bet.debitAmount)),
    SportsBookDetailsHeader(label: 'Liability', valueGetter: (bet) => bet.exposure == 0 ? '-' : formattedAmounts(bet.exposure)),
    SportsBookDetailsHeader(label: 'Odds Matched', valueGetter: (bet) => bet.odds == 0 ? '-' : formattedAmounts(bet.odds)),
    if (showResult) SportsBookDetailsHeader(label: 'Result', valueGetter: (bet) => bet.pnl >= 0 ? 'WIN' : 'LOSS'),
  ];
}

class SportsBookDetails extends StatelessWidget {
  const SportsBookDetails({super.key, required this.bet});
  final SportsBookModel bet;

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
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8ED),
                          border: Border(bottom: BorderSide(color: borderColor)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Row(
                            children: sportsBookDetailsHeaders(showResult: bet.status.toLowerCase() == 'settled').map((header) {
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
                      Container(
                        height: 30,
                        color: const Color(0xFFF2F4F7),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Row(
                            children: sportsBookDetailsHeaders(showResult: bet.status.toLowerCase() == 'settled').map((header) {
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

class BettingInfo extends StatelessWidget {
  const BettingInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12),
        Heading('Betting History enables you to review the bets you have placed.'),
        Heading('Specify the time period during which your bets were placed, the type of markets on which the bets were placed, and the sport.'),
        SizedBox(height: 4),
        Heading('Betting History is available online for the past 62 days.'),
        SizedBox(height: 4),
        Heading(
          'User can search up to 14 days records per query only. However, when querying Fancybet with the bet status set to voided, the maximum query period is limited to 2 days.',
        ),
      ],
    );
  }
}
