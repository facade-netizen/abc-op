import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/bm_book_model.dart';
import 'handle_error.dart';

class FetchBMBookBloc extends Bloc<FetchBMBookEvent, FetchBMBookState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchBMBookBloc(this._ordersApiRepository) : super(FetchBMBookInitial()) {
    on<FetchBMBook>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchBMBookBloc');
      emit(FetchBMBookProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final response = await _ordersApiRepository.getBMBook(event.marketId, event.userId, event.userName);
          if (response.status == 200) {
            emit(FetchBMBookSuccess(bmBook: response.data));
          } else {
            if (kDebugMode) debugPrint("fetch_bm_book_bloc.dart [response error]>> ${response.status}");
            emit(FetchBMBookFailure('fetch_bm_book_bloc.dart [response error]>> ${response.status}'));
          }
        } else {
          emit(FetchBMBookFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_bm_book_bloc.dart [Try Block Exception]>> \n $e');
        emit(FetchBMBookFailure(handleError(e)));
      }
    });
  }
}

// states
abstract class FetchBMBookState {}

// events
abstract class FetchBMBookEvent {}

// states implementation
class FetchBMBookInitial extends FetchBMBookState {}

class FetchBMBookProgress extends FetchBMBookState {}

class FetchBMBookSuccess extends FetchBMBookState {
  FetchBMBookSuccess({required this.bmBook});
  final List<BMBookData> bmBook;
}

class FetchBMBookFailure extends FetchBMBookState {
  FetchBMBookFailure(this.error);
  final String error;
}

// events implementation
class FetchBMBook extends FetchBMBookEvent {
  FetchBMBook({required this.marketId, required this.userName, this.userId});
  final String marketId;
  final String? userName;
  final String? userId;
}
