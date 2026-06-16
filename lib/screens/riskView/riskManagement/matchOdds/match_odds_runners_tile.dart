import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../bloc/signalRBloc/protoUsage/receive/receive.pb.dart';
import '../../../../bloc/signalRBloc/signalRStreamers/odds_signalr_streamer.dart';
import '../../../../model/open_odds_bets_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/highlighted_text_widget.dart';
import '../../../../reusable/sized_box_hw.dart';
import '../../../../reusable/style.dart';

class MatchOddsRunnersDetails extends StatelessWidget {
  const MatchOddsRunnersDetails({super.key, required this.runners});
  final List<OddsRunner> runners;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      width: size.width,
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
            // Left spacer
            SizedBox(width: 41),
            const VerticalDivider(
              color: borderColor,
              width: 1,
            ),
            Expanded(
              child: Column(
                children: [
                  MatchOddsBLHeader(
                    selections: runners.length.toString(),
                  ),
                  ...runners.map((runner) => MatchOddsRunnersTile(runner: runner)),
                  hb20,
                ],
              ),
            ),
            const VerticalDivider(
              color: borderColor,
              width: 1,
            ),
            // Right spacer
            SizedBox(width: 80),
          ],
        ),
      ),
    );
  }
}

class MatchOddsRunnersTile extends StatefulWidget {
  const MatchOddsRunnersTile({
    super.key,
    required this.runner,
  });

  final OddsRunner runner;

  @override
  State<MatchOddsRunnersTile> createState() => _MatchOddsRunnersTileState();
}

class _MatchOddsRunnersTileState extends State<MatchOddsRunnersTile> {
  String? activeKey;
  bool? isBackActive;

  // Store previous data to compare prices
  Map<String, double> previousPrices = {};
  Map<String, Color> flashColors = {};

  // Store last valid runner
  AbcRunner? lastValidRunner;
  double? selectedOdds;

  void checkPriceChanges(List<ABCPrice> prices, String side) {
    for (int i = 0; i < prices.length; i++) {
      final price = prices[i];
      final key = '${widget.runner.runnerId}-$side-$i';
      final currentPrice = price.price.toDouble();

      if (previousPrices.containsKey(key)) {
        final prevPrice = previousPrices[key]!;
        if (currentPrice > prevPrice) {
          flashColors[key] = appYellow; // Price increased
        } else if (currentPrice < prevPrice) {
          flashColors[key] = cyan; // Price decreased
        }
      }

      previousPrices[key] = currentPrice;
    }

    // Clear flash
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => flashColors.clear());
      }
    });
  }

  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: isHovered ? highlightTileHover : white,
          border: Border(bottom: BorderSide(color: darkGreen, width: 0.5)),
        ),
        child: Row(
          children: [
            /// RUNNER NAME
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    const Icon(Icons.bar_chart, color: darkGreen, size: 18),
                    wb10,
                    Expanded(
                      child: HighlightText(
                        widget.runner.runnerName,
                        style: b14ts,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// ODDS PRICES
            BlocBuilder<OddsSignalRStreamerBloc, OddsSignalRStreamerState>(
              builder: (context, state) {
                AbcRunner? currentRunner;
                String runnerStatus = '';
                if (state is OddsSignalRStreamerSuccess) {
                  currentRunner = state.oddsData.runner.firstWhereOrNull((r) => r.runnerId == widget.runner.runnerId);

                  // Store valid runner
                  if (currentRunner != null) {
                    lastValidRunner = currentRunner;
                  }
                }

                // Use current runner or last valid one
                final runner = currentRunner ?? lastValidRunner;

                // Get prices
                List<ABCPrice> backs = List<ABCPrice>.from(runner?.backs ?? []);
                List<ABCPrice> lays = List<ABCPrice>.from(runner?.lays ?? []);

                // Ensure we have 3 price slots
                backs = getThreePrices(backs);
                lays = getThreePrices(lays);

                final bool backPricesZero = backs.any((e) => e.price == 0.0);
                final bool layPricesZero = lays.any((e) => e.price == 0.0);

                // Check for price changes
                if (runner != null) {
                  runnerStatus = runner.status.name;
                  checkPriceChanges(backs, 'BACK');
                  checkPriceChanges(lays, 'LAY');
                }

                return Stack(
                  children: [
                    Row(
                      children: [
                        /// BACK PRICES (3 buttons)
                        ...backs.asMap().entries.toList().reversed.map((entry) {
                          final index = entry.key;
                          final price = entry.value.price;
                          final size = entry.value.size;
                          final key = '${widget.runner.runnerId}-BACK-$index';
                          final hasPrice = price > 0;

                          return BackLayAllCTAButton(
                            title: hasPrice ? price.toString() : ' ',
                            value: hasPrice ? formattedAmounts(size.toDouble()) : ' ',
                            isFlash: flashColors.containsKey(key),
                            color: flashColors[key] ?? (applyOpacity(backBtn, getBackOpacity(index))),
                            active: hasPrice,
                            action: () {},
                          );
                        }),

                        /// LAY PRICES (3 buttons)
                        ...lays.asMap().entries.map((entry) {
                          final index = entry.key;
                          final price = entry.value.price;
                          final size = entry.value.size;
                          final key = '${widget.runner.runnerId}-LAY-$index';
                          final hasPrice = price > 0;

                          return BackLayAllCTAButton(
                            title: hasPrice ? price.toString() : ' ',
                            value: hasPrice ? formattedAmounts(size.toDouble()) : ' ',
                            isFlash: flashColors.containsKey(key),
                            color: flashColors[key] ?? applyOpacity(layBtn, getLayOpacity(index)),
                            active: hasPrice,
                            action: () {},
                          );
                        }),
                      ],
                    ),

                    /// STATUS OVERLAY
                    Visibility(
                      visible: (backPricesZero || layPricesZero) || runnerStatus.toLowerCase().contains('suspended'),
                      child: MOStatus(
                        status: (backPricesZero || layPricesZero) ? 'SUSPENDED' : runnerStatus.toUpperCase(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to ensure we always have 3 price slots
  List<ABCPrice> getThreePrices(List<ABCPrice> prices) {
    final result = List<ABCPrice>.from(prices);
    while (result.length < 3) {
      result.add(ABCPrice()..price = 0.0);
    }
    return result;
  }
}

class MatchOddsBLHeader extends StatelessWidget {
  const MatchOddsBLHeader({super.key, required this.selections});
  final String selections;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: darkGreen, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: HighlightText(
                "$selections selections",
                style: TextStyle(
                  fontSize: 12,
                  color: applyOpacity(darkGreen, 0.6),
                ),
              ),
            ),
            SizedBox(
              width: blw(context) * 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HighlightText("", textAlign: TextAlign.center, style: n12ts),

                  ///100.8%
                  BackLayChips(),
                ],
              ),
            ),
            SizedBox(
              width: blw(context) * 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BackLayChips(type: 2),
                  HighlightText("", textAlign: TextAlign.center, style: n12ts), //99.6%
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackLayChips extends StatelessWidget {
  const BackLayChips({this.type = 1, super.key});
  final int type;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: blw(context),
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: type == 1 ? backBtn : layBtn,
        borderRadius: BorderRadius.only(
          topRight: type == 2 ? Radius.circular(15) : Radius.circular(0),
          topLeft: type == 1 ? Radius.circular(15) : Radius.circular(0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          HighlightText("${type == 1 ? 'Back' : 'Lay'} All", style: n12ts),
        ],
      ),
    );
  }
}

double getBackOpacity(int index) {
  return switch (index) { 0 => 1.0, 1 => 0.4, _ => 0.2 };
}

double getLayOpacity(int index) {
  return switch (index) { 0 => 1.0, 1 => 0.4, _ => 0.2 };
}

double blw(BuildContext context) {
  Size size = MediaQuery.sizeOf(context);
  return size.width * 0.070;
}

class BackLayAllCTAButton extends StatelessWidget {
  const BackLayAllCTAButton({
    super.key,
    this.title,
    this.value,
    this.action,
    this.color,
    this.active = false,
    this.isFlash = false,
  });
  final Color? color;
  final bool active, isFlash;
  final String? title, value;
  final void Function()? action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      child: Container(
        height: 45,
        width: blw(context),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: white),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HighlightText(
                title ?? "-",
                style: b13ts(color: black),
              ),
              HighlightText(
                value ?? "-",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MOStatus extends StatelessWidget {
  const MOStatus({
    super.key,
    required this.status,
  });
  final String status;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: blw(context) * 6,
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: applyOpacity(black, 0.2)),
      child: Center(
        child: HighlightText(status, style: b13ts(color: white)),
      ),
    );
  }
}
