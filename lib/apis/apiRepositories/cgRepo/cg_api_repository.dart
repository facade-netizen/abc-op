import 'package:chopper/chopper.dart';
import '../../../model/bet_list_model.dart';
import '../../../model/casino_balance_log_model.dart';
import '../../../model/casino_history_model.dart';
import '../../../model/order_events_model.dart';
import '../../../model/premium_runner_wise_report_model.dart';
import '../../../model/premium_sport_model.dart';
import '../../../model/sport_book_pl_model.dart';
import '../../../model/sports_book_model.dart';
import 'cg_api_services.dart';

class CGApiRepository {
  CGApiRepository() : _cgApiServices = CGApiServices.create();
  final CGApiServices _cgApiServices;

  ///get CG history
  Future<Response<CasinoHistoryResponse>> getCGHistory({
    String? userName,
    String? from,
    String? to,
    int? page,
    int? limit,
  }) async {
    try {
      return _cgApiServices.getCGHistory(
        userName,
        from,
        to,
        page,
        limit,
      );
    } catch (e) {
      rethrow;
    }
  }

  ///get CG balance log
  Future<Response<CasinoBalanceLogResponse>> getCGBalanceLog({
    String? status,
    String? userName,
    String? from,
    String? to,
    int? page,
    int? limit,
  }) async {
    try {
      return _cgApiServices.getCGBalanceLog(
        status,
        userName,
        from,
        to,
        page,
        limit,
      );
    } catch (e) {
      rethrow;
    }
  }

  ///get CG sports book
  Future<Response<SportsBookResponse>> getCGSportsBook({
    String? status,
    String? userName,
    String? from,
    String? to,
    int? page,
    int? limit,
    String? orderIds,
  }) async {
    try {
      return _cgApiServices.getCGSportsBook(
        status,
        userName,
        from,
        to,
        page,
        limit,
        orderIds,
      );
    } catch (e) {
      rethrow;
    }
  }

  ///get CG sports book detail
  Future<Response<SportBookPlResponse>> getCGSportsBookDetail({
    String? userName,
    String? from,
    String? to,
    int? page,
    int? limit,
  }) async {
    try {
      return _cgApiServices.getCGSportsBookDetail(
        userName,
        from,
        to,
        page,
        limit,
      );
    } catch (e) {
      rethrow;
    }
  }

  ///get CG premium sport
  Future<Response<PremiumSportResponse>> getCGPremiumSport({String? sportName, required String userName}) async {
    try {
      return _cgApiServices.getCGPremiumSport(sportName, userName);
    } catch (e) {
      rethrow;
    }
  }

  ///get CG premium runner wise report
  Future<PremiumRunnerWiseReportResponse> getPremiumRunnerWiseReport({
    required String marketId,
    required String runnerName,
    required String userName,
  }) async {
    try {
      return _cgApiServices.getPremiumRunnerWiseReport(marketId, runnerName, userName);
    } catch (e) {
      rethrow;
    }
  }

  ///get CG sports book bet list
  Future<BetResponse> getCGSportsBookBetList({
    String? status,
    String? sport,
    String? orderIds,
    String? userName,
    String? userId,
    String? from,
    String? to,
    int? limit,
    int? page,
    String? eventIds,
    String? marketIds,
    String? ip,
    String? isp,
    String? oddDiff,
    bool? oddDiffGreater,
    String? stake,
    String? column,
    bool? isAscending,
    bool? stakeGreater,
  }) async {
    try {
      return _cgApiServices.getCGSportsBookBetList(
        status,
        sport,
        orderIds,
        userName,
        userId,
        from,
        to,
        limit,
        page,
        eventIds,
        marketIds,
        ip,
        isp,
        oddDiff,
        oddDiffGreater,
        stake,
        column,
        isAscending,
        stakeGreater,
      );
    } catch (e) {
      rethrow;
    }
  }

  ///getSportBookBetEventsList
  Future<OrderEventResponse> getSportBookBetEventsList({
    String? status,
    String? sport,
    String? orderIds,
    String? userName,
    String? userId,
    String? from,
    String? to,
    int? limit,
    int? page,
    String? eventIds,
    String? marketIds,
    String? ip,
    String? isp,
    String? oddDiff,
    bool? oddDiffGreater,
  }) async {
    try {
      return _cgApiServices.getSportBookBetEventsList(
        status,
        sport,
        orderIds,
        userName,
        userId,
        from,
        to,
        limit,
        page,
        eventIds,
        marketIds,
        ip,
        isp,
        oddDiff,
        oddDiffGreater,
      );
    } catch (e) {
      rethrow;
    }
  }
}
