import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/signalRBloc/signalRStreamers/fancy_signalr_streamer.dart';
import '../../../../model/open_fancy_bets_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/highlighted_text_widget.dart';
import '../../../../reusable/sized_box_hw.dart';
import '../../../../reusable/style.dart';
import '../matchOdds/match_odds_runners_tile.dart';

class FancyRunnerDetailsTile extends StatelessWidget {
  const FancyRunnerDetailsTile({super.key, required this.risk});
  final FancyRisk risk;

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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: fancyGradient,
                    ),
                    height: 30,
                    width: 150,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 20),
                          child: HighlightText("Fancy Bet", style: TextStyle(color: white)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 3,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: fancy,
                    ),
                  ),
                  YesNoTileHeader(),
                  FancyRunnerTile(risk: risk),
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

class FancyRunnerTile extends StatefulWidget {
  const FancyRunnerTile({
    super.key,
    required this.risk,
  });
  final FancyRisk risk;

  @override
  State<FancyRunnerTile> createState() => _FancyRunnerTileState();
}

class _FancyRunnerTileState extends State<FancyRunnerTile> {
  bool isBack = false;
  String lay1Price = '';
  String back1Price = '';

  // For THREE_SELECTIONS markets
  String back2Price = '';
  String back2Line = '';
  String lay2Price = '';
  String lay2Line = '';

  // Make these nullable and initialize properly
  double? minValue;
  double? maxValue;

  // Track which button is active (row and selection)
  String? activeButtonKey;

  FancyRunner? lastValidRunner;

  /// Hover
  bool isHovered = false;
  bool isClicked = false;

  /// Flash logic
  final Map<String, Color> flashColors = {};
  final Map<String, double> previousPrices = {};

  /// DETECT PRICE CHANGES (BACKS1/LAYS1) - Fixed naming
  void detectPriceChanges(FancyRunner? newRunner) {
    if (newRunner == null) return;
    final marketId = widget.risk.marketId;
    final isThreeSelections = widget.risk.marketType.startsWith("THREE_SELECTIONS");

    // BACKS1 - First selection backs
    if (newRunner.backs.isNotEmpty) {
      final currentPrice = newRunner.backs.first.price.toDouble();
      final backs1Key = '$marketId-BACKS1';
      if (previousPrices.containsKey(backs1Key)) {
        final prevPrice = previousPrices[backs1Key]!;
        if (currentPrice > prevPrice) {
          flashColors[backs1Key] = appYellow;
        } else if (currentPrice < prevPrice) {
          flashColors[backs1Key] = cyan;
        }
      }
      previousPrices[backs1Key] = currentPrice;
    }

    // LAYS1 - First selection lays
    if (newRunner.lays.isNotEmpty) {
      final currentPrice = newRunner.lays.first.price.toDouble();
      final lays1Key = '$marketId-LAYS1';

      if (previousPrices.containsKey(lays1Key)) {
        final prevPrice = previousPrices[lays1Key]!;
        if (currentPrice > prevPrice) {
          flashColors[lays1Key] = appYellow;
        } else if (currentPrice < prevPrice) {
          flashColors[lays1Key] = cyan;
        }
      }
      previousPrices[lays1Key] = currentPrice;
    }

    // For THREE_SELECTIONS markets - Second selection
    if (isThreeSelections) {
      // BACKS2 (second backs)
      if (newRunner.backs.length > 1) {
        final currentPrice = newRunner.backs[1].price.toDouble();
        final backs2Key = '$marketId-BACKS2';

        if (previousPrices.containsKey(backs2Key)) {
          final prevPrice = previousPrices[backs2Key]!;
          if (currentPrice > prevPrice) {
            flashColors[backs2Key] = appYellow;
          } else if (currentPrice < prevPrice) {
            flashColors[backs2Key] = cyan;
          }
        }
        previousPrices[backs2Key] = currentPrice;
      }

      // LAYS2 (second lays)
      if (newRunner.lays.length > 1) {
        final currentPrice = newRunner.lays[1].price.toDouble();
        final lays2Key = '$marketId-LAYS2';

        if (previousPrices.containsKey(lays2Key)) {
          final prevPrice = previousPrices[lays2Key]!;
          if (currentPrice > prevPrice) {
            flashColors[lays2Key] = appYellow;
          } else if (currentPrice < prevPrice) {
            flashColors[lays2Key] = cyan;
          }
        }
        previousPrices[lays2Key] = currentPrice;
      }
    }

    // Clear flash after 3 seconds
    if (flashColors.isNotEmpty) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => flashColors.clear());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FancyRisk bet = widget.risk;
    final marketId = bet.marketId;
    final isThreeSelections = bet.marketType.startsWith("THREE_SELECTIONS");

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: isHovered ? highlightTileHover : white,
          border: const Border(
            bottom: BorderSide(color: black, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: HighlightText(
                      widget.risk.marketName ?? '',
                      style: b14ts,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Column(
                  children: [
                    BlocBuilder<FancySignalRStreamerBloc, FancySignalRStreamerState>(
                      builder: (_, frd) {
                        FancyRunner? runner;

                        if (frd is FancySignalRStreamerSuccess) {
                          final market = frd.fancyCatalogues.where((m) => m.marketId == marketId).toList();
                          if (market.isNotEmpty && market.first.runners.isNotEmpty) {
                            runner = market.first.runners.first;
                            lastValidRunner = runner;
                            bet = market.first;

                            // Update min/max values here
                            minValue = market.first.marketCondition?.minBet;
                            maxValue = market.first.marketCondition?.maxBet;
                          }
                        }

                        runner ??= lastValidRunner;

                        detectPriceChanges(runner);

                        /// Runner null fallback
                        back1Price = runner?.backs.isNotEmpty == true ? runner!.backs.first.price.toString() : ''; // BACKS1
                        final back1Line = runner?.backs.isNotEmpty == true ? runner!.backs.first.line.toString() : '';

                        lay1Price = runner?.lays.isNotEmpty == true ? runner!.lays.first.price.toString() : ''; // LAYS1
                        final lay1Line = runner?.lays.isNotEmpty == true ? runner!.lays.first.line.toString() : '';

                        return Stack(
                          children: [
                            Row(
                              children: [
                                // LAYS1 button
                                YesNoCTAButton(
                                  key: ValueKey('$marketId-LAYS1'),
                                  type: 0, // LAY type
                                  price: lay1Price,
                                  line: lay1Line,
                                  isFlash: flashColors.containsKey('$marketId-LAYS1'),
                                  flashColor: flashColors['$marketId-LAYS1'],
                                ),
                                // BACKS1 button
                                YesNoCTAButton(
                                  key: ValueKey('$marketId-BACKS1'),
                                  type: 1, // BACK type
                                  price: back1Price,
                                  line: back1Line,
                                  isFlash: flashColors.containsKey('$marketId-BACKS1'),
                                  flashColor: flashColors['$marketId-BACKS1'],
                                ),
                              ],
                            ),

                            /// STATUS OVERLAY
                            FBStatus(
                              market: bet,
                              backLine1: back1Line,
                              layLine1: lay1Line,
                              backLine2: '',
                              layLine2: '',
                            ),
                          ],
                        );
                      },
                    ),

                    /// THREE_SELECTIONS MARKET - Second Row
                    if (isThreeSelections)
                      BlocBuilder<FancySignalRStreamerBloc, FancySignalRStreamerState>(
                        builder: (_, frd) {
                          FancyRunner? runner;

                          if (frd is FancySignalRStreamerSuccess) {
                            final market = frd.fancyCatalogues.where((m) => m.marketId == marketId).toList();

                            if (market.isNotEmpty && market.first.runners.isNotEmpty) {
                              runner = market.first.runners.first;
                              lastValidRunner = runner;
                              bet = market.first;

                              // Update min/max values here as well
                              minValue = market.first.marketCondition?.minBet;
                              maxValue = market.first.marketCondition?.maxBet;
                            }
                          }

                          runner ??= lastValidRunner;

                          detectPriceChanges(runner);

                          /// Runner null fallback for second row
                          back2Price = runner != null && runner.backs.length > 1 ? runner.backs[1].price.toString() : '';
                          back2Line = runner != null && runner.backs.length > 1 ? runner.backs[1].line.toString() : '';

                          lay2Price = runner != null && runner.lays.length > 1 ? runner.lays[1].price.toString() : '';
                          lay2Line = runner != null && runner.lays.length > 1 ? runner.lays[1].line.toString() : '';

                          return Container(
                            margin: const EdgeInsets.only(top: 2),
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    // LAYS2 button
                                    YesNoCTAButton(
                                      key: ValueKey('$marketId-LAYS2'),
                                      type: 0,
                                      price: lay2Price,
                                      line: lay2Line,
                                      isFlash: flashColors.containsKey('$marketId-LAYS2'),
                                      flashColor: flashColors['$marketId-LAYS2'],
                                    ),
                                    // BACKS2 button
                                    YesNoCTAButton(
                                      key: ValueKey('$marketId-BACKS2'),
                                      type: 1,
                                      price: back2Price,
                                      line: back2Line,
                                      isFlash: flashColors.containsKey('$marketId-BACKS2'),
                                      flashColor: flashColors['$marketId-BACKS2'],
                                    ),
                                  ],
                                ),

                                /// STATUS OVERLAY for second row
                                FBStatus(
                                  market: bet,
                                  backLine1: '',
                                  layLine1: '',
                                  backLine2: back2Line,
                                  layLine2: lay2Line,
                                  isSecondRow: true,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
                // Move FancyMmInfo outside BlocBuilder so it can access updated min/max values
                FancyMmInfo(
                  min: minValue,
                  max: maxValue,
                  key: ValueKey('mm_${marketId}_${minValue}_$maxValue'), // Force rebuild when values change
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FBStatus extends StatelessWidget {
  final FancyRisk market;
  final String backLine1;
  final String layLine1;
  final String backLine2;
  final String layLine2;
  final bool isSecondRow;

  const FBStatus({
    super.key,
    required this.market,
    required this.backLine1,
    required this.layLine1,
    required this.backLine2,
    required this.layLine2,
    this.isSecondRow = false,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveStatuses = {
      'SUSPENDED',
      'SUSPEND',
      'INACTIVE',
      'CLOSED',
      'VOID',
      'OFFLINE',
      'VOIDED',
      'SETTLED',
      'BALL_RUN',
      'SETTLE_PROCESSING',
      'VOID_PROCESSING',
    };

    final status = market.status.toUpperCase();

    final backLine = isSecondRow ? backLine2 : backLine1;
    final layLine = isSecondRow ? layLine2 : layLine1;

    final show = inactiveStatuses.contains(status) || (backLine.isEmpty && layLine.isEmpty);

    if (!show) return const SizedBox.shrink();

    final text = market.sportingEvent == true || market.status == 'BALL_RUN'
        ? "Ball Running"
        : market.status == 'OFFLINE' || market.status == 'SUSPENDED' || market.status == 'SUSPEND' || (backLine.isEmpty && layLine.isEmpty)
            ? "Suspended"
            : "";
    return Container(
      height: 45,
      width: blw(context) * 2,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: applyOpacity(black, 0.2)),
      child: Center(
        child: HighlightText(text, style: b13ts(color: white)),
      ),
    );
  }
}

class FancyMmInfo extends StatelessWidget {
  const FancyMmInfo({
    super.key,
    required this.min,
    required this.max,
  });
  final double? min;
  final double? max;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HighlightText('Min/Max', style: TextStyle(color: applyOpacity(darkGreen, 0.7), fontSize: 12)),
            hb4,
            HighlightText(
              formatMinMaxValues(min: min ?? 0, max: max ?? 0),
              style: const TextStyle(color: black, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class YesNoTileHeader extends StatelessWidget {
  const YesNoTileHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        border: Border(bottom: BorderSide(color: black, width: 0.5)),
      ),
      height: 30,
      child: Row(
        children: [
          Expanded(flex: 2, child: SizedBox()),
          SizedBox(width: blw(context), child: Center(child: HighlightText('No', style: b14ts))),
          SizedBox(width: blw(context), child: Center(child: HighlightText('Yes', style: b14ts))),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

class YesNoCTAButton extends StatelessWidget {
  const YesNoCTAButton({
    super.key,
    this.price,
    this.line,
    this.active = false,
    this.action,
    this.color,
    this.type = 1,
    this.isFlash = false,
    this.flashColor,
  });
  final int type;
  final Color? color;
  final bool active;
  final bool isFlash;
  final Color? flashColor;
  final String? price, line;
  final void Function()? action;

  @override
  Widget build(BuildContext context) {
    // Use flash color if flashing, otherwise use provided color or default
    final displayColor = isFlash && flashColor != null ? flashColor! : (color ?? (type == 1 ? (active ? oddsBackBtn : backBtn) : (active ? pinkButtonClr : layBtn)));
    return InkWell(
      onTap: action,
      child: Container(
        height: 45,
        width: blw(context),
        decoration: BoxDecoration(
          color: displayColor,
          border: Border.all(color: white),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HighlightText(
                line ?? "-",
                style: b13ts(color: active ? white : black),
              ),
              HighlightText(
                price ?? "-",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  color: active ? white : black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
