import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class FetchRiskMonitoringBloc extends Bloc<FetchRiskMonitoringEvent, FetchRiskMonitoringState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchRiskMonitoringBloc(this._ordersApiRepository) : super(FetchRiskMonitoringInitial()) {
    on<FetchRiskMonitoring>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchRiskMonitoringBloc');
      emit(FetchRiskMonitoringProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final response = await _ordersApiRepository.getRiskMonitoring(
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
            sameSelectionBL: event.sameSelectionBL,
            diffSelectionBB: event.diffSelectionBB,
            diffSelectionLL: event.diffSelectionLL,
            timePeriod: event.timePeriod,
          );
       
          if (response.status.toLowerCase() == "success") {
            if (response.data.isNotEmpty) {
              emit(FetchRiskMonitoringSuccess(betsList: response.data, response: response));
            } else if (response.status.isNotEmpty && response.status.toLowerCase() != 'success') {
              emit(FetchRiskMonitoringFailure(response.status));
            } else {
              emit(FetchRiskMonitoringFailure('You have no bets in this time period.'));
            }
          } else {
            if (kDebugMode) debugPrint("fetch_risk_monitoring_bloc.dart [response error]>> ${response.status}");
            emit(FetchRiskMonitoringFailure(response.status));
          }
        } else {
          emit(FetchRiskMonitoringFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_risk_monitoring_bloc.dart [Try Block Exception]>> \n $e');
        emit(FetchRiskMonitoringFailure(handleError(e)));
      }
    });
    on<FetchRiskMonitoringInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchRiskMonitoringInt');
      emit(FetchRiskMonitoringInitial());
    });
  }
}

// states
abstract class FetchRiskMonitoringState {}

// events
abstract class FetchRiskMonitoringEvent {}

// states implementation
class FetchRiskMonitoringInitial extends FetchRiskMonitoringState {}

class FetchRiskMonitoringProgress extends FetchRiskMonitoringState {}

class FetchRiskMonitoringSuccess extends FetchRiskMonitoringState {
  FetchRiskMonitoringSuccess({
    required this.betsList,
    required this.response,
  });
  final List<BetData> betsList;
  final BetResponse response;
}

class FetchRiskMonitoringFailure extends FetchRiskMonitoringState {
  FetchRiskMonitoringFailure(this.error);
  final String error;
}

// events implementation
class FetchRiskMonitoring extends FetchRiskMonitoringEvent {
  FetchRiskMonitoring({
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
    this.sameSelectionBL,
    this.diffSelectionBB,
    this.diffSelectionLL,
    this.timePeriod,
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
  final bool? sameSelectionBL;
  final bool? diffSelectionBB;
  final bool? diffSelectionLL;
  final int? timePeriod;
}

class FetchRiskMonitoringInt extends FetchRiskMonitoringEvent {}
