import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/premium_sport_model.dart';
import 'handle_error.dart';

class FetchOpenPremiumSportBloc extends Bloc<FetchOpenPremiumSportEvent, FetchOpenPremiumSportState> {
  final CGApiRepository _cgApiRepository;
  FetchOpenPremiumSportBloc(this._cgApiRepository) : super(FetchOpenPremiumSportInitial()) {
    on<FetchOpenPremiumSport>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchOpenPremiumSportBloc');
      emit(FetchOpenPremiumSportProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final response = await _cgApiRepository.getCGPremiumSport(sportName: event.sportName, userName: event.userName);
          if (response.statusCode == 200) {
            emit(FetchOpenPremiumSportSuccess(data: response.body!.data));
          } else {
            if (kDebugMode) debugPrint("fetch_open_premium_sport_bloc.dart [response error]>> ${response.statusCode}");
            emit(FetchOpenPremiumSportFailure('fetch_open_premium_sport_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(FetchOpenPremiumSportFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_open_premium_sport_bloc.dart [Try Block Exception]>> \n $e');
        emit(FetchOpenPremiumSportFailure(handleError(e)));
      }
    });
    on<FetchOpenPremiumSportInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchOpenPremiumSportInt');
      emit(FetchOpenPremiumSportInitial());
    });
  }
}

// states
abstract class FetchOpenPremiumSportState {}

// events
abstract class FetchOpenPremiumSportEvent {}

// states implementation
class FetchOpenPremiumSportInitial extends FetchOpenPremiumSportState {}

class FetchOpenPremiumSportProgress extends FetchOpenPremiumSportState {}

class FetchOpenPremiumSportSuccess extends FetchOpenPremiumSportState {
  FetchOpenPremiumSportSuccess({required this.data});
  final List<PremiumSportData> data;
}

class FetchOpenPremiumSportFailure extends FetchOpenPremiumSportState {
  FetchOpenPremiumSportFailure(this.error);
  final String error;
}

// events implementation
class FetchOpenPremiumSport extends FetchOpenPremiumSportEvent {
  final String? sportName;
  final String userName;
  FetchOpenPremiumSport({this.sportName, required this.userName});
}

class FetchOpenPremiumSportInt extends FetchOpenPremiumSportEvent {}
