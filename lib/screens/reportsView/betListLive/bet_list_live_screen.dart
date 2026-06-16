import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_betlist_live_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_order_event_bloc.dart';
import '../../../reusable/formatters.dart';
import '../../riskView/riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';
import 'bet_list_live_filter.dart';
import 'bet_list_live_table.dart';

class BetListLiveScreen extends StatefulWidget {
  const BetListLiveScreen({super.key});

  @override
  State<BetListLiveScreen> createState() => _BetListLiveScreenState();
}

class _BetListLiveScreenState extends State<BetListLiveScreen> {
  late final FetchBetListLiveBloc _bloc;
  late final ScrollController _scrollController;
  final ValueNotifier<FilterState> _filtersNotifier = ValueNotifier(FilterState());

  // Cache for performance
  late final Map<String, String> _columnNameMap;
  FilterState get _filters => _filtersNotifier.value;
  set _filters(FilterState value) => _filtersNotifier.value = value;
  bool isSportsBookData = false;
  bool get _isSportsBookData => _filters.selectedSports.any((sport) => sport.toLowerCase().contains('sportsbook'));
  @override
  void initState() {
    super.initState();
    _bloc = context.read<FetchBetListLiveBloc>();
    _initializeMaps();
    _scrollController = ScrollController();
    _initializeFilters();
    _setupScrollListener();
    _initialLoad();
  }

  void _initializeMaps() {
    _columnNameMap = {"Stake": "stake", "Player ID": "userName", "Time": "timeStamp"};
  }

  void _initializeFilters() {
    _filters = _filters.copyWith(selectedSports: List.from(defaultSports));
  }

  void _setupScrollListener() {
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _filtersNotifier.dispose();
    _bloc.add(const StopAutoRefresh());
    super.dispose();
  }

  void _initialLoad() {
    _bloc
      ..add(const ResetBetListLive())
      ..add(const ClearRequestedPages());
    _fetch(isRefresh: true);
    _updateAutoRefresh();
  }

  void _resetAndFetch() {
    _bloc.add(const ClearRequestedPages());
    _fetch(isRefresh: true, isFilterChange: true);
    _updateAutoRefresh();
  }

  void _loadMore() {
    final state = _bloc.state;

    if (state is FetchBetListLiveSuccess && state.hasMore && !state.isLoadingMore) {
      _bloc.add(const LoadMoreBetList());
    }
  }

  void _updateAutoRefresh() {
    final refreshTime = _filters.refreshTime;

    if (refreshTime == "Stop") {
      _bloc.add(const StopAutoRefresh());
    } else {
      final interval = int.tryParse(refreshTime) ?? 15;
      _bloc.add(StartAutoRefresh(interval));
    }
  }

  void _fetch({bool isRefresh = false, bool isFilterChange = false}) {
    setState(() {
      isSportsBookData = _isSportsBookData;
    });
    if (_filters.betStatus == 'Unmatched') {
      _bloc.add(const ResetBetListLive());
      return;
    }

    final params = _buildFetchParameters();

    _bloc.add(
      FetchBetListLive(
        userId: params.userName,
        sports: params.sports,
        ip: params.ip,
        isp: params.isp,
        column: params.column,
        isAscending: params.isAscending,
        limit: params.limit,
        page: 1,
        isRefresh: isRefresh,
        isFilterChange: isFilterChange,
        eventIds: params.eventIds,
        marketIds: params.marketIds,
        diffOdds: params.diffOdds,
        oddDiffGreater: params.oddDiffGreater,
        stake: params.stake,
        stakeGreater: params.stakeGreater,
      ),
    );
    DateTime fromDate = DateTime.now().subtract(Duration(days: 90));
    DateTime toDate = DateTime.now();

    ///call to fetch order events for matched bets to show
    context.read<FetchOrderEventsBloc>().add(
      FetchOrderEvents(
        fromDate: fromToDateTimeString(fromDate.toIso8601String(), startOfDay: true),
        toDate: fromToDateTimeString(toDate.toIso8601String(), startOfDay: false),
        isDone: false,
        status: 'new',
        userId: params.userName,
        // ip: params.ip,
        // isp: params.isp,
        // eventIds: params.eventIds,
        // marketIds: params.marketIds,
        page: 1,
        limit: 1000,
        sports: params.sports,
      ),
    );
  }

  FetchParameters _buildFetchParameters() {
    final ipFilter = _filters.ipFilter;
    final isIpEnabled = ipFilter['switchStatus'] == true;
    final oddsFilter = _filters.oddsFilter;
    final stakesFilter = _filters.stakesFilter;
    final isStakeEnabled = stakesFilter['switchStatus'] == true;

    double? stake;
    bool? stakeGreater;
    if (isStakeEnabled) {
      stake = double.tryParse('${stakesFilter['stake'] ?? ''}');
      stakeGreater = stake != null ? true : null;
    }

    double? diffOdds;
    bool? oddDiffGreater;
    final backGreater = double.tryParse('${oddsFilter['backGreater'] ?? ''}');
    final backLower = double.tryParse('${oddsFilter['backLower'] ?? ''}');
    final layGreater = double.tryParse('${oddsFilter['layGreater'] ?? ''}');
    final layLower = double.tryParse('${oddsFilter['layLower'] ?? ''}');
    if (backGreater != null) {
      diffOdds = backGreater;
      oddDiffGreater = true;
    } else if (backLower != null) {
      diffOdds = backLower;
      oddDiffGreater = false;
    } else if (layGreater != null) {
      diffOdds = layGreater;
      oddDiffGreater = true;
    } else if (layLower != null) {
      diffOdds = layLower;
      oddDiffGreater = false;
    }

    return FetchParameters(
      userName: _filters.userFilter['switchStatus'] == true ? _filters.userFilter['userId'] : null,
      sports: _filters.selectedSports,
      ip: isIpEnabled ? ipFilter['ipValue'] : null,
      isp: isIpEnabled ? ipFilter['ispValue'] : null,
      column: _columnNameMap[_filters.orderBy] ?? "stake",
      isAscending: _filters.order == "Ascending",
      page: 1,
      limit: int.tryParse(_filters.lastTxn.split(' ').first) ?? 5,
      eventIds: (_filters.selectedEvents['eventIds'] as Set?)?.isNotEmpty == true ? (_filters.selectedEvents['eventIds'] as Set).join(',') : null,
      marketIds: (_filters.selectedEvents['marketIds'] as Set?)?.isNotEmpty == true ? (_filters.selectedEvents['marketIds'] as Set).join(',') : null,
      diffOdds: diffOdds,
      oddDiffGreater: oddDiffGreater,
      stake: stake,
      stakeGreater: stakeGreater,
    );
  }

  void _updateFilter(void Function(FilterState) update) {
    final newFilters = FilterState.from(_filters);
    update(newFilters);
    _filters = newFilters;
  }

  void _handleSportChange(bool isAll, String sportValue, bool value) {
    _updateFilter((filters) {
      if (isAll) {
        filters.selectedSports = value ? List.from(defaultSports) : ['cricket'];
      } else {
        if (value) {
          final newGroup = getSportGroup(sportValue);
          final currentGroup = filters.selectedSports.isNotEmpty ? getSportGroup(filters.selectedSports.first) : SportGroup.regular;
          if (newGroup != currentGroup) {
            // Switch group → clear previous selections, select only this sport
            filters.selectedSports = [sportValue];
          } else {
            filters.selectedSports.add(sportValue);
          }
        } else {
          filters.selectedSports.remove(sportValue);
          if (filters.selectedSports.isEmpty) {
            filters.selectedSports = ['cricket'];
          }
        }
      }
    });
    _resetAndFetch();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RiskHeader(type: 1, title: "Bet List Live"),
              FilterSection(
                filtersNotifier: _filtersNotifier,
                onSportChange: _handleSportChange,
                onFilterUpdate: _updateFilter,
                onResetAndFetch: _resetAndFetch,
                onUpdateAutoRefresh: _updateAutoRefresh,
              ),
              ValueListenableBuilder<FilterState>(
                valueListenable: _filtersNotifier,
                builder: (context, filters, _) => TableSection(filters: filters, isSportsBook: _isSportsBookData),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
