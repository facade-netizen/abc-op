import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/accountsRepo/account_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/activity_log_model.dart';
import 'handle_error.dart';

class FetchCreditLimitLogsBloc extends Bloc<FetchCreditLimitLogsEvent, FetchCreditLimitLogsState> {
  final AccountApiRepository _accountApiRepository;
  FetchCreditLimitLogsBloc(this._accountApiRepository) : super(FetchCreditLimitLogsInitial()) {
    on<FetchCreditLimitLogs>((event, emit) async {
      emit(FetchCreditLimitLogsProgress());
      debugPrint("Called FetchCreditLimitLogsBloc");
      SaveLoginTokenModel? savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedData != null) {
          final response = await _accountApiRepository.getUserCreditLimitLogs(
            userName: event.body['userName'],
            from: event.body['from'],
            to: event.body['to'],
            page: event.body['page'] ?? 1,
            limit: event.body['limit'] ?? 100,
          );
          if (response.status == "success" && response.data.isNotEmpty) {
            emit(FetchCreditLimitLogsSuccess(creditLimitResponse: response));
          } else if (response.status != "success" && response.data.isEmpty) {
            emit(FetchCreditLimitLogsFailure(response.status));
          } else {
            if (kDebugMode) debugPrint("fetch_credit_limit_logs_bloc.dart [response error]>> \\${response.status}");
            emit(FetchCreditLimitLogsFailure('Data not found'));
          }
        } else {
          emit(FetchCreditLimitLogsFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        debugPrint("fetch_credit_limit_logs_bloc.dart [Platform Exception] >>error: $e");
        emit(FetchCreditLimitLogsFailure(handleError(e)));
      }
    });
    on<FetchCreditLimitLogsInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchCreditLimitLogsInt');
      emit(FetchCreditLimitLogsInitial());
    });
  }
}

//states
abstract class FetchCreditLimitLogsState {}

//events
abstract class FetchCreditLimitLogsEvent {}

//states implementation
class FetchCreditLimitLogsInitial extends FetchCreditLimitLogsState {}

class FetchCreditLimitLogsProgress extends FetchCreditLimitLogsState {}

class FetchCreditLimitLogsSuccess extends FetchCreditLimitLogsState {
  final CreditLimitResponse creditLimitResponse;
  FetchCreditLimitLogsSuccess({required this.creditLimitResponse});
}

class FetchCreditLimitLogsFailure extends FetchCreditLimitLogsState {
  final String error;
  FetchCreditLimitLogsFailure(this.error);
}

// events implementation
class FetchCreditLimitLogs extends FetchCreditLimitLogsEvent {
  final Map<String, dynamic> body;
  FetchCreditLimitLogs({required this.body});
}

class FetchCreditLimitLogsInt extends FetchCreditLimitLogsEvent {}
