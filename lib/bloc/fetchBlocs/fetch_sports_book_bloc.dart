import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/sports_book_model.dart';
import 'handle_error.dart';

class FetchSportsBookBloc extends Bloc<FetchSportsBookEvent, FetchSportsBookState> {
  final CGApiRepository _cgApiRepository;
  FetchSportsBookBloc(this._cgApiRepository) : super(FetchSportsBookInitial()) {
    on<FetchSportsBook>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchSportsBookBloc');
      emit(FetchSportsBookProgress());
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData == null) {
          emit(FetchSportsBookFailure('Your session has expired. Please log in again to proceed.'));
          return;
        }
        final Response<SportsBookResponse> response = await _cgApiRepository.getCGSportsBook(
          status: event.body["status"],
          userName: event.body["userName"],
          from: event.body["from"],
          to: event.body["to"],
          orderIds: event.body["orderIds"],
          page: event.body["page"] ?? 1,
          limit: event.body["limit"] ?? 500,
        );

        if (response.statusCode == 200) {
          final SportsBookResponse sportsBookResponse = response.body!;

          // Check if data is not empty
          if (sportsBookResponse.data.isNotEmpty) {
            emit(FetchSportsBookSuccess(sportsBookResponse: sportsBookResponse));
          } else if (sportsBookResponse.status.isNotEmpty && sportsBookResponse.status.toLowerCase() != 'success') {
            emit(FetchSportsBookFailure(sportsBookResponse.status));
          } else {
            emit(FetchSportsBookFailure('You have no bets in this time period.'));
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
            debugPrint("FetchSportsBookBloc - non 200 response ${response.statusCode}");
            debugPrint("FetchSportsBookBloc - error: $errorMessage");
          }

          emit(FetchSportsBookFailure(errorMessage));
        }
      } catch (e) {
        emit(FetchSportsBookFailure(handleError(e)));
      }
    });

    on<FetchSportsBookInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchSportsBookInt');
      emit(FetchSportsBookInitial());
    });
  }
}

//states
abstract class FetchSportsBookState {}

//events
abstract class FetchSportsBookEvent {}

//states implementation
class FetchSportsBookInitial extends FetchSportsBookState {}

class FetchSportsBookProgress extends FetchSportsBookState {}

class FetchSportsBookSuccess extends FetchSportsBookState {
  final SportsBookResponse sportsBookResponse;
  FetchSportsBookSuccess({required this.sportsBookResponse});
}

class FetchSportsBookFailure extends FetchSportsBookState {
  final String error;
  FetchSportsBookFailure(this.error);
}

//events implementation
class FetchSportsBook extends FetchSportsBookEvent {
  final Map<String, dynamic> body;
  FetchSportsBook({required this.body});
}

class FetchSportsBookInt extends FetchSportsBookEvent {}
