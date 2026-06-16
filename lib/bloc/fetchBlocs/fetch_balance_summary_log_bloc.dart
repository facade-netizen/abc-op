import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/balance_summary_logs_model.dart';
import 'handle_error.dart';

class FetchBalanceSummaryLogBloc extends Bloc<FetchBalanceSummaryLogEvent, FetchBalanceSummaryLogState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchBalanceSummaryLogBloc(this._ordersApiRepository) : super(FetchBalanceSummaryLogInitial()) {
    on<FetchBalanceSummaryLog>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchBalanceSummaryLogBloc');
      emit(FetchBalanceSummaryLogProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final response = event.isNegativeAfterBalanceLog
              ? await _ordersApiRepository.getNegativeBalanceLogsSummary(body: event.getPlayerData)
              : await _ordersApiRepository.getBalanceLogsSummary(body: event.getPlayerData);
          if (response.status == "success" && response.data.isNotEmpty) {
            emit(FetchBalanceSummaryLogSuccess(summaryItems: response.data, response: response));
          } else {
            if (kDebugMode) debugPrint("fetch_balance_summary_log_bloc.dart [response error]>> \\${response.status}");
            emit(FetchBalanceSummaryLogFailure('Data not found'));
          }
        } else {
          emit(FetchBalanceSummaryLogFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_balance_summary_log_bloc.dart [Try Block Exception]>> \n $e');
        emit(FetchBalanceSummaryLogFailure(handleError(e)));
      }
    });
    on<FetchBalanceSummaryLogInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchBalanceSummaryLogInt');
      emit(FetchBalanceSummaryLogInitial());
    });
  }
}

// states
abstract class FetchBalanceSummaryLogState {}

// events
abstract class FetchBalanceSummaryLogEvent {}

// states implementation
class FetchBalanceSummaryLogInitial extends FetchBalanceSummaryLogState {}

class FetchBalanceSummaryLogProgress extends FetchBalanceSummaryLogState {}

class FetchBalanceSummaryLogSuccess extends FetchBalanceSummaryLogState {
  FetchBalanceSummaryLogSuccess({
    required this.summaryItems,
    required this.response,
  });
  final List<BalanceLogSummaryItem> summaryItems;
  final BalanceLogSummaryResponse response;
}

class FetchBalanceSummaryLogFailure extends FetchBalanceSummaryLogState {
  FetchBalanceSummaryLogFailure(this.error);
  final String error;
}

// events implementation
class FetchBalanceSummaryLog extends FetchBalanceSummaryLogEvent {
  FetchBalanceSummaryLog({required this.getPlayerData, required this.isNegativeAfterBalanceLog});
  Map<String, dynamic> getPlayerData;
  final bool isNegativeAfterBalanceLog;
}

class FetchBalanceSummaryLogInt extends FetchBalanceSummaryLogEvent {}
