import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/top_exposure_player_model.dart';
import 'handle_error.dart';

class FetchTopExposurePlayerBloc extends Bloc<FetchTopExposurePlayerEvent, FetchTopExposurePlayerState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchTopExposurePlayerBloc(this._ordersApiRepository) : super(FetchTopExposurePlayerInitial()) {
    on<FetchTopExposurePlayer>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchTopExposurePlayerBloc');
      emit(FetchTopExposurePlayerProgress());
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData == null) {
          emit(FetchTopExposurePlayerFailure('Your session has expired. Please log in again to proceed.'));
          return;
        }
        final TopPlayerExposureResponse response = await _ordersApiRepository.getTopExposurePlayers(event.userName);
        if (response.status == 200 && response.message.toLowerCase() == 'success') {
          TopPlayerExposureDataWrapper topPlayerExposure = response.data;
          emit(FetchTopExposurePlayerSuccess(
            topExposure: topPlayerExposure.topExposure,
            topBalance: topPlayerExposure.topBalance,
          ));
        } else {
          emit(FetchTopExposurePlayerFailure(response.message));
        }
      } catch (e) {
        emit(FetchTopExposurePlayerFailure(handleError(e)));
      }
    });
    on<FetchTopExposurePlayerInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchTopExposurePlayerInt');
      emit(FetchTopExposurePlayerInitial());
    });
  }
}

//states
abstract class FetchTopExposurePlayerState {}

//events
abstract class FetchTopExposurePlayerEvent {}

//states implementation
class FetchTopExposurePlayerInitial extends FetchTopExposurePlayerState {}

class FetchTopExposurePlayerProgress extends FetchTopExposurePlayerState {}

class FetchTopExposurePlayerSuccess extends FetchTopExposurePlayerState {
  final List<TopPlayerExposureData> topBalance;
  final List<TopPlayerExposureData> topExposure;
  FetchTopExposurePlayerSuccess({
    required this.topBalance,
    required this.topExposure,
  });
}

class FetchTopExposurePlayerFailure extends FetchTopExposurePlayerState {
  final String error;
  FetchTopExposurePlayerFailure(this.error);
}

//events implementation
class FetchTopExposurePlayer extends FetchTopExposurePlayerEvent {
  final String userName;
  FetchTopExposurePlayer({required this.userName});
}

class FetchTopExposurePlayerInt extends FetchTopExposurePlayerEvent {}
