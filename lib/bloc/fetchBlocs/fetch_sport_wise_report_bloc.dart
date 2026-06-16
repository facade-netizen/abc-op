import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/sport_wise_report_model.dart';
import 'handle_error.dart';

String ipl = 'Indian Premier League';
String matchOdds = 'match_odds';
String bookmaker = 'bookmaker';

class FetchSportWiseReportBloc extends Bloc<FetchSportWiseReportEvent, FetchSportWiseReportState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchSportWiseReportBloc(this._ordersApiRepository) : super(FetchSportWiseReportInitial()) {
    on<FetchSportWiseReport>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchSportWiseReportBloc');
      emit(FetchSportWiseReportProgress());
      // checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final response = await _ordersApiRepository.getSportWiseReport(
            sid: event.sid,
            username: event.userName,
            bettingType: event.bettingType,
            eventId: event.eventId,
          );

          if (response.status == 200) {
            // Separate data based on marketType
            final List<SportWiseReportData> matchOddsData = [];
            final List<SportWiseReportData> otherMarketsData = [];

            for (var report in response.data) {
              // Separate details based on marketType
              final matchOddsDetails = report.detail.where((detail) => detail.marketType != MarketType.otherMarkets).toList();
              final otherDetails = report.detail.where((detail) => detail.marketType == MarketType.otherMarkets || detail.eventName == ipl).toList();

              if (matchOddsDetails.isNotEmpty) {
                matchOddsData.add(SportWiseReportData(
                  date: report.date,
                  detail: matchOddsDetails,
                ));
              }

              if (otherDetails.isNotEmpty) {
                otherMarketsData.add(SportWiseReportData(
                  date: report.date,
                  detail: otherDetails,
                ));
              }
            }

            emit(FetchSportWiseReportSuccess(
              reports: matchOddsData,
              otherMarkets: otherMarketsData,
            ));
          } else {
            if (kDebugMode) debugPrint("fetch_sport_wise_report_bloc.dart [response error]>> ${response.status}");
            emit(FetchSportWiseReportFailure(response.message));
          }
        } else {
          emit(FetchSportWiseReportFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_sport_wise_report_bloc.dart [Try Block Exception]>> \n $e');
        emit(FetchSportWiseReportFailure(handleError(e)));
      }
    });

    on<FetchSportWiseReportInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchSportWiseReportInt');
      emit(FetchSportWiseReportInitial());
    });
  }
}

// states
abstract class FetchSportWiseReportState {}

// events
abstract class FetchSportWiseReportEvent {}

// states implementation
class FetchSportWiseReportInitial extends FetchSportWiseReportState {}

class FetchSportWiseReportProgress extends FetchSportWiseReportState {}

class FetchSportWiseReportSuccess extends FetchSportWiseReportState {
  FetchSportWiseReportSuccess({required this.reports, required this.otherMarkets});
  final List<SportWiseReportData> reports;
  final List<SportWiseReportData> otherMarkets;
}

class FetchSportWiseReportFailure extends FetchSportWiseReportState {
  FetchSportWiseReportFailure(this.error);
  final String error;
}

// events implementation
class FetchSportWiseReport extends FetchSportWiseReportEvent {
  FetchSportWiseReport({
    required this.sid,
    required this.bettingType,
    required this.userName,
    this.eventId = '',
  });
  final String sid;
  final int bettingType;
  final String eventId;
  final String userName;
}

class FetchSportWiseReportInt extends FetchSportWiseReportEvent {}
