import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/bet_list_model.dart';
import '../../reusable/formatters.dart';
import 'handle_error.dart';

String? joinIds(dynamic ids) {
  if (ids == null) return null;
  if (ids is Set) return ids.join(',');
  if (ids is Iterable) return ids.join(',');
  return ids.toString();
}

class FetchBetListBloc extends Bloc<FetchBetListEvent, FetchBetListState> {
  final OrdersApiRepository _ordersApiRepository;
  final CGApiRepository _cgApiRepository;

  FetchBetListBloc(this._ordersApiRepository, this._cgApiRepository) : super(FetchBetListInitial()) {
    on<FetchBetList>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchBetListBloc');
      emit(FetchBetListProgress());
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

          final response = isSportsBook
              ? await _cgApiRepository.getCGSportsBookBetList(
                  from: event.fromDate != null ? fromToDateTimeString(event.fromDate!, startOfDay: true) : null,
                  to: event.toDate != null ? fromToDateTimeString(event.toDate!, startOfDay: false) : null,
                  status: sportsbookStatus,
                  sport: sportsbookSport.isNotEmpty ? sportsbookSport : null,
                  userName: event.userId,
                  page: event.page ?? 1,
                  limit: event.limit ?? 50,
                  marketIds: event.marketIds,
                  eventIds: event.eventIds,
                  ip: event.ip,
                  isp: event.isp,
                  oddDiff: (event.diffOdds ?? '').toString(),
                  oddDiffGreater: event.oddDiffGreater,
                )
              : await _ordersApiRepository.getBetList(
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
                  ip: event.ip,
                  isp: event.isp,
                  column: event.column,
                  isAscending: event.isAscending,
                  betIds: event.betIds,
                  stake: event.stake,
                  diffOdds: event.diffOdds,
                  stakeGreater: event.stakeGreater,
                  oddDiffGreater: event.oddDiffGreater,
                  side: event.side,
                );
          if (response.status.toLowerCase() == "success") {
            if (response.data.isNotEmpty) {
              emit(FetchBetListSuccess(betsList: response.data, response: response));
            } else if (response.status.isNotEmpty && response.status.toLowerCase() != 'success') {
              emit(FetchBetListFailure(response.status));
            } else {
              emit(FetchBetListFailure('You have no bets in this time period.'));
            }
          } else {
            if (kDebugMode) debugPrint("fetch_betlist_bloc.dart [response error]>> ${response.status}");
            emit(FetchBetListFailure(response.status));
          }
        } else {
          emit(FetchBetListFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_betlist_bloc.dart.dart [Try Block Exception]>> \n $e');
        emit(FetchBetListFailure(handleError(e)));
      }
    });
    on<FetchBetListInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchBetListInt');
      emit(FetchBetListInitial());
    });
  }
}

// states
abstract class FetchBetListState {}

// events
abstract class FetchBetListEvent {}

// states implementation
class FetchBetListInitial extends FetchBetListState {}

class FetchBetListProgress extends FetchBetListState {}

class FetchBetListSuccess extends FetchBetListState {
  FetchBetListSuccess({
    required this.betsList,
    required this.response,
  });
  final List<BetData> betsList;
  final BetResponse response;
}

class FetchBetListFailure extends FetchBetListState {
  FetchBetListFailure(this.error);
  final String error;
}

// events implementation
class FetchBetList extends FetchBetListEvent {
  FetchBetList({
    this.page,
    this.limit,
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

class FetchBetListInt extends FetchBetListEvent {}
