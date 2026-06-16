import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/open_odds_bets_model.dart';
import '../../model/sport_wise_report_model.dart';
import 'handle_error.dart';

String ipl = 'Indian Premier League';
String matchOdds = 'match_odds';

class FetchOpenOddsBloc extends Bloc<FetchOpenOddsEvent, FetchOpenOddsState> {
  final OrdersApiRepository _ordersApiRepository;

  FetchOpenOddsBloc(this._ordersApiRepository) : super(FetchOpenOddsInitial()) {
    on<FetchOpenOdds>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchOpenOddsBloc');
      emit(FetchOpenOddsProgress());

      // checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final response = await _ordersApiRepository.getOpenOdds(event.userName, 0);
          if (response.statusCode == 200) {
            /// open odds data
            final openOddsData = response.body!.data;

            /// Separating data based on marketType
            final List<OpenOddsData> matchOddsData = [];
            final List<OpenOddsData> otherMarketsData = [];

            for (var report in openOddsData) {
              final List<OddsDate> matchOddsDates = [];
              final List<OddsDate> otherMarketsDates = [];

              for (var date in report.dates) {
                // Separate events based on marketType
                final matchOddsEvents = date.events.where((event) => event.risk.marketType == MarketType.matchOdds).toList();
                final otherEvents = date.events.where((event) => event.risk.marketType != MarketType.matchOdds || event.eventName == ipl).toList();
                if (matchOddsEvents.isNotEmpty) {
                  matchOddsDates.add(OddsDate(date: date.date, events: matchOddsEvents));
                }

                if (otherEvents.isNotEmpty) {
                  otherMarketsDates.add(OddsDate(date: date.date, events: otherEvents));
                }
              }

              if (matchOddsDates.isNotEmpty) {
                matchOddsData.add(OpenOddsData(
                  sid: report.sid,
                  sportName: report.sportName,
                  dates: matchOddsDates,
                ));
              }

              if (otherMarketsDates.isNotEmpty) {
                otherMarketsData.add(OpenOddsData(
                  sid: report.sid,
                  sportName: report.sportName,
                  dates: otherMarketsDates,
                ));
              }
            }

            emit(FetchOpenOddsSuccess(
              openOddsData: matchOddsData,
              otherMarkets: otherMarketsData,
            ));
          } else {
            if (kDebugMode) debugPrint("fetch_open_odds_bloc.dart [response error]>> ${response.statusCode}");
            emit(FetchOpenOddsFailure('fetch_open_odds_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(FetchOpenOddsFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_open_odds_bloc.dart [Try Block Exception]>> \n $e');
        emit(FetchOpenOddsFailure(handleError(e)));
      }
    });
    on<FetchOpenOddsInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchOpenOddsInt');
      emit(FetchOpenOddsInitial());
    });
  }
}

// states
abstract class FetchOpenOddsState {}

// events
abstract class FetchOpenOddsEvent {}

// states implementation
class FetchOpenOddsInitial extends FetchOpenOddsState {}

class FetchOpenOddsProgress extends FetchOpenOddsState {}

class FetchOpenOddsSuccess extends FetchOpenOddsState {
  FetchOpenOddsSuccess({required this.openOddsData, required this.otherMarkets});
  final List<OpenOddsData> openOddsData;
  final List<OpenOddsData> otherMarkets;
}

class FetchOpenOddsFailure extends FetchOpenOddsState {
  FetchOpenOddsFailure(this.error);
  final String error;
}

// events implementation
class FetchOpenOdds extends FetchOpenOddsEvent {
  final String userName;
  FetchOpenOdds({required this.userName});
}

class FetchOpenOddsInt extends FetchOpenOddsEvent {}
