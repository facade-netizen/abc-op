import 'package:flutter/material.dart';

import '../../../model/casino_history_model.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/highlighted_text_widget.dart';
import 'show_casino_profit_details.dart';

class ExchangeHeaderCell extends StatelessWidget {
  const ExchangeHeaderCell({
    super.key,
    required this.title,
    this.flex = 1,
  });
  final String title;
  final int flex;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: HighlightText(
          title,
          textAlign: flex == 1 ? TextAlign.end : TextAlign.start,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: headerTextColor,
          ),
        ),
      ),
    );
  }
}

class CasinoTableHeader extends StatelessWidget {
  const CasinoTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 32,
      decoration: const BoxDecoration(
        color: headerRowColor,
        border: Border(
          bottom: BorderSide(color: borderColor),
          top: BorderSide(color: borderColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          ExchangeHeaderCell(flex: 4, title: 'Market'),
          ExchangeHeaderCell(title: 'Profit/Loss'),
        ],
      ),
    );
  }
}

/// Header config for Casino details
class CasinoPlDetailsHeader {
  final String label;
  final double flex;
  final bool alignRight;
  final String Function(GameReport report) valueGetter;
  final Color Function(GameReport report)? color;

  const CasinoPlDetailsHeader({
    required this.label,
    this.flex = 1,
    required this.valueGetter,
    this.alignRight = true,
    this.color,
  });
}

/// Define your details headers dynamically
List<CasinoPlDetailsHeader> casinoPlDetailsHeaders = [
  CasinoPlDetailsHeader(
    label: 'Platform',
    flex: 4,
    alignRight: false,
    valueGetter: (report) => report.name.isEmpty ? '-' : report.name,
    color: (report) => const Color(0xFF1A66CC),
  ),
  CasinoPlDetailsHeader(
    label: 'Valid Turnover',
    flex: 2,
    valueGetter: (report) => formattedAmounts(report.turnover),
  ),
  CasinoPlDetailsHeader(
    label: 'Win / Loss',
    flex: 2,
    valueGetter: (report) => formattedAmounts(report.pnl),
    color: (report) => report.pnl < 0 ? red : black,
  ),
  CasinoPlDetailsHeader(
    label: 'PT/Comm.',
    flex: 2,
    valueGetter: (report) => formattedAmounts(0),
  ),
  CasinoPlDetailsHeader(
    label: 'Profit/Loss',
    flex: 2,
    valueGetter: (report) => formattedAmounts(report.pnl),
    color: (report) => report.pnl < 0 ? red : black,
  ),
];

class CasinoPlDetails extends StatelessWidget {
  final List<GameReport> report;
  const CasinoPlDetails({required this.report, super.key});

  @override
  Widget build(BuildContext context) {
    if (report.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double leftSpacerWidth = availableWidth * 0.22;
        final double detailsWidth = (availableWidth - leftSpacerWidth - 2).clamp(0.0, double.infinity);
        final double grandTotalTurnover = report.fold(0.0, (sum, item) => sum + item.turnover);
        final double grandTotalPnl = report.fold(0.0, (sum, item) => sum + item.pnl);

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
                const VerticalDivider(
                  color: borderColor,
                  width: 2,
                ),
                SizedBox(
                  width: detailsWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8ED),
                          border: Border(bottom: BorderSide(color: borderColor)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: casinoPlDetailsHeaders.map((header) {
                              return Expanded(
                                flex: (header.flex * 10).toInt(),
                                child: Align(
                                  alignment: header.alignRight ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: HighlightText(
                                      header.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: headerTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      ...report.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final bool isOdd = index % 2 == 1;
                        final Color rowColor = isOdd ? const Color(0xFFE2E8ED) : const Color(0xFFF2F4F7);
                        final bool isLastItem = index == report.length - 1;

                        return Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: rowColor,
                            border: isLastItem ? Border(bottom: BorderSide(color: borderColor)) : null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              children: casinoPlDetailsHeaders.map((header) {
                                return Expanded(
                                  flex: (header.flex * 10).toInt(),
                                  child: Align(
                                    alignment: header.alignRight ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: InkWell(
                                        onTap: header.label == 'Platform'
                                            ? () {
                                                showCasinoProfitDetailsDialog(context, item);
                                              }
                                            : null,
                                        child: HighlightText(
                                          header.valueGetter(item),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: header.color != null ? header.color!(item) : black,
                                            decoration: header.label == 'Platform' ? TextDecoration.underline : TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      }),
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9E4EC),
                          border: Border(bottom: BorderSide(color: borderColor)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: (casinoPlDetailsHeaders[0].flex * 10).toInt(),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: HighlightText(
                                      'Grand Total',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: (casinoPlDetailsHeaders[1].flex * 10).toInt(),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: HighlightText(
                                      formattedAmounts(grandTotalTurnover),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: (casinoPlDetailsHeaders[2].flex * 10).toInt(),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: HighlightText(
                                      formattedAmounts(grandTotalPnl),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: grandTotalPnl < 0 ? red : black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: (casinoPlDetailsHeaders[3].flex * 10).toInt(),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: HighlightText(
                                      formattedAmounts(0),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: (casinoPlDetailsHeaders[4].flex * 10).toInt(),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: HighlightText(
                                      formattedAmounts(grandTotalPnl),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: grandTotalPnl < 0 ? red : black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
