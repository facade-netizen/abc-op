import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/premium_runner_wise_report_model.dart';
import 'handle_error.dart';

class FetchPremiumRunnerWiseReportBloc extends Bloc<FetchPremiumRunnerWiseReportEvent, FetchPremiumRunnerWiseReportState> {
  final CGApiRepository _cgApiRepository;
  FetchPremiumRunnerWiseReportBloc(this._cgApiRepository) : super(FetchPremiumRunnerWiseReportInitial()) {
    on<FetchPremiumRunnerWiseReport>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchPremiumRunnerWiseReportBloc');
      emit(FetchPremiumRunnerWiseReportProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final response = await _cgApiRepository.getPremiumRunnerWiseReport(
            marketId: event.marketId,
            runnerName: event.runnerName,
            userName: event.userName,
          );
          if (response.status == 200) {
            emit(FetchPremiumRunnerWiseReportSuccess(reports: response.data));
          } else {
            if (kDebugMode) debugPrint("fetch_premium_runner_wise_report_bloc.dart [response error]>> ${response.status}");
            emit(FetchPremiumRunnerWiseReportFailure(response.message));
          }
        } else {
          emit(FetchPremiumRunnerWiseReportFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_premium_runner_wise_report_bloc.dart [Try Block Exception]>> \n $e');
        emit(FetchPremiumRunnerWiseReportFailure(handleError(e)));
      }
    });

    on<FetchPremiumRunnerWiseReportInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchPremiumRunnerWiseReportInt');
      emit(FetchPremiumRunnerWiseReportInitial());
    });
  }
}

// states
abstract class FetchPremiumRunnerWiseReportState {}

// events
abstract class FetchPremiumRunnerWiseReportEvent {}

// states implementation
class FetchPremiumRunnerWiseReportInitial extends FetchPremiumRunnerWiseReportState {}

class FetchPremiumRunnerWiseReportProgress extends FetchPremiumRunnerWiseReportState {}

class FetchPremiumRunnerWiseReportSuccess extends FetchPremiumRunnerWiseReportState {
  FetchPremiumRunnerWiseReportSuccess({required this.reports});
  final PremiumRunnerWiseReportData reports;
}

class FetchPremiumRunnerWiseReportFailure extends FetchPremiumRunnerWiseReportState {
  FetchPremiumRunnerWiseReportFailure(this.error);
  final String error;
}

// events implementation
class FetchPremiumRunnerWiseReport extends FetchPremiumRunnerWiseReportEvent {
  FetchPremiumRunnerWiseReport({
    required this.marketId,
    required this.runnerName,
    required this.userName,
  });
  final String marketId;
  final String runnerName;
  final String userName;
}

class FetchPremiumRunnerWiseReportInt extends FetchPremiumRunnerWiseReportEvent {}
