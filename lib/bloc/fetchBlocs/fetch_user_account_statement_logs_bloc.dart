import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/accountsRepo/account_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/activity_log_model.dart';
import 'handle_error.dart';

class FetchUserAccountStatementLogsBloc extends Bloc<FetchUserAccountStatementLogsEvent, FetchUserAccountStatementLogsState> {
  final AccountApiRepository _accountApiRepository;
  FetchUserAccountStatementLogsBloc(this._accountApiRepository) : super(FetchUserAccountStatementLogsInitial()) {
    on<FetchUserAccountStatementLogs>((event, emit) async {
      emit(FetchUserAccountStatementLogsProgress());
      debugPrint("Called FetchUserAccountStatementLogsBloc");
      SaveLoginTokenModel? savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedData != null) {
          int limit = event.limit ?? 25;
          int page = event.page ?? 1;

          Map<String, dynamic> logsMap = {"userName": event.userId, "from": event.from, "to": event.to, "limit": limit, "page": page};
          final response = await _accountApiRepository.getUserAccountStatementLogs(body: logsMap);
          if (response.status.toLowerCase() == "success") {
            if (response.data.isNotEmpty) {
              emit(FetchUserAccountStatementLogsSuccess(logs: response));
            } else if (response.status.isNotEmpty && response.status.toLowerCase() != 'success') {
              emit(FetchUserAccountStatementLogsFailure(response.status));
            } else {
              emit(FetchUserAccountStatementLogsFailure('You have no data in this time period.'));
            }
          } else {
            if (kDebugMode) debugPrint("fetch_user_account_statement_logs_bloc.dart [response error]>> ${response.status}");
            emit(FetchUserAccountStatementLogsFailure(response.status));
          }
        } else {
          emit(FetchUserAccountStatementLogsFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        debugPrint("fetch_user_account_statement_logs_bloc.dart [Catch Exception] >>error: $e");
        emit(FetchUserAccountStatementLogsFailure(handleError(e)));
      }
    });
    on<FetchUserAccountStatementLogsInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchUserAccountStatementLogsInt');
      emit(FetchUserAccountStatementLogsInitial());
    });
  }
}

//states
abstract class FetchUserAccountStatementLogsState {}

//events
abstract class FetchUserAccountStatementLogsEvent {}

//states implementation
class FetchUserAccountStatementLogsInitial extends FetchUserAccountStatementLogsState {}

class FetchUserAccountStatementLogsProgress extends FetchUserAccountStatementLogsState {}

class FetchUserAccountStatementLogsSuccess extends FetchUserAccountStatementLogsState {
  final AccountStatementResponse logs;
  FetchUserAccountStatementLogsSuccess({required this.logs});
}

class FetchUserAccountStatementLogsFailure extends FetchUserAccountStatementLogsState {
  final String error;
  FetchUserAccountStatementLogsFailure(this.error);
}

// events implementation
class FetchUserAccountStatementLogs extends FetchUserAccountStatementLogsEvent {
  String? userId;
  String? from;
  String? to;
  int? limit;
  int? page;

  FetchUserAccountStatementLogs({this.userId, this.from, this.to, this.limit, this.page});
}

class FetchUserAccountStatementLogsInt extends FetchUserAccountStatementLogsEvent {}
