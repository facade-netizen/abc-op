import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/accountsRepo/account_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/change_pass_log_model.dart';
import 'handle_error.dart';

class FetchChangePassLogsBloc extends Bloc<FetchChangePassLogsEvent, FetchChangePassLogsState> {
  final AccountApiRepository _accountApiRepository;
  FetchChangePassLogsBloc(this._accountApiRepository) : super(FetchChangePassLogsInitial()) {
    on<FetchChangePassLogs>((event, emit) async {
      emit(FetchChangePassLogsProgress());
      debugPrint("Called FetchChangePassLogsBloc");
      SaveLoginTokenModel? savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedData != null) {
          final response = await _accountApiRepository.getUserChangePassLogs(
            userName: event.body['userName'],
            from: event.body['from'],
            to: event.body['to'],
            page: event.body['page'] ?? 1,
            limit: event.body['limit'] ?? 100,
          );
          if (response.status == "success" && response.data.isNotEmpty) {
            emit(FetchChangePassLogsSuccess(changePass: response));
          } else {
            if (kDebugMode) debugPrint("fetch_change_pass_logs_bloc.dart [response error]>> \\${response.status}");
            emit(FetchChangePassLogsFailure('Data not found'));
          }
        } else {
          emit(FetchChangePassLogsFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        debugPrint("fetch_change_pass_logs_bloc.dart [Platform Exception] >>error: $e");
        emit(FetchChangePassLogsFailure(handleError(e)));
      }
    });
    on<FetchChangePassLogsInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchChangePassLogsInt');
      emit(FetchChangePassLogsInitial());
    });
  }
}

//states
abstract class FetchChangePassLogsState {}

//events
abstract class FetchChangePassLogsEvent {}

//states implementation
class FetchChangePassLogsInitial extends FetchChangePassLogsState {}

class FetchChangePassLogsProgress extends FetchChangePassLogsState {}

class FetchChangePassLogsSuccess extends FetchChangePassLogsState {
  final ChangePassLogsResponse changePass;
  FetchChangePassLogsSuccess({required this.changePass});
}

class FetchChangePassLogsFailure extends FetchChangePassLogsState {
  final String error;
  FetchChangePassLogsFailure(this.error);
}

// events implementation
class FetchChangePassLogs extends FetchChangePassLogsEvent {
  final Map<String, dynamic> body;
  FetchChangePassLogs({required this.body});
}

class FetchChangePassLogsInt extends FetchChangePassLogsEvent {}
