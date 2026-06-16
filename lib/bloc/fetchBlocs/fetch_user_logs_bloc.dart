import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/accountsRepo/account_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/user_log_model.dart';
import 'handle_error.dart';

class FetchUserLogsBloc extends Bloc<FetchUserLogsEvent, FetchUserLogsState> {
  final AccountApiRepository _accountApiRepository;
  FetchUserLogsBloc(this._accountApiRepository) : super(FetchUserLogsInitial()) {
    on<FetchUserLogs>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchUserLogsBloc');
      emit(FetchUserLogsProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final response = await _accountApiRepository.getUserLogs(
            from: event.from,
            to: event.to,
            logType: event.logType,
            username: event.userId,
            updater: event.updater,
          );
          if (response.status == 200) {
            if (response.data.isNotEmpty) {
              emit(
                FetchUserLogsSuccess(
                  userLogs: response.data,
                  response: response,
                ),
              );
            } else if (response.message.isNotEmpty && response.message.toLowerCase() != 'success') {
              emit(FetchUserLogsFailure(response.message));
            } else {
              emit(FetchUserLogsFailure('No logs available for this time period.'));
            }
          } else {
            if (kDebugMode) debugPrint("fetch_user_logs_bloc.dart [response error]>> ${response.status}");
            emit(FetchUserLogsFailure(response.message));
          }
        } else {
          emit(FetchUserLogsFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_user_logs_bloc.dart.dart [Try Block Exception]>> \n $e');
        emit(FetchUserLogsFailure(handleError(e)));
      }
    });
    on<FetchUserLogsInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchUserLogsInt');
      emit(FetchUserLogsInitial());
    });
  }
}

// states
abstract class FetchUserLogsState {}

// events
abstract class FetchUserLogsEvent {}

// states implementation
class FetchUserLogsInitial extends FetchUserLogsState {}

class FetchUserLogsProgress extends FetchUserLogsState {}

class FetchUserLogsSuccess extends FetchUserLogsState {
  FetchUserLogsSuccess({
    required this.userLogs,
    required this.response,
  });
  final List<UserLogModel> userLogs;
  final UserLogResponse response;
}

class FetchUserLogsFailure extends FetchUserLogsState {
  FetchUserLogsFailure(this.error);
  final String error;
}

// events implementation
class FetchUserLogs extends FetchUserLogsEvent {
  FetchUserLogs({
    this.from,
    this.to,
    this.logType,
    this.userId,
    this.updater,
  });
  final String? from;
  final String? to;
  final String? userId;
  final String? updater;
  final int? logType;
}

class FetchUserLogsInt extends FetchUserLogsEvent {}
