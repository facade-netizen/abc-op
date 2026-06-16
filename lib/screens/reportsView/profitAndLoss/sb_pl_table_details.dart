import 'package:flutter/material.dart';

import '../../../model/sport_book_pl_model.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/highlighted_text_widget.dart';

/// Header config for SBPl details
class SBPlDetailsHeader {
  final String label;
  final double flex;
  final bool alignRight;
  final String Function(SportBookPlDetails details) valueGetter;
  final Color Function(SportBookPlDetails details)? color;

  const SBPlDetailsHeader({required this.label, this.flex = 1, required this.valueGetter, this.alignRight = true, this.color});
}

/// Define your details headers dynamically
List<SBPlDetailsHeader> sbPlDetailsHeaders = [
  SBPlDetailsHeader(label: 'Bet ID', flex: 1, valueGetter: (order) => order.id.toString()),
  SBPlDetailsHeader(label: 'Selection', flex: 2, valueGetter: (order) => order.runnerName),
  SBPlDetailsHeader(label: 'Odds', flex: 1, valueGetter: (order) => order.odds.toStringAsFixed(2)),
  SBPlDetailsHeader(label: 'Stake', flex: 1, valueGetter: (order) => formattedAmounts(order.debitAmount)),
  SBPlDetailsHeader(
    label: 'Type',
    flex: 1,
    valueGetter: (order) {
      final bool isBack = order.runnerType.toLowerCase().contains('back');
      return (isBack ? 'Back' : 'Lay');
    },
    color: (order) => order.runnerType.toLowerCase() == 'back' ? backType : layType,
  ),
  SBPlDetailsHeader(label: 'Placed', flex: 2, valueGetter: (order) => formattedDate(order.createdDate)),
  SBPlDetailsHeader(
    label: 'Result',
    flex: 2,
    valueGetter: (order) => order.requestType.toLowerCase() == 'voided'
        ? ''
        : order.pnl >= 0
        ? 'WIN'
        : 'LOSS',
  ),
  SBPlDetailsHeader(
    label: 'Profit/Loss',
    flex: 2,
    valueGetter: (order) => formattedAmounts(order.pnl),
    color: (order) => order.pnl < 0
        ? red
        : order.pnl == 0
        ? black
        : black,
  ),
];

class SBPlDetails extends StatelessWidget {
  final SportBookPlDetailsGroup details;
  const SBPlDetails({required this.details, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double leftSpacerWidth = availableWidth * 0.15;
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
                const VerticalDivider(color: borderColor, width: 2),
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
                            children: sbPlDetailsHeaders.map((header) {
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
                      ...details.orders.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final SportBookPlDetails order = entry.value;
                        return Container(
                          height: 30,
                          color: index.isEven ? const Color(0xFFF6F8FA) : const Color(0xFFFFFFFF),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              children: sbPlDetailsHeaders.map((header) {
                                return Expanded(
                                  flex: (header.flex * 10).toInt(),
                                  child: Align(
                                    alignment: header.alignRight ? Alignment.centerRight : Alignment.centerLeft,
                                    child: HighlightText(
                                      header.valueGetter(order),
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: header.color != null ? header.color!(order) : black),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      }),
                      Container(
                        color: const Color(0xFFD9E4EC),
                        width: double.infinity,
                        child: Column(
                          children: [
                            _buildTotalsRow('Total Stakes', details.totalStakes),
                            _buildTotalsRow('Back subtotal', details.totalBack, valueColor: details.totalBack < 0 ? red : black),
                            _buildTotalsRow('Market subtotal', details.total, valueColor: details.total < 0 ? red : black),
                            const Divider(height: 1, color: borderColor),
                            _buildTotalsRow('Net Market Total', details.netMarketTotal, valueColor: details.netMarketTotal < 0 ? red : black, isBold: true),
                          ],
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

  Widget _buildTotalsRow(String label, double value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 8),
          Expanded(
            flex: 2,
            child: HighlightText(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: black),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: HighlightText(
                formattedAmounts(value),
                style: TextStyle(color: valueColor ?? black, fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
