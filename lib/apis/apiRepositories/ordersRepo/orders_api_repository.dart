import 'package:chopper/chopper.dart';

import '../../../model/balance_summary_logs_model.dart';
import '../../../model/bet_list_model.dart';
import '../../../model/bm_book_model.dart';
import '../../../model/life_time_report_model.dart';
import '../../../model/market_pl_model.dart';
import '../../../model/open_bm_bets_model.dart';
import '../../../model/open_fancy_bets_model.dart';
import '../../../model/open_odds_bets_model.dart';
import '../../../model/order_events_model.dart';
import '../../../model/player_bet_history_model.dart';
import '../../../model/players_profit_and_loss_model.dart';
import '../../../model/runner_wise_report_model.dart';
import '../../../model/runners_pl_model.dart';
import '../../../model/sport_wise_report_model.dart';
import '../../../model/top_exposure_player_model.dart';
import 'orders_api_services.dart';

class OrdersApiRepository {
  OrdersApiRepository() : _ordersApiServices = OrdersApiServices.create();
  final OrdersApiServices _ordersApiServices;

  ///get top exposure
  Future<TopPlayerExposureResponse> getTopExposurePlayers(String userName) async {
    try {
      return _ordersApiServices.getTopExposurePlayers(userName);
    } catch (e) {
      rethrow;
    }
  }

  ///Open Odds
  Future<Response<OpenOddsResponse>> getOpenOdds(String userName, int bettingType) async {
    try {
      return _ordersApiServices.getOpenOdds(userName, bettingType);
    } catch (e) {
      rethrow;
    }
  }

  ///Open BM
  Future<Response<OpenBMResponse>> getBM(String userName, int bettingType) async {
    try {
      return _ordersApiServices.getBM(userName, bettingType);
    } catch (e) {
      rethrow;
    }
  }

  ///Open Fancy
  Future<Response<OpenFancyResponse>> getFancy(String userName, int bettingType) async {
    try {
      return _ordersApiServices.getFancy(userName, bettingType);
    } catch (e) {
      rethrow;
    }
  }

  ///bet list data
  Future<BetResponse> getBetList({
    String? userName,
    String? from,
    String? to,
    int? sid,
    String? marketIds,
    String? eventIds,
    bool? isDone,
    String? status,
    String? ip,
    String? isp,
    int? bettingType,
    int? page,
    int? limit,
    List<String> sports = const [],
    String? column,
    bool? isAscending,
    String? betIds,
    double? stake,
    double? diffOdds,
    bool? stakeGreater,
    bool? oddDiffGreater,
    String? side,
  }) async {
    try {
      return await _ordersApiServices.getBetList(
        userName,
        from,
        to,
        sid,
        marketIds,
        eventIds,
        sports,
        isDone,
        status,
        bettingType,
        page,
        limit,
        ip,
        isp,
        column,
        isAscending,
        betIds,
        stake,
        diffOdds,
        stakeGreater,
        oddDiffGreater,
        side,
      );
    } catch (e) {
      rethrow;
    }
  }

  ///risk monitoring data
  Future<BetResponse> getRiskMonitoring({
    String? userName,
    String? from,
    String? to,
    int? sid,
    String? marketIds,
    String? eventIds,
    bool? isDone,
    String? status,
    String? ip,
    String? isp,
    int? bettingType,
    int? page,
    int? limit,
    List<String> sports = const [],
    String? column,
    bool? isAscending,
    String? betIds,
    double? stake,
    double? diffOdds,
    bool? stakeGreater,
    bool? oddDiffGreater,
    String? side,
    bool? sameSelectionBL,
    bool? diffSelectionBB,
    bool? diffSelectionLL,
    int? timePeriod,
  }) async {
    try {
      return await _ordersApiServices.getRiskMonitoring(
        userName,
        from,
        to,
        sid,
        marketIds,
        eventIds,
        sports,
        isDone,
        status,
        bettingType,
        page,
        limit,
        ip,
        isp,
        column,
        isAscending,
        betIds,
        stake,
        diffOdds,
        stakeGreater,
        oddDiffGreater,
        side,
        sameSelectionBL,
        diffSelectionBB,
        diffSelectionLL,
        timePeriod,
      );
    } catch (e) {
      rethrow;
    }
  }

  ///order events list data
  Future<OrderEventResponse> getOrderEventsList({
    String? userName,
    String? from,
    String? to,
    int? sid,
    String? marketIds,
    String? eventIds,
    bool? isDone,
    String? status,
    String? ip,
    String? isp,
    int? bettingType,
    int? page,
    int? limit,
    List<String> sports = const [],
    String? column,
    bool? isAscending,
    String? betIds,
    double? stake,
    double? diffOdds,
    bool? stakeGreater,
    bool? oddDiffGreater,
    String? side,
  }) async {
    try {
      return await _ordersApiServices.getOrderEvents(
        userName,
        from,
        to,
        sid,
        marketIds,
        eventIds,
        sports,
        isDone,
        status,
        bettingType,
        page,
        limit,
        ip,
        isp,
        column,
        isAscending,
        betIds,
        stake,
        diffOdds,
        stakeGreater,
        oddDiffGreater,
        side,
      );
    } catch (e) {
      rethrow;
    }
  }

  ///get market pl
  Future<MarketPlModel> getMarketProfitLoss({required Map<String, dynamic> body}) async {
    try {
      return await _ordersApiServices.getMarketPl(body: body);
    } catch (e) {
      rethrow;
    }
  }

  ///getPlayerProfitAndLoss
  Future<PlayerProfitAndLossResponse> getPlayerProfitAndLoss({required Map<String, dynamic> body}) async {
    return await _ordersApiServices.getPlayerProfitAndLoss(body: body);
  }

  ///getPlayerBetHistory
  Future<PlayerBetHistoryResponse> getPlayerBetHistory({required Map<String, dynamic> body}) async {
    return await _ordersApiServices.getPlayerBetHistory(body: body);
  }

  Future<FancyBookResponse> getFancyBook({required Map<String, dynamic> body}) async {
    return await _ordersApiServices.getFancyBook(body: body);
  }

  Future<BMBookResponse> getBMBook(String? marketId, String? userId, String? userName) async {
    return await _ordersApiServices.getBMBook(marketId, userId, userName);
  }

  ///get balance logs summary
  Future<BalanceLogSummaryResponse> getBalanceLogsSummary({required Map<String, dynamic> body}) async {
    try {
      return await _ordersApiServices.getBalanceLogsSummary(body: body);
    } catch (e) {
      rethrow;
    }
  }

  ///get negative balance logs summary
  Future<BalanceLogSummaryResponse> getNegativeBalanceLogsSummary({required Map<String, dynamic> body}) async {
    try {
      return await _ordersApiServices.getNegativeBalanceLogsSummary(body: body);
    } catch (e) {
      rethrow;
    }
  }

  ///get life time report
  Future<LifeTimeReportResponse> getLifeTimeReportData({required String userName}) async {
    try {
      return await _ordersApiServices.getLifeTimeReport(userName);
    } catch (e) {
      rethrow;
    }
  }

  ///get runner wise report
  Future<RunnerWiseReportResponse> getRunnerWiseReport({
    required String marketId,
    required String runnerId,
    required String userName,
  }) async {
    try {
      return await _ordersApiServices.getRunnerWiseReport(marketId, runnerId, userName);
    } catch (e) {
      rethrow;
    }
  }

  ///get sport wise report
  Future<SportWiseReportResponse> getSportWiseReport({
    required String sid,
    required int bettingType,
    required String eventId,
    required String username,
  }) async {
    try {
      return await _ordersApiServices.getSportWiseReport(sid, username, eventId, bettingType);
    } catch (e) {
      rethrow;
    }
  }
}
