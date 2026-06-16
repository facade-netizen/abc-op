import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_betlist_live_bloc.dart';
import '../../../model/bet_list_model.dart';
import '../../../reusable/button.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/highlighted_text_widget.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../filterOverlay/download_report.dart';
import '../../filterOverlay/events_filter_overlay.dart';
import '../../filterOverlay/ipisp_filter_overlay.dart';
import '../../filterOverlay/odds_differential_filter_overlay.dart';
import '../../filterOverlay/stakes_filter_overlay.dart';
import '../../filterOverlay/user_filter_overlay.dart';
import '../../riskView/riskMonitoring/row_dropdown.dart';

///Sport Config Model
class SportConfig {
  final int sid;
  final int bettingType;
  const SportConfig({required this.sid, required this.bettingType});
}

///Mapping
final Map<String, SportConfig> sportConfigMap = {
  'Soccer': SportConfig(sid: 1, bettingType: 0),
  'BOOK Soccer': SportConfig(sid: 1, bettingType: 2),
  'Sportsbook Soccer': SportConfig(sid: 1, bettingType: 0),
  'Tennis': SportConfig(sid: 2, bettingType: 0),
  'BOOK Tennis': SportConfig(sid: 2, bettingType: 2),
  'Sportsbook Tennis': SportConfig(sid: 2, bettingType: 0),
  'Cricket': SportConfig(sid: 4, bettingType: 0),
  'Cricket/Fancy Bet': SportConfig(sid: 4, bettingType: 1),
  'BOOK Cricket': SportConfig(sid: 4, bettingType: 2),
  'Sportsbook Cricket': SportConfig(sid: 4, bettingType: 0),
  'Horse Racing': SportConfig(sid: 7, bettingType: 0),
  'Election/Fancy Bet': SportConfig(sid: 2378961, bettingType: 0),
  'BOOK Election': SportConfig(sid: 2378961, bettingType: 2),
};

// Sport groups
enum SportGroup { regular, book, sportsbook }

SportGroup getSportGroup(String sport) {
  final lower = sport.toLowerCase();
  if (lower.startsWith('book ')) return SportGroup.book;
  if (lower.startsWith('sportsbook ')) return SportGroup.sportsbook;
  return SportGroup.regular;
}

// Default sports selected when "All" is checked
const List<String> defaultSports = ['soccer', 'tennis', 'cricket'];

// Constants moved outside class for better performance
final List<String> multiSportsList = ['All', ...sportConfigMap.keys];
const List<String> _txnList = ["100 Txn", "50 Txn", "25 Txn"];
const List<String> _orderList = ["Ascending", "Descending"];
const List<String> _orderByList = ["Stake", "Player ID", "Time"];
const List<String> _refreshTimeList = ["Stop", "60", "30", "15", "5", "2"];
final List<String> betStatusList = ["All", "Unmatched", "Matched"];

// Separated widget for filter section to reduce rebuilds
class FilterSection extends StatelessWidget {
  final ValueNotifier<FilterState> filtersNotifier;
  final Function(bool, String, bool) onSportChange;
  final Function(void Function(FilterState)) onFilterUpdate;
  final VoidCallback onResetAndFetch;
  final VoidCallback onUpdateAutoRefresh;

  const FilterSection({
    super.key,
    required this.filtersNotifier,
    required this.onSportChange,
    required this.onFilterUpdate,
    required this.onResetAndFetch,
    required this.onUpdateAutoRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      width: size.width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: accountStatementHeaderBg,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SportsCheckboxes(filtersNotifier: filtersNotifier, onSportChange: onSportChange),
          hb12,
          FiltersRow(onFilterUpdate: onFilterUpdate, onResetAndFetch: onResetAndFetch),
          hb12,
          ControlsRow(filtersNotifier: filtersNotifier, onFilterUpdate: onFilterUpdate, onResetAndFetch: onResetAndFetch, onUpdateAutoRefresh: onUpdateAutoRefresh),
        ],
      ),
    );
  }
}

class SportsCheckboxes extends StatelessWidget {
  final ValueNotifier<FilterState> filtersNotifier;
  final Function(bool, String, bool) onSportChange;

  const SportsCheckboxes({super.key, required this.filtersNotifier, required this.onSportChange});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FilterState>(
      valueListenable: filtersNotifier,
      builder: (context, filters, _) {
        final isAllSelected = filters.selectedSports.length == defaultSports.length && defaultSports.every((s) => filters.selectedSports.contains(s));

        return Wrap(
          spacing: 8,
          children: multiSportsList.map((sport) {
            final isAll = sport == "All";
            final sportValue = sport.toLowerCase();
            final checked = isAll ? isAllSelected : filters.selectedSports.contains(sportValue);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(value: checked, onChanged: (v) => onSportChange(isAll, sportValue, v ?? false)),
                HighlightText(sport, style: const TextStyle(fontSize: 13)),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

class FiltersRow extends StatelessWidget {
  final Function(void Function(FilterState)) onFilterUpdate;
  final VoidCallback onResetAndFetch;

  const FiltersRow({super.key, required this.onFilterUpdate, required this.onResetAndFetch});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ///event filter
        EventsFilterOverlayNew(
          width: 130,
          onSubmitted: (events) {
            onFilterUpdate((f) => f.selectedEvents = events);
            onResetAndFetch();
          },
        ),

        ///stacks filter
        StakesFilterOverlay(
          width: 130,
          onSubmitted: (stacks) {
            onFilterUpdate((f) => f.stakesFilter = stacks);
            onResetAndFetch();
          },
        ),

        ///odds differential filter
        OddsDifferentialFilterOverlay(
          width: 220,
          onSubmitted: (filterValues) {
            onFilterUpdate((f) => f.oddsFilter = filterValues);
            onResetAndFetch();
          },
        ),
        UserFilterOverlay(
          width: 130,
          onSubmitted: (filterValues) {
            onFilterUpdate((f) => f.userFilter = filterValues);
            onResetAndFetch();
          },
        ),
        IPISPFilterOverlay(
          width: 130,
          onSubmitted: (filterValues) {
            onFilterUpdate((f) => f.ipFilter = filterValues);
            onResetAndFetch();
          },
        ),
      ],
    );
  }
}

class ControlsRow extends StatelessWidget {
  final ValueNotifier<FilterState> filtersNotifier;
  final Function(void Function(FilterState)) onFilterUpdate;
  final VoidCallback onResetAndFetch;
  final VoidCallback onUpdateAutoRefresh;
  const ControlsRow({super.key, required this.filtersNotifier, required this.onFilterUpdate, required this.onResetAndFetch, required this.onUpdateAutoRefresh});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FilterState>(
      valueListenable: filtersNotifier,
      builder: (context, filters, _) {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            RowDropdown(
              title: "Order of display",
              value: filters.orderBy,
              items: _orderByList,
              onChanged: (v) {
                onFilterUpdate((f) => f.orderBy = v!);
                onResetAndFetch();
              },
            ),
            RowDropdown(
              title: "of",
              value: filters.order,
              items: _orderList,
              onChanged: (v) {
                onFilterUpdate((f) => f.order = v!);
                onResetAndFetch();
              },
            ),
            RowDropdown(
              title: "Last",
              value: filters.lastTxn,
              items: _txnList,
              onChanged: (v) {
                onFilterUpdate((f) => f.lastTxn = v!);
                onResetAndFetch();
              },
            ),
            RowDropdown(
              title: "Auto Refresh (Seconds)",
              value: filters.refreshTime,
              items: _refreshTimeList,
              onChanged: (v) {
                onFilterUpdate((f) => f.refreshTime = v!);
                onUpdateAutoRefresh();
              },
            ),
            RowDropdown(
              title: "Bet Status",
              value: filters.betStatus,
              items: betStatusList,
              onChanged: (v) {
                onFilterUpdate((f) => f.betStatus = v!);
                onResetAndFetch();
              },
            ),
            CustomECTAButton(title: "Refresh", action: onResetAndFetch),

            /// DOWNLOAD
            BlocBuilder<FetchBetListLiveBloc, FetchBetListLiveState>(
              builder: (_, state) {
                List<BetData> data = [];

                if (state is FetchBetListLiveSuccess) {
                  data = state.betsList;
                }

                return DownloadReport(
                  height: 30,
                  reportName: "Bet List",
                  headerTitles: betDataColumns.map((e) => e.label).toList(),
                  rowData: data.map((row) {
                    return betDataColumns.map((col) {
                      if (col.label == "Market") {
                        return "${row.sport} > ${row.event} > ${row.marketName}";
                      }
                      return col.value?.call(row) ?? "";
                    }).toList();
                  }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// Optimized FilterState with better immutability
class FilterState {
  List<String> selectedSports;
  Map<String, dynamic> selectedEvents;
  Map<String, dynamic> oddsFilter;
  Map<String, dynamic> stakesFilter;
  Map<String, dynamic> userFilter;
  Map<String, dynamic> ipFilter;
  String orderBy;
  String order;
  String lastTxn;
  String refreshTime;
  String betStatus;

  FilterState({
    this.selectedSports = const [],
    this.selectedEvents = const {},
    this.oddsFilter = const {},
    this.stakesFilter = const {},
    this.userFilter = const {},
    this.ipFilter = const {},
    this.orderBy = "Stake",
    this.order = "Ascending",
    this.lastTxn = "25 Txn",
    this.refreshTime = "15",
    this.betStatus = "All",
  });

  factory FilterState.from(FilterState other) {
    return FilterState(
      selectedSports: List.from(other.selectedSports),
      selectedEvents: Map.from(other.selectedEvents),
      oddsFilter: Map.from(other.oddsFilter),
      stakesFilter: Map.from(other.stakesFilter),
      userFilter: Map.from(other.userFilter),
      ipFilter: Map.from(other.ipFilter),
      orderBy: other.orderBy,
      order: other.order,
      lastTxn: other.lastTxn,
      refreshTime: other.refreshTime,
      betStatus: other.betStatus,
    );
  }

  FilterState copyWith({
    List<String>? selectedSports,
    Map<String, dynamic>? selectedEvents,
    Map<String, dynamic>? oddsFilter,
    Map<String, dynamic>? stakesFilter,
    Map<String, dynamic>? userFilter,
    Map<String, dynamic>? ipFilter,
    String? orderBy,
    String? order,
    String? lastTxn,
    String? refreshTime,
    String? betStatus,
  }) {
    return FilterState(
      selectedSports: selectedSports ?? List.from(this.selectedSports),
      selectedEvents: selectedEvents ?? Map.from(this.selectedEvents),
      oddsFilter: oddsFilter ?? Map.from(this.oddsFilter),
      stakesFilter: stakesFilter ?? Map.from(this.stakesFilter),
      userFilter: userFilter ?? Map.from(this.userFilter),
      ipFilter: ipFilter ?? Map.from(this.ipFilter),
      orderBy: orderBy ?? this.orderBy,
      order: order ?? this.order,
      lastTxn: lastTxn ?? this.lastTxn,
      refreshTime: refreshTime ?? this.refreshTime,
      betStatus: betStatus ?? this.betStatus,
    );
  }
}
