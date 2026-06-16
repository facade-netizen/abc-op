import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/open_fancy_bets_model.dart';
import 'handle_error.dart';

class FetchOpenFancyBloc extends Bloc<FetchOpenFancyEvent, FetchOpenFancyState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchOpenFancyBloc(this._ordersApiRepository) : super(FetchOpenFancyInitial()) {
    on<FetchOpenFancy>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchOpenFancyBloc');
      emit(FetchOpenFancyProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final response = await _ordersApiRepository.getFancy(event.userName, 1);
          if (response.statusCode == 200) {
            //if (kDebugMode) debugPrint("Fancy ${response.bodyString}");
            emit(FetchOpenFancySuccess(openFancyData: response.body!.data));
          } else {
            if (kDebugMode) debugPrint("fetch_open_fancy_bloc.dart [response error]>> ${response.statusCode}");
            emit(FetchOpenFancyFailure('fetch_open_fancy_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(FetchOpenFancyFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_open_fancy_bloc.dart.dart [Try Block Exception]>> \n $e');
        emit(FetchOpenFancyFailure(handleError(e)));
      }
    });
    on<FetchOpenFancyInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchOpenFancyInt');
      emit(FetchOpenFancyInitial());
    });
  }
}

// states
abstract class FetchOpenFancyState {}

// events
abstract class FetchOpenFancyEvent {}

// states implementation
class FetchOpenFancyInitial extends FetchOpenFancyState {}

class FetchOpenFancyProgress extends FetchOpenFancyState {}

class FetchOpenFancySuccess extends FetchOpenFancyState {
  FetchOpenFancySuccess({required this.openFancyData});
  final List<OpenFancyData> openFancyData;
}

class FetchOpenFancyFailure extends FetchOpenFancyState {
  FetchOpenFancyFailure(this.error);
  final String error;
}

// events implementation
class FetchOpenFancy extends FetchOpenFancyEvent {
  final String userName;
  FetchOpenFancy({required this.userName});
}

class FetchOpenFancyInt extends FetchOpenFancyEvent {}
