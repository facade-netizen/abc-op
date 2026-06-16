import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/sport_book_pl_model.dart';
import 'handle_error.dart';

class FetchSportBookPlBloc extends Bloc<FetchSportBookPlEvent, FetchSportBookPlState> {
  final CGApiRepository _cgApiRepository;

  FetchSportBookPlBloc(this._cgApiRepository) : super(FetchSportBookPlInitial()) {
    on<FetchSportBookPl>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchSportBookPlBloc');
      emit(FetchSportBookPlProgress());
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData == null) {
          emit(FetchSportBookPlFailure('Your session has expired. Please log in again to proceed.'));
          return;
        }

        final Response<SportBookPlResponse> response = await _cgApiRepository.getCGSportsBookDetail(
          userName: event.body["userName"],
          from: event.body["from"],
          to: event.body["to"],
          page: event.body["page"] ?? 1,
          limit: event.body["limit"] ?? 500,
        );

        if (response.statusCode != 200 || response.body == null) {
          emit(FetchSportBookPlFailure(response.body?.message ?? 'Something went wrong'));
          return;
        }

        final SportBookPlResponse sbr = response.body!;
        final String status = sbr.status.toLowerCase().trim();

        final bool isSuccess = status == 'success' || status == 'sucess';
        final bool isError = status == 'error';
        final bool hasData = sbr.data.isNotEmpty;

        if (isSuccess && hasData) {
          emit(FetchSportBookPlSuccess(sportsBookResponse: sbr));
          return;
        }

        if (isSuccess && !hasData) {
          emit(FetchSportBookPlFailure('You have no bets in this time period.'));
          return;
        }

        if (isError) {
          emit(FetchSportBookPlFailure(sbr.message));
          return;
        }

        if (!hasData) {
          emit(FetchSportBookPlFailure('You have no bets in this time period.'));
          return;
        }

        emit(FetchSportBookPlFailure(sbr.message));
      } catch (e) {
        emit(FetchSportBookPlFailure(handleError(e)));
      }
    });
    on<FetchSportBookPlInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchSportBookPlInt');
      emit(FetchSportBookPlInitial());
    });
  }
}

//states
abstract class FetchSportBookPlState {}

//events
abstract class FetchSportBookPlEvent {}

//states implementation
class FetchSportBookPlInitial extends FetchSportBookPlState {}

class FetchSportBookPlProgress extends FetchSportBookPlState {}

class FetchSportBookPlSuccess extends FetchSportBookPlState {
  final SportBookPlResponse sportsBookResponse;
  FetchSportBookPlSuccess({required this.sportsBookResponse});
}

class FetchSportBookPlFailure extends FetchSportBookPlState {
  final String error;
  FetchSportBookPlFailure(this.error);
}

//events implementation
class FetchSportBookPl extends FetchSportBookPlEvent {
  final Map<String, dynamic> body;
  FetchSportBookPl({required this.body});
}

class FetchSportBookPlInt extends FetchSportBookPlEvent {}
