import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/runner_wise_report_model.dart';
import 'handle_error.dart';

class FetchRunnerWiseReportBloc extends Bloc<FetchRunnerWiseReportEvent, FetchRunnerWiseReportState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchRunnerWiseReportBloc(this._ordersApiRepository) : super(FetchRunnerWiseReportInitial()) {
    on<FetchRunnerWiseReport>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchRunnerWiseReportBloc');
      emit(FetchRunnerWiseReportProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final response = await _ordersApiRepository.getRunnerWiseReport(
            marketId: event.marketId,
            runnerId: event.runnerId,
            userName: event.userName,
          );
          if (response.status == 200) {
            emit(FetchRunnerWiseReportSuccess(reports: response.data));
          } else {
            if (kDebugMode) debugPrint("fetch_runner_wise_report_bloc.dart [response error]>> ${response.status}");
            emit(FetchRunnerWiseReportFailure(response.message));
          }
        } else {
          emit(FetchRunnerWiseReportFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_runner_wise_report_bloc.dart [Try Block Exception]>> \n $e');
        emit(FetchRunnerWiseReportFailure(handleError(e)));
      }
    });

    on<FetchRunnerWiseReportInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchRunnerWiseReportInt');
      emit(FetchRunnerWiseReportInitial());
    });
  }
}

// states
abstract class FetchRunnerWiseReportState {}

// events
abstract class FetchRunnerWiseReportEvent {}

// states implementation
class FetchRunnerWiseReportInitial extends FetchRunnerWiseReportState {}

class FetchRunnerWiseReportProgress extends FetchRunnerWiseReportState {}

class FetchRunnerWiseReportSuccess extends FetchRunnerWiseReportState {
  FetchRunnerWiseReportSuccess({required this.reports});
  final RunnerWiseReportData reports;
}

class FetchRunnerWiseReportFailure extends FetchRunnerWiseReportState {
  FetchRunnerWiseReportFailure(this.error);
  final String error;
}

// events implementation
class FetchRunnerWiseReport extends FetchRunnerWiseReportEvent {
  FetchRunnerWiseReport({
    required this.marketId,
    required this.runnerId,
    required this.userName,
  });
  final String marketId;
  final String runnerId;
  final String userName;
}

class FetchRunnerWiseReportInt extends FetchRunnerWiseReportEvent {}
