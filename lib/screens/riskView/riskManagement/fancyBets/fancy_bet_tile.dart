import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/fetchBlocs/fetch_fancy_book_bloc.dart';
import '../../../../bloc/signalRBloc/signalRStreamers/fancy_signalr_streamer.dart';
import '../../../../bloc/signalRBloc/signalr_event_listener_bloc.dart';
import '../../../../model/open_fancy_bets_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/highlighted_text_widget.dart';
import 'grouped_bet_tile.dart';
import 'fancy_header.dart';
import 'fancy_runner_details_tile.dart';
import 'show_fancy_book_view.dart';

class FancyBetTile extends StatelessWidget {
  const FancyBetTile({
    super.key,
    required this.openFancyData,
  });

  final OpenFancyData openFancyData;

  @override
  Widget build(BuildContext context) {
    return GroupedBetTile(
      tileType: 'fancy',
      sportName: openFancyData.sportName,
      dates: openFancyData.dates,
      getEvents: (date) => date.events,
      getDate: (date) => date.date,
      eventRowBuilder: (context, event, isLast, isExpanded, onExpandToggle) {
        return Row(
          children: [
            MarketNameCard(
              isLast: isLast,
              eventName: event.eventName,
              type: event.risk.marketName ?? '',
              isExpanded: isExpanded,
              onExpandToggle: (event.risk.marketName ?? '').isEmpty
                  ? null
                  : () {
                      String eventId = event.eventId;
                      if (eventId.isEmpty) {
                        onExpandToggle!();
                        return;
                      }
                      if (!isExpanded) {
                        context.read<SignalREventListenerBloc>().add(SignalREventListener(eventId: eventId));
                        context.read<FancySignalRStreamerBloc>().add(FancySignalRStreamerListener());
                      } else {
                        context.read<FancySignalRStreamerBloc>().add(SetToInitialSignalRFancy());
                        context.read<SignalREventListenerBloc>().add(SignalREventDisconnect());
                      }
                      // Toggle expansion after handling connection
                      onExpandToggle!();
                    },
            ),
            RunnersCard(isExpanded: isExpanded, linePnl: event.risk.linePnl, isLast: isLast),
            BooksButton(
              isLast: isLast,
              isExpanded: false,
              onTap: () async {
                final bloc = context.read<FetchFancyBookBloc>();
                if (kIsWeb) {
                  bloc.add(FetchFancyBook(marketId: event.risk.marketId));
                  try {
                    final state = await bloc.stream.firstWhere((s) => s is FetchFancyBookSuccess || s is FetchFancyBookFailure);
                    if (state is FetchFancyBookSuccess) {
                      final entries = state.fancyBook.map((b) => FancyBookEntry(runs: b.runs.toString(), amount: (b.amount).toDouble())).toList();
                      if (context.mounted) {
                        showFancyBookViewWithData(context, matchTitle: event.eventName, tag: event.risk.marketName ?? '', runnerName: event.eventName, data: entries);
                      }
                      return;
                    }
                  } catch (e) {
                    debugPrint('Failed to fetch fancy book data for web popup $e');
                  }
                }
                bloc.add(FetchFancyBook(marketId: event.risk.marketId));
              },
            ),
          ],
        );
      },
      expandedSectionBuilder: (context, event, isExpanded) {
        return FancyRunnerDetailsTile(
          risk: event.risk,
          key: Key('fancy_runners_details_at_${event.eventId}_${DateTime.now().toIso8601String()}'),
        );
      },
    );
  }
}

class RunnersCard extends StatelessWidget {
  const RunnersCard({
    super.key,
    required this.linePnl,
    required this.isLast,
    required this.isExpanded,
  });

  final LinePnl? linePnl;
  final bool isLast, isExpanded;

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
          bottom: isExpanded ? BorderSide.none : BorderSide(color: isLast ? borderColor : Colors.grey.shade200),
        ),
      ),
      width: mmw(context) * 2,
      child: Row(
        children: [
          SizedBox(
            width: mmw(context) - 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: HighlightText(
                formattedAmounts(linePnl?.min ?? 0.0).replaceAll("-", ''),
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: (linePnl?.min ?? 0.0) < 0 ? red : green,
                  fontSize: 12,
                  decoration: (linePnl?.min ?? 0.0) < 0 ? TextDecoration.none : TextDecoration.underline,
                  decorationColor: (linePnl?.min ?? 0.0) < 0 ? red : green,
                ),
              ),
            ),
          ),
          SizedBox(
            width: mmw(context) - 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: HighlightText(
                formattedAmounts(linePnl?.max ?? 0.0).replaceAll("-", ''),
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: (linePnl?.max ?? 0.0) < 0 ? red : green,
                  fontSize: 12,
                  decoration: (linePnl?.max ?? 0.0) < 0 ? TextDecoration.none : TextDecoration.underline,
                  decorationColor: (linePnl?.max ?? 0.0) < 0 ? red : green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
