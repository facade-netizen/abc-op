import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/casino_history_model.dart';
import 'handle_error.dart';

class FetchCGHistoryBloc extends Bloc<FetchCGHistoryEvent, FetchCGHistoryState> {
  final CGApiRepository _cgApiRepository;
  FetchCGHistoryBloc(this._cgApiRepository) : super(FetchCGHistoryInitial()) {
    on<FetchCGHistory>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchCGHistoryBloc');
      emit(FetchCGHistoryProgress());
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData == null) {
          emit(FetchCGHistoryFailure('Your session has expired. Please log in again to proceed.'));
          return;
        }
        final Response<CasinoHistoryResponse> response = await _cgApiRepository.getCGHistory(
          userName: event.body["userName"],
          from: event.body["from"],
          to: event.body["to"],
          page: event.body["page"],
          limit: event.body["limit"],
        );

        if (response.statusCode == 200) {
          final CasinoHistoryResponse cgHistoryData = response.body!;

          // Check if data is not empty
          if (cgHistoryData.data.isNotEmpty) {
            emit(FetchCGHistorySuccess(cgHistoryData: cgHistoryData));
          } else if (cgHistoryData.message.isNotEmpty && cgHistoryData.message.toLowerCase() != 'success') {
            emit(FetchCGHistoryFailure(cgHistoryData.message));
          } else {
            emit(FetchCGHistoryFailure('No casino game history found for this time period.'));
          }
        } else {
          // Handle non-200 status codes
          String errorMessage = 'Request failed with status ${response.statusCode}';

          // Try to extract error message from response body if available
          if (response.body != null) {
            errorMessage = response.body!.message;
          } else if (response.error != null) {
            errorMessage = response.error.toString();
          }

          if (kDebugMode) {
            debugPrint("FetchCGHistoryBloc - non 200 response ${response.statusCode}");
            debugPrint("FetchCGHistoryBloc - error: $errorMessage");
          }

          emit(FetchCGHistoryFailure(errorMessage));
        }
      } catch (e) {
        emit(FetchCGHistoryFailure(handleError(e)));
      }
    });

    on<FetchCGHistoryInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchCGHistoryInt');
      emit(FetchCGHistoryInitial());
    });
  }
}

//states
abstract class FetchCGHistoryState {}

//events
abstract class FetchCGHistoryEvent {}

//states implementation
class FetchCGHistoryInitial extends FetchCGHistoryState {}

class FetchCGHistoryProgress extends FetchCGHistoryState {}

class FetchCGHistorySuccess extends FetchCGHistoryState {
  final CasinoHistoryResponse cgHistoryData;
  FetchCGHistorySuccess({required this.cgHistoryData});
}

class FetchCGHistoryFailure extends FetchCGHistoryState {
  final String error;
  FetchCGHistoryFailure(this.error);
}

//events implementation
class FetchCGHistory extends FetchCGHistoryEvent {
  final Map<String, dynamic> body;
  FetchCGHistory({required this.body});
}

class FetchCGHistoryInt extends FetchCGHistoryEvent {}
