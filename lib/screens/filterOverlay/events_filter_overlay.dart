import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/fetchBlocs/fetch_order_event_bloc.dart';
import '../../model/order_events_model.dart';
import '../../reusable/colors.dart';
import '../../reusable/highlighted_text_widget.dart';
import 'filter_overlay_button.dart';

class EventsFilterOverlayNew extends StatefulWidget {
  final double width;
  final Function(Map<String, dynamic> values)? onSubmitted;

  const EventsFilterOverlayNew({super.key, required this.width, this.onSubmitted});

  @override
  State<EventsFilterOverlayNew> createState() => _EventsFilterOverlayNewState();
}

class _EventsFilterOverlayNewState extends State<EventsFilterOverlayNew> {
  Set<String> selectedEvents = {};
  bool isAllSelected = true;
  // Per-event market selections: eventName → Set<marketId>
  final Map<String, Set<String>> _selectedMarketsPerEvent = {};
  String? selectedEventForMarkets;
  StateSetter? _setBodyState;
  Map<String, String> _eventNameToId = {};

  void _refreshFilters() {
    void reset() {
      selectedEvents = {};
      isAllSelected = false;
      _selectedMarketsPerEvent.clear();
      selectedEventForMarkets = null;
    }

    if (_setBodyState != null) {
      _setBodyState!(reset);
    } else {
      setState(reset);
    }
  }

  double bw = 600;

  @override
  Widget build(BuildContext context) {
    return FilterOverlay(
      width: widget.width,
      bodyWidth: bw,
      title: 'Events Filter',
      refreshTitle: 'Refresh',
      onRefresh: _refreshFilters,
      onSubmitted: (filterValues) {
        if (widget.onSubmitted != null) {
          final selectedEventIds = selectedEvents.map((name) => _eventNameToId[name] ?? name).toSet();
          final allMarketIds = _selectedMarketsPerEvent.values.expand((ids) => ids).toSet();
          debugPrint('Selected Event IDs: ${selectedEventIds.join(',')}');
          debugPrint('Selected Market IDs: ${allMarketIds.join(',')}');
          widget.onSubmitted!({'eventIds': selectedEventIds, 'marketIds': allMarketIds});
        }
      },
      body: BlocBuilder<FetchOrderEventsBloc, FetchOrderEventsState>(
        builder: (context, fbl) {
          List<OrderEventData> eventList = [];
          if (fbl is FetchOrderEventsSuccess) {
            eventList = fbl.events;
          }

          Set<String> eventNames = {};
          Map<String, String> eventNameToId = {};

          for (var event in eventList) {
            eventNames.add(event.eventName);
            eventNameToId[event.eventName] = event.eventId;
          }

          // Keep state-level map in sync for use in submit
          _eventNameToId = eventNameToId;

          // Auto-select all events on initial load
          if (isAllSelected && selectedEvents.isEmpty && eventList.isNotEmpty) {
            selectedEvents = eventNames.toSet();
            // Also auto-select all markets for every event
            for (var event in eventList) {
              final ids = <String>{};
              for (var m in event.markets) {
                ids.add(m.marketId);
              }
              if (ids.isNotEmpty) {
                _selectedMarketsPerEvent.putIfAbsent(event.eventName, () => ids);
              }
            }
          }

          return StatefulBuilder(
            builder: (context, setBodyState) {
              _setBodyState = setBodyState;

              // Must be computed inside StatefulBuilder so it rebuilds when
              // selectedEventForMarkets changes via setBodyState
              final List<OrderMarketData> marketsForSelectedEvent = [];
              final Set<String> marketIdsForSelectedEvent = {};
              if (selectedEventForMarkets != null) {
                for (var event in eventList) {
                  if (event.eventName == selectedEventForMarkets) {
                    for (var market in event.markets) {
                      if (marketIdsForSelectedEvent.add(market.marketId)) {
                        marketsForSelectedEvent.add(market);
                      }
                    }
                    break;
                  }
                }
              }

              final currentEventMarkets = _selectedMarketsPerEvent[selectedEventForMarkets] ?? {};
              final isAllMarketsSelected = marketIdsForSelectedEvent.isNotEmpty && currentEventMarkets.length == marketIdsForSelectedEvent.length;

              return Container(
                width: bw,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: const [
                        Expanded(child: EventHeader(title: 'Events')),
                        Expanded(child: EventHeader(title: 'Markets')),
                      ],
                    ),
                    Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: Colors.grey.shade300),
                                  right: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: eventList.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return AllActionTile(
                                      value: isAllSelected,
                                      onChanged: (value) {
                                        setBodyState(() {
                                          isAllSelected = value!;
                                          if (isAllSelected) {
                                            selectedEvents = eventNames.toSet();
                                            // Auto-select all markets for all events
                                            for (var event in eventList) {
                                              final ids = <String>{};
                                              for (var m in event.markets) {
                                                ids.add(m.marketId);
                                              }
                                              if (ids.isNotEmpty) {
                                                _selectedMarketsPerEvent[event.eventName] = ids;
                                              }
                                            }
                                          } else {
                                            selectedEvents.clear();
                                            _selectedMarketsPerEvent.clear();
                                          }
                                        });
                                      },
                                    );
                                  }

                                  final event = eventList[index - 1];
                                  final isSelected = selectedEvents.contains(event.eventName);
                                  final isEventSelectedForMarkets = selectedEventForMarkets == event.eventName;

                                  return EventRow(
                                    eventName: event.eventName,
                                    sportName: event.eventId.contains('sr') ? "S/R ${event.sportName}" : event.sportName,
                                    value: isSelected,
                                    isSelectedForMarkets: isEventSelectedForMarkets,
                                    onTap: () {
                                      setBodyState(() {
                                        if (selectedEventForMarkets == event.eventName) {
                                          selectedEventForMarkets = null;
                                        } else {
                                          selectedEventForMarkets = event.eventName;
                                        }
                                      });
                                    },
                                    onChanged: (value) {
                                      setBodyState(() {
                                        if (value!) {
                                          selectedEvents.add(event.eventName);
                                          // Auto-select all markets for this event
                                          final ids = event.markets.map((m) => m.marketId).toSet();
                                          if (ids.isNotEmpty) {
                                            _selectedMarketsPerEvent[event.eventName] = ids;
                                          }
                                        } else {
                                          selectedEvents.remove(event.eventName);
                                          // Auto-deselect all markets for this event
                                          _selectedMarketsPerEvent.remove(event.eventName);
                                        }
                                        isAllSelected = selectedEvents.length == eventNames.length;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: Colors.grey.shade300),
                                  right: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: marketsForSelectedEvent.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return AllActionTile(
                                      value: isAllMarketsSelected,
                                      onChanged: (value) {
                                        setBodyState(() {
                                          if (value!) {
                                            _selectedMarketsPerEvent[selectedEventForMarkets!] = marketIdsForSelectedEvent.toSet();
                                            // Auto-select the event
                                            selectedEvents.add(selectedEventForMarkets!);
                                            isAllSelected = selectedEvents.length == eventNames.length;
                                          } else {
                                            _selectedMarketsPerEvent[selectedEventForMarkets!] = {};
                                            // Auto-deselect the event
                                            selectedEvents.remove(selectedEventForMarkets);
                                            isAllSelected = false;
                                          }
                                        });
                                      },
                                    );
                                  }

                                  final marketIndex = index - 1;
                                  final marketData = marketsForSelectedEvent[marketIndex];
                                  final isSelected = (_selectedMarketsPerEvent[selectedEventForMarkets] ?? {}).contains(marketData.marketId);

                                  return EventRow(
                                    eventName: marketData.marketName,
                                    value: isSelected,
                                    onTap: () {
                                      setBodyState(() {
                                        if (isSelected) {
                                          _selectedMarketsPerEvent[selectedEventForMarkets!]?.remove(marketData.marketId);
                                          // If no markets left, deselect the event
                                          if ((_selectedMarketsPerEvent[selectedEventForMarkets!] ?? {}).isEmpty) {
                                            selectedEvents.remove(selectedEventForMarkets);
                                            isAllSelected = false;
                                          }
                                        } else {
                                          _selectedMarketsPerEvent[selectedEventForMarkets!] = (_selectedMarketsPerEvent[selectedEventForMarkets!] ?? {})..add(marketData.marketId);
                                          // Auto-select the event if not already selected
                                          selectedEvents.add(selectedEventForMarkets!);
                                          isAllSelected = selectedEvents.length == eventNames.length;
                                        }
                                      });
                                    },
                                    onChanged: (value) {
                                      setBodyState(() {
                                        final eventMarkets = _selectedMarketsPerEvent.putIfAbsent(selectedEventForMarkets!, () => {});
                                        if (value!) {
                                          eventMarkets.add(marketData.marketId);
                                          // Auto-select the event if not already selected
                                          selectedEvents.add(selectedEventForMarkets!);
                                          isAllSelected = selectedEvents.length == eventNames.length;
                                        } else {
                                          eventMarkets.remove(marketData.marketId);
                                          // If no markets left, deselect the event
                                          if (eventMarkets.isEmpty) {
                                            selectedEvents.remove(selectedEventForMarkets);
                                            isAllSelected = false;
                                          }
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AllActionTile extends StatelessWidget {
  const AllActionTile({super.key, this.value, this.onChanged});
  final bool? value;
  final Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Checkbox(value: value, onChanged: onChanged),
          const HighlightText('All', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class EventRow extends StatefulWidget {
  const EventRow({super.key, required this.eventName, this.value, this.sportName = '', this.onChanged, this.isSelectedForMarkets = false, this.onTap});

  final String eventName;
  final String sportName;
  final bool? value;
  final Function(bool?)? onChanged;
  final bool isSelectedForMarkets;
  final void Function()? onTap;

  @override
  State<EventRow> createState() => _EventRowState();
}

class _EventRowState extends State<EventRow> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        color: widget.isSelectedForMarkets
            ? const Color(0xFFF7EAC5)
            : isHovered
            ? const Color(0xFFEBE5DC)
            : const Color(0xFFF4F1EC),
      ),
      child: InkWell(
        onTap: widget.onTap,
        onHover: (hovering) {
          setState(() {
            isHovered = hovering;
          });
        },
        child: Row(
          children: [
            Checkbox(value: widget.value, onChanged: widget.onChanged),
            if (widget.sportName.isNotEmpty) ...[HighlightText(widget.sportName), SizedBox(width: 4), Icon(Icons.arrow_right, color: Colors.grey)],
            Expanded(child: HighlightText(widget.eventName, overflow: TextOverflow.ellipsis, maxLines: 1)),
          ],
        ),
      ),
    );
  }
}

class EventHeader extends StatelessWidget {
  const EventHeader({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 30,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
        color: white,
      ),
      child: Center(
        child: HighlightText(
          title,
          style: TextStyle(color: black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
