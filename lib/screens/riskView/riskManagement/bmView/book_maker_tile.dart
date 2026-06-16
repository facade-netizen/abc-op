import 'package:flutter/material.dart';
import 'package:web/web.dart' as html;

import '../../../../model/open_bm_bets_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/highlighted_text_widget.dart';
import '../../../../router/route_paths.dart';
import '../fancyBets/grouped_bet_tile.dart';
import '../fancyBets/fancy_header.dart';
import '../matchOdds/match_odds_header.dart';

Color getBottomBorder(bool isLast) => isLast ? borderColor : Colors.grey.shade200;

class BookMakerTile extends StatefulWidget {
  const BookMakerTile({super.key, required this.openBM, required this.sid, required this.userName});
  final String userName;
  final OpenBMData openBM;
  final int sid;

  @override
  State<BookMakerTile> createState() => _BookMakerTileState();
}

class _BookMakerTileState extends State<BookMakerTile> {
  void openBookView(String eventName, String eventType, String marketId, String userName) {
    final baseUrl = html.window.location.origin;
    final url = '$baseUrl${RoutePaths.manageEventBookView}?eventName=${eqc(eventName)}&eventType=${eqc(eventType)}&marketId=${eqc(marketId)}&userName=${eqc(userName)}';
    html.window.open(url, '_blank', 'width=1200,height=650,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,location=no,status=no');
  }

  @override
  Widget build(BuildContext context) {
    return GroupedBetTile(
      tileType: 'bm',
      sportName: widget.openBM.sportName,
      dates: widget.openBM.dates,
      getEvents: (date) => date.events,
      getDate: (date) => date.date,
      sportAction: () {
        final baseUrl = html.window.location.origin;
        final url = '$baseUrl${RoutePaths.manageSportWiseReport}?sid=${eqc(widget.openBM.sid)}&bettingType=${eqc('2')}&userName=${eqc(widget.userName)}';
        html.window.open(url, '_blank', 'width=1200,height=850,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,location=no,status=no');
      },
      eventRowBuilder: (context, event, isLast, isExpanded, onExpandToggle) {
        return Row(
          children: [
            MarketNameCard(
              isLast: isLast,
              eventName: event.eventName,
              type: '_Bookmaker',
              isExpanded: isExpanded,
              onTap: () {
                final baseUrl = html.window.location.origin;
                final url =
                    '$baseUrl${RoutePaths.manageSportWiseReport}?sid=${eqc(widget.openBM.sid)}&bettingType=${eqc('2')}&eventId=${eqc(event.eventId)}&userName=${eqc(widget.userName)}';
                html.window.open(url, '_blank', 'width=1200,height=850,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,location=no,status=no');
              },
            ),
            RunnersCard(risk: event.risk, isLast: isLast, sid: widget.sid, userName: widget.userName),
            ViewButton(
              isLast: isLast,
              onTap: () {
                openBookView(event.eventName, 'Bookmaker', event.risk.marketId, widget.userName);
              },
            ),
          ],
        );
      },
    );
  }
}

class RunnersCard extends StatefulWidget {
  const RunnersCard({super.key, required this.isLast, this.isExpanded = false, required this.sid, required this.risk, required this.userName});
  final BMRisk risk;
  final bool isLast, isExpanded;
  final int sid;
  final String userName;
  @override
  State<RunnersCard> createState() => _RunnersCardState();
}

class _RunnersCardState extends State<RunnersCard> {
  List<BMRunner> runners = [];
  List<BMRunner> displayRunners = [];

  @override
  void initState() {
    super.initState();
    _updateRunners();
  }

  @override
  void didUpdateWidget(covariant RunnersCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.risk != widget.risk) {
      _updateRunners();
    }
  }

  void _updateRunners() {
    runners = widget.risk.runners;
    displayRunners = [];
    if (runners.length == 3) {
      // Party1 | Draw | Party2
      displayRunners = [runners[0], runners[2], runners[1]];
    } else if (runners.length == 2) {
      // Party1 | Party2
      displayRunners = [runners[0], runners[1]];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: white,
        border: Border(
          left: const BorderSide(color: borderColor),
          right: const BorderSide(color: borderColor),
          bottom: BorderSide(color: getBottomBorder(widget.isLast)),
        ),
      ),
      width: mmw(context) * (widget.sid == 1 ? 3 : 2),
      child: Row(
        children: List.generate(displayRunners.length, (index) {
          final oddsRunner = displayRunners[index];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      final baseUrl = html.window.location.origin;
                      final url =
                          '$baseUrl${RoutePaths.manageRunnerWiseReport}?eventType=${eqc('Bookmaker')}&marketId=${eqc(widget.risk.marketId)}&runnerId=${eqc(oddsRunner.runnerId)}&userName=${eqc(widget.userName)}';
                      html.window.open(url, '_blank', 'width=1200,height=850,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,location=no,status=no');
                    },
                    child: HighlightText(
                      formattedAmounts(oddsRunner.pnl.toDouble()).replaceAll("-", ''),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: oddsRunner.pnl < 0 ? red : green,
                        fontSize: 12,
                        decoration: oddsRunner.pnl < 0 ? TextDecoration.none : TextDecoration.underline,
                        decorationColor: oddsRunner.pnl < 0 ? red : green,
                      ),
                    ),
                  ),
                  HighlightText(
                    oddsRunner.runnerName,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 10, color: black),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
