import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/player_bet_history_model.dart';
import 'handle_error.dart';

class FetchPlayerBetHistoryBloc extends Bloc<FetchPlayerBetHistoryEvent, FetchPlayerBetHistoryState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchPlayerBetHistoryBloc(this._ordersApiRepository) : super(FetchPlayerBetHistoryInitial()) {
    on<FetchPlayerBetHistory>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchPlayerBetHistoryBloc');
      emit(FetchPlayerBetHistoryProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData == null) {
          emit(FetchPlayerBetHistoryFailure('Your session has expired. Please log in again to proceed.'));
          return;
        }

        PlayerBetHistoryResponse res = await _ordersApiRepository.getPlayerBetHistory(body: event.getPlayerData);

        final String status = res.status.toLowerCase().trim();
        final bool isSuccess = status == 'success' || status == 'sucess';
        final bool isError = status == 'error';
        final bool hasData = res.data.isNotEmpty;

        if (hasData) {
          emit(FetchPlayerBetHistorySuccess(playerBets: res.data, res: res));
          return;
        }

        if (isSuccess) {
          emit(FetchPlayerBetHistoryFailure('You have no bets in this time period.'));
          return;
        }

        if (isError) {
          emit(FetchPlayerBetHistoryFailure(res.message.isNotEmpty ? res.message : 'Failed to fetch player bet history.'));
          return;
        }

        emit(FetchPlayerBetHistoryFailure(res.message.isNotEmpty ? res.message : 'No player bet history found.'));
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_player_bet_history_bloc.dart.dart [Try Block Exception]>> \n $e');
        emit(FetchPlayerBetHistoryFailure(handleError(e)));
      }
    });
    on<FetchPlayerBetInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchPlayerBetInt');
      emit(FetchPlayerBetHistoryInitial());
    });
  }
}

// states
abstract class FetchPlayerBetHistoryState {}

// events
abstract class FetchPlayerBetHistoryEvent {}

// states implementation
class FetchPlayerBetHistoryInitial extends FetchPlayerBetHistoryState {}

class FetchPlayerBetHistoryProgress extends FetchPlayerBetHistoryState {}

class FetchPlayerBetHistorySuccess extends FetchPlayerBetHistoryState {
  FetchPlayerBetHistorySuccess({
    required this.playerBets,
    required this.res,
  });
  final List<PlayerBetHistory> playerBets;
  final PlayerBetHistoryResponse res;
}

class FetchPlayerBetHistoryFailure extends FetchPlayerBetHistoryState {
  FetchPlayerBetHistoryFailure(this.error);
  final String error;
}

// events implementation
class FetchPlayerBetHistory extends FetchPlayerBetHistoryEvent {
  FetchPlayerBetHistory({required this.getPlayerData});
  Map<String, dynamic> getPlayerData;
}

class FetchPlayerBetInt extends FetchPlayerBetHistoryEvent {}
