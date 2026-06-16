import 'package:flutter/material.dart';
import '../../../model/players_profit_and_loss_model.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/highlighted_text_widget.dart';

/// Header config for expanded details
class ExchangePlDetailsHeader {
  final String label;
  final double flex;
  final bool alignRight;
  final String Function(ResultBets order) valueGetter;
  final Color Function(ResultBets order)? color;

  const ExchangePlDetailsHeader({required this.label, this.flex = 1, required this.valueGetter, this.alignRight = true, this.color});
}

/// Define your details headers dynamically
List<ExchangePlDetailsHeader> exchangePlDetailsHeaders = [
  ExchangePlDetailsHeader(label: 'Bet ID', flex: 1, valueGetter: (order) => order.orderId.toString()),
  ExchangePlDetailsHeader(label: 'Selection', flex: 2, valueGetter: (order) => order.runnerName.toLowerCase().contains('adjustment') ? '-' : order.runnerName),
  ExchangePlDetailsHeader(label: 'Odds', flex: 1, valueGetter: (order) => order.bettingType == 1 ? '${order.line}/${order.price}' : '${order.price}'),
  ExchangePlDetailsHeader(label: 'Stake', flex: 1, valueGetter: (order) => formattedAmounts(order.stake)),
  ExchangePlDetailsHeader(
    label: 'Type',
    flex: 1,
    valueGetter: (order) {
      final bool isBack = order.side.toLowerCase().contains('back');
      return order.bettingType == 1 ? (isBack ? 'Yes' : 'No') : (isBack ? 'Back' : 'Lay');
    },
    color: (order) => order.side.toLowerCase() == 'back' ? backType : layType,
  ),
  ExchangePlDetailsHeader(label: 'Placed', flex: 2, valueGetter: (order) => formattedDate(order.timeStamp)),
  ExchangePlDetailsHeader(label: 'Result', flex: 2, valueGetter: (order) => order.runnerName.toLowerCase().contains('adjustment') ? order.result : ''),
  ExchangePlDetailsHeader(
    label: 'Profit/Loss',
    flex: 2,
    valueGetter: (order) => formattedAmounts(order.mtm),
    color: (order) => order.mtm < 0
        ? red
        : order.mtm == 0
        ? black
        : black,
  ),
];

class ExpandedPlDetails extends StatelessWidget {
  final ResultDetails? details;
  const ExpandedPlDetails({required this.details, super.key});

  @override
  Widget build(BuildContext context) {
    if (details == null) return const SizedBox.shrink();
    final bool isYesNoMarket = details!.orders.any((order) => order.bettingType == 1);
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
                      // Header Row
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8ED),
                          border: Border(bottom: BorderSide(color: borderColor)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: exchangePlDetailsHeaders.map((header) {
                              return Expanded(
                                flex: (header.flex * 10).toInt(),
                                child: Align(
                                  alignment: header.alignRight ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: HighlightText(
                                      header.label,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: headerTextColor),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      // Orders with alternating row colors
                      ...details!.orders.asMap().entries.map((entry) {
                        final index = entry.key;
                        final order = entry.value;
                        final bool isOdd = index % 2 == 1;
                        final Color rowColor = isOdd ? const Color(0xFFE2E8ED) : const Color(0xFFF2F4F7);
                        final bool isLastItem = index == details!.orders.length - 1;

                        return Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: rowColor,
                            border: isLastItem ? Border(bottom: BorderSide(color: borderColor)) : null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              children: exchangePlDetailsHeaders.map((header) {
                                return Expanded(
                                  flex: (header.flex * 10).toInt(),
                                  child: Align(
                                    alignment: header.alignRight ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: HighlightText(
                                        header.valueGetter(order),
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: header.color != null ? header.color!(order) : black),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      }),
                      // Totals Section
                      Container(
                        color: const Color(0xFFD9E4EC),
                        width: double.infinity,
                        child: Column(
                          children: [
                            _buildTotalsRow('Total Stakes', details!.totalStack),
                            _buildTotalsRow(isYesNoMarket ? 'Yes subtotal' : 'Back subtotal', details!.totalBack),
                            _buildTotalsRow(isYesNoMarket ? 'No subtotal' : 'Lay subtotal', details!.totalLay),
                            _buildTotalsRow('Market subtotal', details!.totalBack + details!.totalLay),
                            _buildTotalsRow('Commission', details!.totalCommission),
                            const Divider(height: 1, color: borderColor),
                            _buildTotalsRow('Net Market Total', details?.total ?? 0.0, isBold: true),
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

  Widget _buildTotalsRow(String label, double value, {bool isBold = false}) {
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
                style: TextStyle(color: value >= 0 ? black : red, fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
