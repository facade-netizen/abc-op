import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/accountsRepo/account_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/activity_log_model.dart';
import 'handle_error.dart';

class FetchTransferredLogsBloc extends Bloc<FetchTransferredLogsEvent, FetchTransferredLogsState> {
  final AccountApiRepository _accountApiRepository;
  FetchTransferredLogsBloc(this._accountApiRepository) : super(FetchTransferredLogsInitial()) {
    on<FetchTransferredLogs>((event, emit) async {
      emit(FetchTransferredLogsProgress());
      debugPrint("Called FetchTransferredLogsBloc");
      SaveLoginTokenModel? savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedData != null) {
          final response = await _accountApiRepository.getUserTransferredLogs(
            userName: event.body['userName'],
            from: event.body['from'],
            to: event.body['to'],
            page: event.body['page'] ?? 1,
            limit: event.body['limit'] ?? 100,
          );
          if (response.status == "success" && response.data.isNotEmpty) {
            emit(FetchTransferredLogsSuccess(transferredResponse: response));
          } else if (response.status != "success" && response.data.isEmpty) {
            emit(FetchTransferredLogsFailure(response.status));
          } else {
            if (kDebugMode) debugPrint("fetch_transferred_logs_bloc.dart [response error]>> \\${response.status}");
            emit(FetchTransferredLogsFailure('Data not found'));
          }
        } else {
          emit(FetchTransferredLogsFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        debugPrint("fetch_transferred_logs_bloc.dart [Platform Exception] >>error: $e");
        emit(FetchTransferredLogsFailure(handleError(e)));
      }
    });
    on<FetchTransferredLogsInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchTransferredLogsInt');
      emit(FetchTransferredLogsInitial());
    });
  }
}

//states
abstract class FetchTransferredLogsState {}

//events
abstract class FetchTransferredLogsEvent {}

//states implementation
class FetchTransferredLogsInitial extends FetchTransferredLogsState {}

class FetchTransferredLogsProgress extends FetchTransferredLogsState {}

class FetchTransferredLogsSuccess extends FetchTransferredLogsState {
  final TransferredResponse transferredResponse;
  FetchTransferredLogsSuccess({required this.transferredResponse});
}

class FetchTransferredLogsFailure extends FetchTransferredLogsState {
  final String error;
  FetchTransferredLogsFailure(this.error);
}

// events implementation
class FetchTransferredLogs extends FetchTransferredLogsEvent {
  final Map<String, dynamic> body;
  FetchTransferredLogs({required this.body});
}

class FetchTransferredLogsInt extends FetchTransferredLogsEvent {}
