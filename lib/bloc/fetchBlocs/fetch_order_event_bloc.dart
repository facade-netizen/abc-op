import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/order_events_model.dart';
import '../../reusable/formatters.dart';
import 'handle_error.dart';

class FetchOrderEventsBloc extends Bloc<FetchOrderEventsEvent, FetchOrderEventsState> {
  final OrdersApiRepository _ordersApiRepository;
  final CGApiRepository _cgApiRepository;

  FetchOrderEventsBloc(this._ordersApiRepository, this._cgApiRepository) : super(FetchOrderEventsInitial()) {
    on<FetchOrderEvents>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchOrderEventsBloc');
      emit(FetchOrderEventsProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final bool isSportsBook = event.sports.any((sport) => sport.toLowerCase().startsWith('sportsbook'));
          final String? requestStatus = event.status?.toLowerCase();
          final String? sportsbookStatus = requestStatus == null
              ? null
              : requestStatus == 'new'
                  ? 'open'
                  : requestStatus;
          final String sportsbookSport =
              event.sports.map((sport) => sport.replaceAll(RegExp(r'^sportsbook\s*', caseSensitive: false), '').toLowerCase()).where((sport) => sport.isNotEmpty).join(',');
          if (kDebugMode) {
            debugPrint('FetchOrderEventsBloc branch: ${isSportsBook ? 'CG sportsbook' : 'orders'}');
          }
          final response = isSportsBook
              ? await _cgApiRepository.getSportBookBetEventsList(
                  status: sportsbookStatus,
                  sport: sportsbookSport.isNotEmpty ? sportsbookSport : null,
                  from: (event.fromDate != null) ? fromToDateTimeString(event.fromDate!, startOfDay: true) : null,
                  to: (event.toDate != null) ? fromToDateTimeString(event.toDate!, startOfDay: false) : null,
                  page: event.page ?? 1,
                  limit: event.limit ?? 50,
                  orderIds: event.betIds,
                  userName: event.userId,
                  marketIds: event.marketIds,
                  eventIds: event.eventIds,
                  ip: event.ip,
                  isp: event.isp,
                  oddDiff: (event.diffOdds ?? '').toString(),
                  oddDiffGreater: event.oddDiffGreater,
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
                  page: event.page ?? 1,
                  limit: event.limit ?? 50,
                  status: event.status,
                  sports: event.sports,
                  ip: event.ip,
                  isp: event.isp,
                  column: event.column,
                  isAscending: event.isAscending,
                  betIds: event.betIds,
                  stakeGreater: event.stakeGreater,
                  oddDiffGreater: event.oddDiffGreater,
                  stake: event.stake,
                  diffOdds: event.diffOdds,
                  side: event.side,
                );
          if (response.status == 200) {
            if (response.data.isNotEmpty) {
              emit(FetchOrderEventsSuccess(events: response.data, response: response));
            } else if (response.message.isNotEmpty && response.message.toLowerCase() != 'success') {
              emit(FetchOrderEventsFailure(response.message));
            } else {
              emit(FetchOrderEventsFailure('You have no order events in this time period.'));
            }
          } else {
            if (kDebugMode) {
              debugPrint("fetch_order_events_bloc.dart [response error]>> ${response.status}");
            }
            emit(FetchOrderEventsFailure(response.message.isNotEmpty ? response.message : 'Failed to fetch order events. Please try again.'));
          }
        } else {
          emit(FetchOrderEventsFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('fetch_order_events_bloc.dart [Try Block Exception]>> \n $e');
        }
        emit(FetchOrderEventsFailure(handleError(e)));
      }
    });
    on<FetchOrderEventsInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchOrderEventsInt');
      emit(FetchOrderEventsInitial());
    });
  }
}

// states
abstract class FetchOrderEventsState {}

// events
abstract class FetchOrderEventsEvent {}

// states implementation
class FetchOrderEventsInitial extends FetchOrderEventsState {}

class FetchOrderEventsProgress extends FetchOrderEventsState {}

class FetchOrderEventsSuccess extends FetchOrderEventsState {
  FetchOrderEventsSuccess({
    required this.events,
    required this.response,
  });
  final List<OrderEventData> events;
  final OrderEventResponse response;
}

class FetchOrderEventsFailure extends FetchOrderEventsState {
  FetchOrderEventsFailure(this.error);
  final String error;
}

// events implementation
class FetchOrderEvents extends FetchOrderEventsEvent {
  FetchOrderEvents({
    this.fromDate,
    this.toDate,
    this.userId,
    this.isDone,
    this.eventIds,
    this.marketIds,
    this.status,
    this.bettingType,
    this.sid,
    this.page,
    this.limit,
    this.sports = const [],
    this.ip,
    this.isp,
    this.column,
    this.isAscending,
    this.betIds,
    this.stakeGreater,
    this.oddDiffGreater,
    this.stake,
    this.diffOdds,
    this.side,
  });
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
  final bool? stakeGreater;
  final bool? oddDiffGreater;
  final double? stake;
  final double? diffOdds;
  final String? side;
}

class FetchOrderEventsInt extends FetchOrderEventsEvent {}
