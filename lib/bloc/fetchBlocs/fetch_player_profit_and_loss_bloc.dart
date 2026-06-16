import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/players_profit_and_loss_model.dart';
import 'handle_error.dart';

class FetchPlayerProfitAndLossBloc extends Bloc<FetchPlayerProfitAndLossEvent, FetchPlayerProfitAndLossState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchPlayerProfitAndLossBloc(this._ordersApiRepository) : super(FetchPlayerProfitAndLossInitial()) {
    on<FetchPlayerProfitAndLoss>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchPlayerProfitAndLossBloc');
      emit(FetchPlayerProfitAndLossProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final response = await _ordersApiRepository.getPlayerProfitAndLoss(body: event.getPlayerPl);
          if (response.status.toLowerCase() == 'success') {
            if (response.data.isNotEmpty) {
              emit(FetchPlayerProfitAndLossSuccess(resultList: response.data, response: response));
            } else if (response.status.isNotEmpty && response.status.toLowerCase() != 'success') {
              emit(FetchPlayerProfitAndLossFailure(response.status));
            } else {
              emit(FetchPlayerProfitAndLossFailure('You have no bets in this time period.'));
            }
          } else {
            emit(FetchPlayerProfitAndLossFailure(response.status));
          }
        } else {
          emit(FetchPlayerProfitAndLossFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_player_profit_and_loss_bloc.dart.dart [Try Block Exception]>> \n $e');
        emit(FetchPlayerProfitAndLossFailure(handleError(e)));
      }
    });
    on<FetchPlayerProfitAndLossInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchBetListInt');
      emit(FetchPlayerProfitAndLossInitial());
    });
  }
}

// states
abstract class FetchPlayerProfitAndLossState {}

// events
abstract class FetchPlayerProfitAndLossEvent {}

// states implementation
class FetchPlayerProfitAndLossInitial extends FetchPlayerProfitAndLossState {}

class FetchPlayerProfitAndLossProgress extends FetchPlayerProfitAndLossState {}

class FetchPlayerProfitAndLossSuccess extends FetchPlayerProfitAndLossState {
  FetchPlayerProfitAndLossSuccess({
    required this.resultList,
    required this.response,
  });
  final List<PlayerProfitAndLossResponseResult> resultList;
  final PlayerProfitAndLossResponse response;
}

class FetchPlayerProfitAndLossFailure extends FetchPlayerProfitAndLossState {
  FetchPlayerProfitAndLossFailure(this.error);
  final String error;
}

// events implementation
class FetchPlayerProfitAndLoss extends FetchPlayerProfitAndLossEvent {
  FetchPlayerProfitAndLoss({required this.getPlayerPl});
  Map<String, dynamic> getPlayerPl;
}

class FetchPlayerProfitAndLossInt extends FetchPlayerProfitAndLossEvent {}
