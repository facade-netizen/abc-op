import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/accountsRepo/account_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/ispip_log_model.dart';
import 'handle_error.dart';

class FetchUserIspIpLogsBloc extends Bloc<FetchUserIspIpLogsEvent, FetchUserIspIpLogsState> {
  final AccountApiRepository _accountApiRepository;
  FetchUserIspIpLogsBloc(this._accountApiRepository) : super(FetchUserIspIpLogsInitial()) {
    on<FetchUserIspIpLogs>((event, emit) async {
      emit(FetchUserIspIpLogsProgress());
      debugPrint("Called FetchUserIspIpLogsBloc");
      SaveLoginTokenModel? savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedData != null) {
          final response = await _accountApiRepository.getUserISPData(body: event.body);
          if (response.status == "success" && response.data.isNotEmpty) {
            emit(FetchUserIspIpLogsSuccess(ispIpLogsResponse: response));
          } else {
            if (kDebugMode) debugPrint("fetch_user_ispip_logs_bloc.dart [response error]>> \\${response.status}");
            emit(FetchUserIspIpLogsFailure('Data not found'));
          }
        } else {
          emit(FetchUserIspIpLogsFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        debugPrint("fetch_user_ispip_logs_bloc.dart [Platform Exception] >>error: $e");
        emit(FetchUserIspIpLogsFailure(handleError(e)));
      }
    });
    on<FetchUserIspIpLogsInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchUserIspIpLogsInt');
      emit(FetchUserIspIpLogsInitial());
    });
  }
}

//states
abstract class FetchUserIspIpLogsState {}

//events
abstract class FetchUserIspIpLogsEvent {}

//states implementation
class FetchUserIspIpLogsInitial extends FetchUserIspIpLogsState {}

class FetchUserIspIpLogsProgress extends FetchUserIspIpLogsState {}

class FetchUserIspIpLogsSuccess extends FetchUserIspIpLogsState {
  final IspIpLogsResponse ispIpLogsResponse;
  FetchUserIspIpLogsSuccess({required this.ispIpLogsResponse});
}

class FetchUserIspIpLogsFailure extends FetchUserIspIpLogsState {
  final String error;
  FetchUserIspIpLogsFailure(this.error);
}

// events implementation
class FetchUserIspIpLogs extends FetchUserIspIpLogsEvent {
  final Map<String, dynamic> body;
  FetchUserIspIpLogs({required this.body});
}

class FetchUserIspIpLogsInt extends FetchUserIspIpLogsEvent {}
