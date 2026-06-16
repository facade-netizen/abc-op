import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../model/bet_list_model.dart';
import '../../reusable/formatters.dart';

bool isSportsbookSports(List<String> sports) => sports.isNotEmpty && sports.every((s) => s.startsWith('sportsbook '));

class FetchBetListLiveBloc extends Bloc<FetchBetListLiveEvent, FetchBetListLiveState> {
  final OrdersApiRepository _ordersApiRepository;
  final CGApiRepository _cgApiRepository;
  Timer? _autoRefreshTimer;

  FetchParameters? _currentParams;
  final Set<int> _requestedPages = {};
  final Map<int, BetData> _betsCache = {}; // Use Map for O(1) lookups
  bool _isLoading = false;

  FetchBetListLiveBloc(this._ordersApiRepository, this._cgApiRepository) : super(FetchBetListLiveInitial()) {
    on<FetchBetListLive>(_onFetchBetList);
    on<FetchBetListLiveInt>((event, emit) => emit(FetchBetListLiveInitial()));
    on<ResetBetListLive>(_onReset);
    on<StartAutoRefresh>(_onStartAutoRefresh);
    on<StopAutoRefresh>(_onStopAutoRefresh);
    on<UpdateFetchParameters>(_onUpdateParameters);
    on<ClearRequestedPages>(_onClearPages);
    on<LoadMoreBetList>(_onLoadMore);
  }

  Future<void> _onFetchBetList(FetchBetListLive event, Emitter<FetchBetListLiveState> emit) async {
    final pageToFetch = event.page ?? 1;

    // Prevent duplicate requests
    if (!event.isRefresh && _requestedPages.contains(pageToFetch)) {
      return;
    }

    // Prevent concurrent requests
    if (_isLoading) return;

    // Clear state on filter change
    if (event.isFilterChange) {
      _requestedPages.clear();
      _betsCache.clear();
    }

    final savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
    if (savedTokenData == null) {
      emit(const FetchBetListLiveFailure('Your session has expired. Please log in again to proceed.'));
      return;
    }

    _isLoading = true;

    // Update loading state
    if (state is FetchBetListLiveSuccess) {
      final currentState = state as FetchBetListLiveSuccess;
      if (event.isRefresh) {
        emit(currentState.copyWith(isLoading: true));
      } else {
        emit(currentState.copyWith(isLoadingMore: true));
      }
    }

    try {
      _currentParams = FetchParameters(
        userName: event.userId,
        sports: event.sports,
        ip: event.ip,
        isp: event.isp,
        column: event.column,
        isAscending: event.isAscending,
        page: pageToFetch,
        limit: event.limit ?? 5,
        eventIds: event.eventIds,
        marketIds: event.marketIds,
        diffOdds: event.diffOdds,
        oddDiffGreater: event.oddDiffGreater,
        stake: event.stake,
        stakeGreater: event.stakeGreater,
      );

      _requestedPages.add(pageToFetch);
      DateTime fromDate = DateTime.now().subtract(Duration(days: 90));
      DateTime toDate = DateTime.now();

      final BetResponse response;
      if (isSportsbookSports(event.sports)) {
        final sbSports = event.sports.map((s) => s.replaceFirst('sportsbook ', '')).join(',');
        response = await _cgApiRepository.getCGSportsBookBetList(
          userName: event.userId,
          page: pageToFetch,
          limit: event.limit ?? 5,
          status: 'open',
          sport: sbSports,
          from: fromToDateTimeString(fromDate.toIso8601String(), startOfDay: true),
          to: fromToDateTimeString(toDate.toIso8601String(), startOfDay: false),
          ip: event.ip,
          isp: event.isp,
          stake: (event.stake != null) ? event.stake.toString() : null,
          column: event.column,
          isAscending: event.isAscending,
          stakeGreater: event.stakeGreater,
          eventIds: event.eventIds,
          marketIds: event.marketIds,
          oddDiff: (event.diffOdds ?? '').toString(),
          oddDiffGreater: event.oddDiffGreater,
        );
      } else {
        response = await _ordersApiRepository.getBetList(
          isDone: false,
          status: 'new',
          userName: event.userId,
          sports: event.sports,
          ip: event.ip,
          isp: event.isp,
          column: event.column,
          isAscending: event.isAscending,
          page: pageToFetch,
          limit: event.limit ?? 5,
          eventIds: event.eventIds,
          marketIds: event.marketIds,
          diffOdds: event.diffOdds,
          oddDiffGreater: event.oddDiffGreater,
          stake: event.stake,
          stakeGreater: event.stakeGreater,
          from: stringDateToDateTimeString(fromDate.toIso8601String(), startOfDay: true),
          to: stringDateToDateTimeString(toDate.toIso8601String(), startOfDay: false),
        );
      }

      if (response.status.toLowerCase() == "success") {
        // Update cache with O(1) complexity
        for (var bet in response.data) {
          _betsCache[bet.betId] = bet;
        }

        final hasMore = response.data.length == (event.limit ?? 5);
        final betsList = _betsCache.values.toList();

        emit(FetchBetListLiveSuccess(betsList: betsList, currentPage: pageToFetch, hasMore: hasMore, isLoading: false, isLoadingMore: false));

        // Auto-stop refresh if no more data
        if (!hasMore && _autoRefreshTimer != null) {
          add(const StopAutoRefresh());
        }
      } else {
        _handleError(emit, 'Failed to fetch: ${response.status}');
      }
    } catch (e) {
      _handleError(emit, e.toString());
    } finally {
      _isLoading = false;
      _requestedPages.remove(pageToFetch);
    }
  }

  void _onLoadMore(LoadMoreBetList event, Emitter<FetchBetListLiveState> emit) {
    final currentState = state;
    if (currentState is FetchBetListLiveSuccess && currentState.hasMore && !currentState.isLoadingMore && !_isLoading) {
      add(
        FetchBetListLive(
          userId: _currentParams?.userName,
          sports: _currentParams?.sports ?? [],
          ip: _currentParams?.ip,
          isp: _currentParams?.isp,
          column: _currentParams?.column,
          isAscending: _currentParams?.isAscending,
          page: currentState.currentPage + 1,
          limit: _currentParams?.limit ?? 5,
          isRefresh: false,
          isFilterChange: false,
        ),
      );
    }
  }

  void _handleError(Emitter<FetchBetListLiveState> emit, String error) {
    if (_betsCache.isNotEmpty) {
      final currentState = state;
      final currentPage = currentState is FetchBetListLiveSuccess ? currentState.currentPage : 1;
      final hasMore = currentState is FetchBetListLiveSuccess ? currentState.hasMore : true;

      emit(FetchBetListLiveSuccess(betsList: _betsCache.values.toList(), currentPage: currentPage, hasMore: hasMore, isLoading: false, isLoadingMore: false, error: error));
    } else {
      emit(FetchBetListLiveFailure(error));
    }
  }

  void _onReset(ResetBetListLive event, Emitter<FetchBetListLiveState> emit) {
    _stopAutoRefresh();
    _currentParams = null;
    _requestedPages.clear();
    _betsCache.clear();
    _isLoading = false;
    emit(FetchBetListLiveInitial());
  }

  void _onStartAutoRefresh(StartAutoRefresh event, Emitter<FetchBetListLiveState> emit) {
    _stopAutoRefresh();

    if (event.intervalSeconds > 0) {
      _autoRefreshTimer = Timer.periodic(Duration(seconds: event.intervalSeconds), (_) => _performAutoRefresh());
    }
  }

  void _performAutoRefresh() {
    if (isClosed || _isLoading) return;

    final currentState = state;
    if (currentState is! FetchBetListLiveSuccess) return;

    // Don't trigger if already loading
    if (currentState.isLoadingMore || currentState.isLoading) return;

    if (currentState.hasMore) {
      add(LoadMoreBetList());
    } else {
      add(
        FetchBetListLive(
          userId: _currentParams?.userName,
          sports: _currentParams?.sports ?? [],
          ip: _currentParams?.ip,
          isp: _currentParams?.isp,
          column: _currentParams?.column,
          isAscending: _currentParams?.isAscending,
          page: 1,
          limit: _currentParams?.limit ?? 5,
          eventIds: _currentParams?.eventIds,
          marketIds: _currentParams?.marketIds,
          diffOdds: _currentParams?.diffOdds,
          oddDiffGreater: _currentParams?.oddDiffGreater,
          stake: _currentParams?.stake,
          stakeGreater: _currentParams?.stakeGreater,
          isRefresh: true,
          isFilterChange: false,
        ),
      );
    }
  }

  void _onStopAutoRefresh(StopAutoRefresh event, Emitter<FetchBetListLiveState> emit) {
    _stopAutoRefresh();
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  void _onUpdateParameters(UpdateFetchParameters event, Emitter<FetchBetListLiveState> emit) {
    _currentParams = event.params;
  }

  void _onClearPages(ClearRequestedPages event, Emitter<FetchBetListLiveState> emit) {
    _requestedPages.clear();
  }

  @override
  Future<void> close() {
    _stopAutoRefresh();
    _betsCache.clear();
    _requestedPages.clear();
    return super.close();
  }
}

abstract class FetchBetListLiveEvent {
  const FetchBetListLiveEvent();
}

class FetchBetListLive extends FetchBetListLiveEvent {
  final String? userId;
  final int? page;
  final int? limit;
  final List<String> sports;
  final String? ip;
  final String? isp;
  final String? column;
  final bool? isAscending;
  final bool isRefresh;
  final bool isFilterChange;
  final double? diffOdds;
  final bool? oddDiffGreater;
  final String? eventIds;
  final String? marketIds;
  final double? stake;
  final bool? stakeGreater;

  const FetchBetListLive({
    this.userId,
    this.page,
    this.limit = 5,
    this.sports = const [],
    this.ip,
    this.isp,
    this.column,
    this.isAscending,
    this.isRefresh = false,
    this.isFilterChange = false,
    this.diffOdds,
    this.oddDiffGreater,
    this.eventIds,
    this.marketIds,
    this.stake,
    this.stakeGreater,
  });
}

class LoadMoreBetList extends FetchBetListLiveEvent {
  const LoadMoreBetList();
}

class FetchBetListLiveInt extends FetchBetListLiveEvent {
  const FetchBetListLiveInt();
}

class ResetBetListLive extends FetchBetListLiveEvent {
  const ResetBetListLive();
}

class StartAutoRefresh extends FetchBetListLiveEvent {
  final int intervalSeconds;
  const StartAutoRefresh(this.intervalSeconds);
}

class StopAutoRefresh extends FetchBetListLiveEvent {
  const StopAutoRefresh();
}

class UpdateFetchParameters extends FetchBetListLiveEvent {
  final FetchParameters params;
  const UpdateFetchParameters(this.params);
}

class ClearRequestedPages extends FetchBetListLiveEvent {
  const ClearRequestedPages();
}

class FetchParameters {
  final String? userName;
  final List<String> sports;
  final String? ip;
  final String? isp;
  final String? column;
  final bool? isAscending;
  final int page;
  final int limit;
  final String? eventIds;
  final String? marketIds;
  final double? diffOdds;
  final bool? oddDiffGreater;
  final double? stake;
  final bool? stakeGreater;
  const FetchParameters({
    this.userName,
    this.sports = const [],
    this.ip,
    this.isp,
    this.column,
    this.isAscending,
    required this.page,
    required this.limit,
    this.eventIds,
    this.marketIds,
    this.diffOdds,
    this.oddDiffGreater,
    this.stake,
    this.stakeGreater,
  });
}

abstract class FetchBetListLiveState {
  const FetchBetListLiveState();
}

class FetchBetListLiveInitial extends FetchBetListLiveState {
  const FetchBetListLiveInitial();
}

class FetchBetListLiveSuccess extends FetchBetListLiveState {
  final List<BetData> betsList;
  final int currentPage;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  const FetchBetListLiveSuccess({required this.betsList, this.currentPage = 1, this.hasMore = true, this.isLoading = false, this.isLoadingMore = false, this.error});

  FetchBetListLiveSuccess copyWith({List<BetData>? betsList, int? currentPage, bool? hasMore, bool? isLoading, bool? isLoadingMore, String? error}) {
    return FetchBetListLiveSuccess(
      betsList: betsList ?? this.betsList,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FetchBetListLiveSuccess &&
        other.currentPage == currentPage &&
        other.hasMore == hasMore &&
        other.isLoading == isLoading &&
        other.isLoadingMore == isLoadingMore &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(currentPage, hasMore, isLoading, isLoadingMore, error);
  }
}

class FetchBetListLiveFailure extends FetchBetListLiveState {
  final dynamic error;
  const FetchBetListLiveFailure(this.error);
}
