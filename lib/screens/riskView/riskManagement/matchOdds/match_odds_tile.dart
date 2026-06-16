import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/web.dart' as html;

import '../../../../bloc/signalRBloc/signalRStreamers/odds_signalr_streamer.dart';
import '../../../../bloc/signalRBloc/signalr_event_listener_bloc.dart';
import '../../../../model/open_odds_bets_model.dart';
import '../../../../model/sport_wise_report_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/highlighted_text_widget.dart';
import '../../../../router/route_paths.dart';
import '../bmView/book_maker_tile.dart';
import '../fancyBets/grouped_bet_tile.dart';
import '../fancyBets/fancy_header.dart';
import 'match_odds_header.dart';
import 'match_odds_runners_tile.dart';

class MatchOddsTableTile extends StatefulWidget {
  const MatchOddsTableTile({super.key, required this.openOdds, required this.sid, required this.userName});
  final OpenOddsData openOdds;
  final int sid;
  final String userName;

  @override
  State<MatchOddsTableTile> createState() => _MatchOddsTableTileState();
}

class _MatchOddsTableTileState extends State<MatchOddsTableTile> {
  void openBookView(String eventName, String eventType, String marketId) {
    final baseUrl = html.window.location.origin;
    final url = '$baseUrl${RoutePaths.manageEventBookView}?eventName=${eqc(eventName)}&eventType=${eqc(eventType)}&marketId=${eqc(marketId)}&userName=${eqc(widget.userName)}';
    html.window.open(url, '_blank', 'width=1200,height=650,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,location=no,status=no');
  }

  @override
  Widget build(BuildContext context) {
    return GroupedBetTile(
      tileType: 'odds',
      sportName: widget.openOdds.sportName,
      dates: widget.openOdds.dates,
      getEvents: (date) => date.events,
      getDate: (date) => date.date,
      sportAction: () {
        final baseUrl = html.window.location.origin;
        final url = '$baseUrl${RoutePaths.manageSportWiseReport}?sid=${eqc(widget.openOdds.sid)}&bettingType=${eqc('0')}&userName=${eqc(widget.userName)}';
        html.window.open(url, '_blank', 'width=1200,height=850,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,location=no,status=no');
      },
      eventRowBuilder: (context, event, isLast, isExpanded, onExpandToggle) {
        return Row(
          children: [
            MarketNameCard(
              isExpanded: isExpanded,
              isLast: isLast,
              eventName: event.eventName,
              onTap: () {
                final baseUrl = html.window.location.origin;
                final url =
                    '$baseUrl${RoutePaths.manageSportWiseReport}?sid=${eqc(widget.openOdds.sid)}&bettingType=${eqc('0')}&eventId=${eqc(event.eventId)}&userName=${eqc(widget.userName)}';
                html.window.open(url, '_blank', 'width=1200,height=850,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,location=no,status=no');
              },
              type: getReportType(event.risk.marketType),
              onExpandToggle: () {
                String eventId = event.eventId;
                if (eventId.isEmpty) {
                  onExpandToggle!();
                  return;
                }

                if (!isExpanded) {
                  // Expanding - Connect to SignalR
                  debugPrint('Connecting to event: $eventId');
                  context.read<SignalREventListenerBloc>().add(SignalREventListener(eventId: eventId));
                  context.read<OddsSignalRStreamerBloc>().add(OddsSignalRStreamerListener());
                } else {
                  // Collapsing - Disconnect from SignalR
                  debugPrint('Disconnecting from event: $eventId');
                  context.read<SignalREventListenerBloc>().add(SignalREventDisconnect());
                  context.read<OddsSignalRStreamerBloc>().add(SetToInitialOddsSignalRStreamer());
                }
                // Toggle expansion after handling connection
                onExpandToggle!();
              },
            ),
            RunnersCard(isLast: isLast, sid: widget.sid, isExpanded: isExpanded, risk: event.risk, userName: widget.userName),
            ViewButton(
              isLast: isLast,
              isExpanded: isExpanded,
              onTap: () {
                openBookView(event.eventName, 'Match Odds', event.risk.marketId);
              },
            ),
          ],
        );
      },
      expandedSectionBuilder: (context, event, isExpanded) {
        return MatchOddsRunnersDetails(runners: event.risk.runners);
      },
    );
  }
}

class RunnersCard extends StatefulWidget {
  const RunnersCard({super.key, required this.isLast, this.isExpanded = false, required this.sid, required this.risk, required this.userName});
  final OddsRisk risk;
  final bool isLast, isExpanded;
  final int sid;
  final String userName;

  @override
  State<RunnersCard> createState() => _RunnersCardState();
}

class _RunnersCardState extends State<RunnersCard> {
  List<OddsRunner> runners = [];
  List<OddsRunner> displayRunners = [];

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
                          '$baseUrl${RoutePaths.manageRunnerWiseReport}?eventType=${eqc('Match Odds')}&marketId=${eqc(widget.risk.marketId)}&runnerId=${eqc(oddsRunner.runnerId)}&userName=${eqc(widget.userName)}';
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
