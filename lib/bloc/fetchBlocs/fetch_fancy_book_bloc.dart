import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/runners_pl_model.dart';
import 'handle_error.dart';

class FetchFancyBookBloc extends Bloc<FetchFancyBookEvent, FetchFancyBookState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchFancyBookBloc(this._ordersApiRepository) : super(FetchFancyBookInitial()) {
    on<FetchFancyBook>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchFancyBookBloc');
      emit(FetchFancyBookProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final Map<String, dynamic> data = {"marketIds": event.marketId};

          final response = await _ordersApiRepository.getFancyBook(body: data);
          if (response.status == 200) {
            // if (kDebugMode) debugPrint("Fancy Book  ${response.data.toString()}");
            emit(FetchFancyBookSuccess(fancyBook: response.data));
          } else {
            if (kDebugMode) debugPrint("fetch_fancy_book_bloc.dart [response error]>> ${response.status}");
            emit(FetchFancyBookFailure('fetch_fancy_book_bloc.dart [response error]>> ${response.status}'));
          }
        } else {
          emit(FetchFancyBookFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_fancy_book_bloc.dart.dart [Try Block Exception]>> \n $e');
        emit(FetchFancyBookFailure(handleError(e)));
      }
    });
  }
}

// states
abstract class FetchFancyBookState {}

// events
abstract class FetchFancyBookEvent {}

// states implementation
class FetchFancyBookInitial extends FetchFancyBookState {}

class FetchFancyBookProgress extends FetchFancyBookState {}

class FetchFancyBookSuccess extends FetchFancyBookState {
  FetchFancyBookSuccess({required this.fancyBook});
  final List<RunData> fancyBook;
}

class FetchFancyBookFailure extends FetchFancyBookState {
  FetchFancyBookFailure(this.error);
  final String error;
}

// events implementation
class FetchFancyBook extends FetchFancyBookEvent {
  FetchFancyBook({required this.marketId});
  final String marketId;
}
