import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/fetchBlocs/fetch_sb_betlist_bloc.dart';
import '../../model/bet_list_model.dart';
import '../../reusable/colors.dart';
import '../../reusable/highlighted_text_widget.dart';
import '../../reusable/sized_box_hw.dart';
import 'filter_overlay_button.dart';

class SbEventsFilterOverlay extends StatefulWidget {
  final double width;
  final Function(Set<String> selectedEvents)? onSubmitted;

  const SbEventsFilterOverlay({
    super.key,
    required this.width,
    this.onSubmitted,
  });

  @override
  State<SbEventsFilterOverlay> createState() => _SbEventsFilterOverlayState();
}

class _SbEventsFilterOverlayState extends State<SbEventsFilterOverlay> {
  // Track selected events
  late Set<String> selectedEvents;
  late bool isAllSelected;

  // Store the setBodyState function
  late void Function(void Function()) _setBodyState;

  @override
  void initState() {
    super.initState();
    selectedEvents = {};
    isAllSelected = true;
  }

  void _refreshFilters() {
    _setBodyState(() {
      selectedEvents.clear();
      isAllSelected = false;
    });

    setState(() {
      selectedEvents.clear();
      isAllSelected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FilterOverlay(
      width: widget.width,
      bodyWidth: 400,
      title: 'Events Filter',
      refreshTitle: 'Refresh',
      onRefresh: _refreshFilters,
      onSubmitted: (filterValues) {
        if (widget.onSubmitted != null) {
          widget.onSubmitted!(selectedEvents);
        }
      },
      body: BlocBuilder<FetchSbBetListBloc, FetchSbBetListState>(
        builder: (context, fbl) {
          List<BetData> betsList = [];
          if (fbl is FetchSbBetListSuccess) {
            betsList = fbl.betsList;
          }

          // Filter to get unique events
          List<BetData> uniqueEvents = [];
          Set<String> eventNames = {};

          for (var bet in betsList) {
            if (!eventNames.contains(bet.event)) {
              eventNames.add(bet.event);
              uniqueEvents.add(bet);
            }
          }

          // Initialize selected events if empty and All is selected
          if (selectedEvents.isEmpty && isAllSelected) {
            selectedEvents = eventNames.toSet();
          }

          return StatefulBuilder(
            builder: (context, setBodyState) {
              // Store the setBodyState function for refresh
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _setBodyState = setBodyState;
              });

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                    ),
                    child: Center(
                      child: HighlightText(
                        'Event',
                        style: TextStyle(color: black, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // All Events Option
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                      color: white,
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isAllSelected,
                          onChanged: (value) {
                            setBodyState(() {
                              isAllSelected = value!;
                              if (isAllSelected) {
                                // When All is selected, select all events
                                selectedEvents = eventNames.toSet();
                              } else {
                                // When All is deselected, clear all selections
                                selectedEvents.clear();
                              }
                            });
                          },
                        ),
                        const HighlightText(
                          'All',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // Individual Events List
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 300,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: uniqueEvents.length,
                      itemBuilder: (context, index) {
                        BetData betData = uniqueEvents[index];
                        bool isSelected = selectedEvents.contains(betData.event);

                        return Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                            color: white,
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setBodyState(() {
                                    if (value!) {
                                      selectedEvents.add(betData.event);
                                    } else {
                                      selectedEvents.remove(betData.event);
                                    }
                                    isAllSelected = selectedEvents.length == eventNames.length;
                                  });
                                },
                              ),
                              HighlightText(betData.sport),
                              wb4,
                              Icon(
                                Icons.arrow_right,
                                color: Colors.grey.shade200,
                              ),
                              Expanded(
                                child: HighlightText(
                                  betData.event,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
