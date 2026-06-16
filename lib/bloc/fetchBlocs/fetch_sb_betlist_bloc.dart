import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/bet_list_model.dart';
import 'handle_error.dart';

class FetchSbBetListBloc extends Bloc<FetchSbBetListEvent, FetchSbBetListState> {
  final CGApiRepository _cgApiRepository;
  FetchSbBetListBloc(this._cgApiRepository) : super(FetchSbBetListInitial()) {
    on<FetchSbBetList>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchSbBetListBloc');
      emit(FetchSbBetListProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final response = await _cgApiRepository.getCGSportsBookBetList(
            userName: event.userId,
            from: event.fromDate,
            to: event.toDate,
            page: event.page ?? 1,
            limit: event.limit ?? 50,
            status: event.status,
            sport: event.sport,
          );
          if (response.status.toLowerCase() == "success") {
            if (response.data.isNotEmpty) {
              emit(FetchSbBetListSuccess(betsList: response.data, response: response));
            } else if (response.status.isNotEmpty && response.status.toLowerCase() != 'success') {
              emit(FetchSbBetListFailure(response.status));
            } else {
              emit(FetchSbBetListFailure('You have no bets in this time period.'));
            }
          } else {
            if (kDebugMode) debugPrint("fetch_sb_betlist_bloc.dart [response error]>> ${response.status}");
            emit(FetchSbBetListFailure(response.status));
          }
        } else {
          emit(FetchSbBetListFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_sb_betlist_bloc.dart [Try Block Exception]>> \n $e');
        emit(FetchSbBetListFailure(handleError(e)));
      }
    });
    on<FetchSbBetListInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchSbBetListInt');
      emit(FetchSbBetListInitial());
    });
  }
}

// states
abstract class FetchSbBetListState {}

// events
abstract class FetchSbBetListEvent {}

// states implementation
class FetchSbBetListInitial extends FetchSbBetListState {}

class FetchSbBetListProgress extends FetchSbBetListState {}

class FetchSbBetListSuccess extends FetchSbBetListState {
  FetchSbBetListSuccess({
    required this.betsList,
    required this.response,
  });
  final List<BetData> betsList;
  final BetResponse response;
}

class FetchSbBetListFailure extends FetchSbBetListState {
  FetchSbBetListFailure(this.error);
  final String error;
}

// events implementation
class FetchSbBetList extends FetchSbBetListEvent {
  FetchSbBetList({
    this.page,
    this.limit,
    this.fromDate,
    this.toDate,
    this.userId,
    this.status,
    this.sport,
  });
  final String? fromDate;
  final String? toDate;
  final String? userId;
  final String? status;
  final String? sport;
  final int? page;
  final int? limit;
}

class FetchSbBetListInt extends FetchSbBetListEvent {}
