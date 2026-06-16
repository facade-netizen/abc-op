import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../model/order_events_model.dart';
import '../../reusable/formatters.dart';
import 'handle_error.dart';

bool isSportsbookSports(List<String> sports) => sports.isNotEmpty && sports.any((s) => s.toLowerCase().startsWith('sportsbook'));

class FetchBetListLiveEventsBloc extends Bloc<FetchBetListLiveEventsEvent, FetchBetListLiveEventsState> {
  final OrdersApiRepository _ordersApiRepository;
  final CGApiRepository _cgApiRepository;
  Timer? _autoRefreshTimer;

  FetchParametersLiveEvents? _currentParams;
  final Set<int> _requestedPages = {};
  final Map<String, OrderEventData> _eventsCache = {};
  bool _isLoading = false;

  FetchBetListLiveEventsBloc(this._ordersApiRepository, this._cgApiRepository) : super(FetchBetListLiveEventsInitial()) {
    on<FetchBetListLiveEvents>(_onFetchBetListLiveEvents);
    on<FetchBetListLiveEventsInt>((event, emit) => emit(FetchBetListLiveEventsInitial()));
    on<ResetBetListLiveEvents>(_onReset);
    on<StartAutoRefreshLiveEvents>(_onStartAutoRefresh);
    on<StopAutoRefreshLiveEvents>(_onStopAutoRefresh);
    on<UpdateFetchParametersLiveEvents>(_onUpdateParameters);
    on<ClearRequestedPagesLiveEvents>(_onClearPages);
    on<LoadMoreBetListLiveEvents>(_onLoadMore);
  }

  Future<void> _onFetchBetListLiveEvents(FetchBetListLiveEvents event, Emitter<FetchBetListLiveEventsState> emit) async {
    final pageToFetch = event.page ?? 1;

    if (!event.isRefresh && _requestedPages.contains(pageToFetch)) {
      return;
    }

    if (_isLoading) return;

    if (event.isFilterChange) {
      _requestedPages.clear();
      _eventsCache.clear();
    }

    final savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
    if (savedTokenData == null) {
      emit(FetchBetListLiveEventsFailure('Your session has expired. Please log in again to proceed.'));
      return;
    }

    _isLoading = true;
    emit(FetchBetListLiveEventsProgress());

    if (_currentParams == null || event.isFilterChange) {
      _currentParams = FetchParametersLiveEvents(
        userId: event.userId,
        sports: event.sports,
        ip: event.ip,
        isp: event.isp,
        column: event.column,
        isAscending: event.isAscending,
        page: pageToFetch,
        limit: event.limit ?? 50,
        eventIds: event.eventIds,
        marketIds: event.marketIds,
        betIds: event.betIds,
        status: event.status,
        isDone: event.isDone,
        bettingType: event.bettingType,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );
    }

    _requestedPages.add(pageToFetch);

    if (state is FetchBetListLiveEventsSuccess) {
      final currentState = state as FetchBetListLiveEventsSuccess;
      if (event.isRefresh) {
        emit(currentState.copyWith(isLoading: true));
      } else {
        emit(currentState.copyWith(isLoadingMore: true));
      }
    }

    try {
      final bool isSportsBook = isSportsbookSports(event.sports);
      final String? requestStatus = event.status?.toLowerCase();
      final String? sportsbookStatus = requestStatus == null
          ? null
          : requestStatus == 'new'
              ? 'open'
              : requestStatus;
      final String sportsbookSport =
          event.sports.map((sport) => sport.replaceAll(RegExp(r'^sportsbook\s*', caseSensitive: false), '').toLowerCase()).where((sport) => sport.isNotEmpty).join(',');

      if (kDebugMode) {
        debugPrint('FetchBetListLiveEventsBloc branch: ${isSportsBook ? 'CG sportsbook' : 'orders'}');
      }

      final OrderEventResponse response = isSportsBook
          ? await _cgApiRepository.getSportBookBetEventsList(
              status: sportsbookStatus,
              sport: sportsbookSport.isNotEmpty ? sportsbookSport : null,
              from: (event.fromDate != null) ? fromToDateTimeString(event.fromDate!, startOfDay: true) : null,
              to: (event.toDate != null) ? fromToDateTimeString(event.toDate!, startOfDay: false) : null,
              page: pageToFetch,
              userName: event.userId,
              limit: event.limit ?? 50,
              orderIds: event.betIds,
              marketIds: event.marketIds,
              eventIds: event.eventIds,
              ip: event.ip,
              isp: event.isp,
            )
          : await _ordersApiRepository.getOrderEventsList(
              userName: event.userId,
              from: (event.fromDate != null) ? stringDateToDateTimeString(event.fromDate!, startOfDay: true) : null,
              to: (event.toDate != null) ? stringDateToDateTimeString(event.toDate!) : null,
              sid: event.sid,
              marketIds: event.marketIds,
              eventIds: event.eventIds,
              isDone: event.isDone,
              bettingType: event.bettingType,
              page: pageToFetch,
              limit: event.limit ?? 50,
              status: event.status,
              sports: event.sports,
              ip: event.ip,
              isp: event.isp,
              column: event.column,
              isAscending: event.isAscending,
              betIds: event.betIds,
            );

      if (response.status == 200) {
        if (response.data.isNotEmpty) {
          for (var eventData in response.data) {
            if (eventData.eventId.isNotEmpty) {
              _eventsCache[eventData.eventId] = eventData;
            }
          }
        }

        final hasMore = response.data.length == (event.limit ?? 50);
        final eventsList = _eventsCache.values.toList();

        emit(FetchBetListLiveEventsSuccess(
          events: eventsList,
          currentPage: pageToFetch,
          hasMore: hasMore,
          isLoading: false,
          isLoadingMore: false,
        ));
      } else {
        _handleError(emit, response.message.isNotEmpty ? response.message : 'Failed to fetch order events. Please try again.');
      }
    } catch (e) {
      _handleError(emit, handleError(e));
    } finally {
      _isLoading = false;
      _requestedPages.remove(pageToFetch);
    }
  }

  void _onLoadMore(LoadMoreBetListLiveEvents event, Emitter<FetchBetListLiveEventsState> emit) {
    if (_isLoading || _currentParams == null) return;

    final currentState = state;
    final currentPage = currentState is FetchBetListLiveEventsSuccess ? currentState.currentPage : _currentParams!.page;
    final hasMore = currentState is FetchBetListLiveEventsSuccess ? currentState.hasMore : true;
    final isLoadingMore = currentState is FetchBetListLiveEventsSuccess ? currentState.isLoadingMore : false;

    if (!hasMore || isLoadingMore) return;

    add(
      FetchBetListLiveEvents(
        userId: _currentParams?.userId,
        sports: _currentParams?.sports ?? [],
        ip: _currentParams?.ip,
        isp: _currentParams?.isp,
        column: _currentParams?.column,
        isAscending: _currentParams?.isAscending,
        page: currentPage + 1,
        limit: _currentParams?.limit ?? 50,
        eventIds: _currentParams?.eventIds,
        marketIds: _currentParams?.marketIds,
        status: _currentParams?.status,
        isDone: _currentParams?.isDone,
        bettingType: _currentParams?.bettingType,
        betIds: _currentParams?.betIds,
        fromDate: _currentParams?.fromDate,
        toDate: _currentParams?.toDate,
        isRefresh: false,
        isFilterChange: false,
      ),
    );
  }

  void _handleError(Emitter<FetchBetListLiveEventsState> emit, String error) {
    if (_eventsCache.isNotEmpty) {
      final currentState = state;
      final currentPage = currentState is FetchBetListLiveEventsSuccess ? currentState.currentPage : 1;
      final hasMore = currentState is FetchBetListLiveEventsSuccess ? currentState.hasMore : true;

      emit(FetchBetListLiveEventsSuccess(
        events: _eventsCache.values.toList(),
        currentPage: currentPage,
        hasMore: hasMore,
        isLoading: false,
        isLoadingMore: false,
        error: error,
      ));
    } else {
      emit(FetchBetListLiveEventsFailure(error));
    }
  }

  void _onReset(ResetBetListLiveEvents event, Emitter<FetchBetListLiveEventsState> emit) {
    _stopAutoRefresh();
    _currentParams = null;
    _requestedPages.clear();
    _eventsCache.clear();
    _isLoading = false;
    emit(FetchBetListLiveEventsInitial());
  }

  void _onStartAutoRefresh(StartAutoRefreshLiveEvents event, Emitter<FetchBetListLiveEventsState> emit) {
    _stopAutoRefresh();

    if (event.intervalSeconds > 0) {
      _autoRefreshTimer = Timer.periodic(Duration(seconds: event.intervalSeconds), (_) => _performAutoRefresh());
    }
  }

  void _performAutoRefresh() {
    if (isClosed || _isLoading || _currentParams == null) return;

    final currentState = state;
    final isLoadingMore = currentState is FetchBetListLiveEventsSuccess ? currentState.isLoadingMore : false;
    final isLoading = currentState is FetchBetListLiveEventsSuccess ? currentState.isLoading : false;
    if (isLoadingMore || isLoading) return;

    if (currentState is FetchBetListLiveEventsSuccess) {
      if (currentState.hasMore) {
        add(const LoadMoreBetListLiveEvents());
        return;
      }
    }

    add(
      FetchBetListLiveEvents(
        userId: _currentParams?.userId,
        sports: _currentParams?.sports ?? [],
        ip: _currentParams?.ip,
        isp: _currentParams?.isp,
        column: _currentParams?.column,
        isAscending: _currentParams?.isAscending,
        page: 1,
        limit: _currentParams?.limit ?? 50,
        eventIds: _currentParams?.eventIds,
        marketIds: _currentParams?.marketIds,
        status: _currentParams?.status,
        isDone: _currentParams?.isDone,
        bettingType: _currentParams?.bettingType,
        betIds: _currentParams?.betIds,
        fromDate: _currentParams?.fromDate,
        toDate: _currentParams?.toDate,
        isRefresh: true,
        isFilterChange: false,
      ),
    );
  }

  void _onStopAutoRefresh(StopAutoRefreshLiveEvents event, Emitter<FetchBetListLiveEventsState> emit) {
    _stopAutoRefresh();
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  void _onUpdateParameters(UpdateFetchParametersLiveEvents event, Emitter<FetchBetListLiveEventsState> emit) {
    _currentParams = event.params;
  }

  void _onClearPages(ClearRequestedPagesLiveEvents event, Emitter<FetchBetListLiveEventsState> emit) {
    _requestedPages.clear();
  }

  @override
  Future<void> close() {
    _stopAutoRefresh();
    _eventsCache.clear();
    _requestedPages.clear();
    return super.close();
  }
}

abstract class FetchBetListLiveEventsState {}

class FetchBetListLiveEventsInitial extends FetchBetListLiveEventsState {}

class FetchBetListLiveEventsProgress extends FetchBetListLiveEventsState {}

class FetchBetListLiveEventsSuccess extends FetchBetListLiveEventsState {
  final List<OrderEventData> events;
  final int currentPage;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  FetchBetListLiveEventsSuccess({
    required this.events,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  FetchBetListLiveEventsSuccess copyWith({
    List<OrderEventData>? events,
    int? currentPage,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return FetchBetListLiveEventsSuccess(
      events: events ?? this.events,
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
    return other is FetchBetListLiveEventsSuccess &&
        other.currentPage == currentPage &&
        other.hasMore == hasMore &&
        other.isLoading == isLoading &&
        other.isLoadingMore == isLoadingMore &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(currentPage, hasMore, isLoading, isLoadingMore, error);
}

class FetchBetListLiveEventsFailure extends FetchBetListLiveEventsState {
  final String error;
  FetchBetListLiveEventsFailure(this.error);
}

abstract class FetchBetListLiveEventsEvent {
  const FetchBetListLiveEventsEvent();
}

class FetchBetListLiveEvents extends FetchBetListLiveEventsEvent {
  final String? fromDate;
  final String? toDate;
  final String? userId;
  final bool? isDone;
  final String? eventIds;
  final String? marketIds;
  final String? status;
  final int? bettingType;
  final int? sid;
  final int? page;
  final int? limit;
  final List<String> sports;
  final String? ip;
  final String? isp;
  final String? column;
  final String? betIds;
  final bool? isAscending;
  final bool isRefresh;
  final bool isFilterChange;

  FetchBetListLiveEvents({
    this.page,
    this.limit = 50,
    this.fromDate,
    this.toDate,
    this.userId,
    this.eventIds,
    this.bettingType,
    this.isDone,
    this.marketIds,
    this.sid,
    this.status,
    this.sports = const [],
    this.ip,
    this.isp,
    this.column,
    this.isAscending,
    this.betIds,
    this.isRefresh = false,
    this.isFilterChange = false,
  });
}

class LoadMoreBetListLiveEvents extends FetchBetListLiveEventsEvent {
  const LoadMoreBetListLiveEvents();
}

class FetchBetListLiveEventsInt extends FetchBetListLiveEventsEvent {
  const FetchBetListLiveEventsInt();
}

class ResetBetListLiveEvents extends FetchBetListLiveEventsEvent {
  const ResetBetListLiveEvents();
}

class StartAutoRefreshLiveEvents extends FetchBetListLiveEventsEvent {
  final int intervalSeconds;
  const StartAutoRefreshLiveEvents(this.intervalSeconds);
}

class StopAutoRefreshLiveEvents extends FetchBetListLiveEventsEvent {
  const StopAutoRefreshLiveEvents();
}

class UpdateFetchParametersLiveEvents extends FetchBetListLiveEventsEvent {
  final FetchParametersLiveEvents params;
  const UpdateFetchParametersLiveEvents(this.params);
}

class ClearRequestedPagesLiveEvents extends FetchBetListLiveEventsEvent {
  const ClearRequestedPagesLiveEvents();
}

class FetchParametersLiveEvents {
  final String? userId;
  final List<String> sports;
  final String? ip;
  final String? isp;
  final String? column;
  final bool? isAscending;
  final int page;
  final int limit;
  final String? eventIds;
  final String? marketIds;
  final String? betIds;
  final String? status;
  final bool? isDone;
  final int? bettingType;
  final String? fromDate;
  final String? toDate;

  const FetchParametersLiveEvents({
    this.userId,
    this.sports = const [],
    this.ip,
    this.isp,
    this.column,
    this.isAscending,
    required this.page,
    required this.limit,
    this.eventIds,
    this.marketIds,
    this.betIds,
    this.status,
    this.isDone,
    this.bettingType,
    this.fromDate,
    this.toDate,
  });
}
