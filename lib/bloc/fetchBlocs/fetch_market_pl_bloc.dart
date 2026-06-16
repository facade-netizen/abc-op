import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/market_pl_model.dart';
import 'handle_error.dart';

class FetchMarketPlBloc extends Bloc<FetchMarketPlEvent, FetchMarketPlState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchMarketPlBloc(this._ordersApiRepository) : super(FetchMarketPlInitial()) {
    on<FetchMarketPl>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchMarketPlBloc');
      emit(FetchMarketPlProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          Map<String, dynamic> body = {
            'from': event.fromDate,
            'to': event.toDate,
            'userName': event.userName,
          };
          final response = await _ordersApiRepository.getMarketProfitLoss(body: body);
          if (response.status == 200) {
            if (response.data.isNotEmpty) {
              emit(
                FetchMarketPlSuccess(
                  marketPl: response.data,
                  response: response,
                  searchedUser: event.userName?.trim(),
                ),
              );
            } else if (event.userName != null && event.userName!.trim().isNotEmpty) {
              emit(FetchMarketPlFailure("This account doesn't exist."));
            } else if (response.message.isNotEmpty && response.message.toLowerCase() != 'success') {
              emit(FetchMarketPlFailure(response.message));
            } else {
              emit(FetchMarketPlFailure('You have no data in this time period.'));
            }
          } else {
            if (kDebugMode) debugPrint("fetch_market_pl_bloc.dart [response error]>> ${response.status}");
            emit(FetchMarketPlFailure(response.message));
          }
        } else {
          emit(FetchMarketPlFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_market_pl_bloc.dart.dart [Try Block Exception]>> \n $e');
        emit(FetchMarketPlFailure(handleError(e)));
      }
    });
    on<FetchMarketPlInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchMarketPlInt');
      emit(FetchMarketPlInitial());
    });
  }
}

// states
abstract class FetchMarketPlState {}

// events
abstract class FetchMarketPlEvent {}

// states implementation
class FetchMarketPlInitial extends FetchMarketPlState {}

class FetchMarketPlProgress extends FetchMarketPlState {}

class FetchMarketPlSuccess extends FetchMarketPlState {
  FetchMarketPlSuccess({
    required this.marketPl,
    required this.response,
    this.searchedUser,
  });
  final List<MarketPlData> marketPl;
  final MarketPlModel response;
  final String? searchedUser;
}

class FetchMarketPlFailure extends FetchMarketPlState {
  FetchMarketPlFailure(this.error);
  final String error;
}

// events implementation
class FetchMarketPl extends FetchMarketPlEvent {
  FetchMarketPl({
    this.fromDate,
    this.toDate,
    this.userName,
  });
  final String? fromDate;
  final String? toDate;
  final String? userName;
}

class FetchMarketPlInt extends FetchMarketPlEvent {}
