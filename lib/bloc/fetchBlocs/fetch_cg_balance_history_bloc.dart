import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/casino_balance_log_model.dart';
import 'handle_error.dart';

class FetchCGBalanceHistoryBloc extends Bloc<FetchCGBalanceHistoryEvent, FetchCGBalanceHistoryState> {
  final CGApiRepository _cgApiRepository;
  FetchCGBalanceHistoryBloc(this._cgApiRepository) : super(FetchCGBalanceHistoryInitial()) {
    on<FetchCGBalanceHistory>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchCGBalanceHistoryBloc');
      emit(FetchCGBalanceHistoryProgress());

      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final Response<CasinoBalanceLogResponse> response = await _cgApiRepository.getCGBalanceLog(
            userName: event.body["userName"],
            from: event.body["from"],
            to: event.body["to"],
            page: event.body["page"] ?? 1,
            limit: event.body["limit"] ?? 500,
          );

          if (response.statusCode == 200) {
            final CasinoBalanceLogResponse cgBalanceHistory = response.body!;

            // Check if data is not empty
            if (cgBalanceHistory.data.isNotEmpty) {
              emit(FetchCGBalanceHistorySuccess(cgBalanceHistory: cgBalanceHistory));
            } else if (cgBalanceHistory.status.isNotEmpty && cgBalanceHistory.status.toLowerCase() != 'success') {
              emit(FetchCGBalanceHistoryFailure(cgBalanceHistory.status));
            } else {
              emit(FetchCGBalanceHistoryFailure('No casino balance history found for this time period.'));
            }
          } else {
            // Handle non-200 status codes
            String errorMessage = 'Request failed with status ${response.statusCode}';

            // Try to extract error message from response body if available
            if (response.body != null) {
              errorMessage = response.body!.status;
            } else if (response.error != null) {
              errorMessage = response.error.toString();
            }

            if (kDebugMode) {
              debugPrint("FetchCGBalanceHistoryBloc - non 200 response ${response.statusCode}");
              debugPrint("FetchCGBalanceHistoryBloc - error: $errorMessage");
            }

            emit(FetchCGBalanceHistoryFailure(errorMessage));
          }
        } else {
          emit(FetchCGBalanceHistoryFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        emit(FetchCGBalanceHistoryFailure(handleError(e)));
      }
    });

    on<FetchCGBalanceHistoryInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchCGBalanceHistoryInt');
      emit(FetchCGBalanceHistoryInitial());
    });
  }
}

//states
abstract class FetchCGBalanceHistoryState {}

//events
abstract class FetchCGBalanceHistoryEvent {}

//states implementation
class FetchCGBalanceHistoryInitial extends FetchCGBalanceHistoryState {}

class FetchCGBalanceHistoryProgress extends FetchCGBalanceHistoryState {}

class FetchCGBalanceHistorySuccess extends FetchCGBalanceHistoryState {
  final CasinoBalanceLogResponse cgBalanceHistory;
  FetchCGBalanceHistorySuccess({required this.cgBalanceHistory});
}

class FetchCGBalanceHistoryFailure extends FetchCGBalanceHistoryState {
  final String error;
  FetchCGBalanceHistoryFailure(this.error);
}

//events implementation
class FetchCGBalanceHistory extends FetchCGBalanceHistoryEvent {
  final Map<String, dynamic> body;
  FetchCGBalanceHistory({required this.body});
}

class FetchCGBalanceHistoryInt extends FetchCGBalanceHistoryEvent {}
