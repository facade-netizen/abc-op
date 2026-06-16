import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/open_bm_bets_model.dart';
import 'handle_error.dart';

class FetchOpenBMBloc extends Bloc<FetchOpenBMEvent, FetchOpenBMState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchOpenBMBloc(this._ordersApiRepository) : super(FetchOpenBMInitial()) {
    on<FetchOpenBM>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchOpenBMBloc');
      emit(FetchOpenBMProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final response = await _ordersApiRepository.getBM(event.userName, 2);
          if (response.statusCode == 200) {
            //if (kDebugMode) debugPrint("BM ${response.bodyString}");
            emit(FetchOpenBMSuccess(openBMData: response.body!.data));
          } else {
            if (kDebugMode) debugPrint("fetch_open_bm_bloc.dart [response error]>> ${response.statusCode}");
            emit(FetchOpenBMFailure('fetch_open_bm_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(FetchOpenBMFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_open_bm_bloc.dart.dart [Try Block Exception]>> \n $e');
        emit(FetchOpenBMFailure(handleError(e)));
      }
    });
    on<FetchOpenBMInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchOpenBMInt');
      emit(FetchOpenBMInitial());
    });
  }
}

// states
abstract class FetchOpenBMState {}

// events
abstract class FetchOpenBMEvent {}

// states implementation
class FetchOpenBMInitial extends FetchOpenBMState {}

class FetchOpenBMProgress extends FetchOpenBMState {}

class FetchOpenBMSuccess extends FetchOpenBMState {
  FetchOpenBMSuccess({required this.openBMData});
  final List<OpenBMData> openBMData;
}

class FetchOpenBMFailure extends FetchOpenBMState {
  FetchOpenBMFailure(this.error);
  final String error;
}

// events implementation
class FetchOpenBM extends FetchOpenBMEvent {
  final String userName;
  FetchOpenBM({required this.userName});
}

class FetchOpenBMInt extends FetchOpenBMEvent {}
