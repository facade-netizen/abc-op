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
import '../../apiHandlers/api_constants.dart';
import '../../apiHandlers/api_interceptors.dart';
import '../../apiHandlers/json_to_type_converter.dart';

part 'orders_api_services.chopper.dart';

final _ordersApiClient = ChopperClient(
  baseUrl: Uri.parse(AuthApiConstants.baseUrl),
  converter: JsonSerializableConverter({
    BetResponse: (json) => BetResponse.fromJson(json),
    MarketPlModel: (json) => MarketPlModel.fromJson(json),
    OpenBMResponse: (json) => OpenBMResponse.fromJson(json),
    BMBookResponse: (json) => BMBookResponse.fromJson(json),
    OpenOddsResponse: (json) => OpenOddsResponse.fromJson(json),
    OpenFancyResponse: (json) => OpenFancyResponse.fromJson(json),
    FancyBookResponse: (json) => FancyBookResponse.fromJson(json),
    OrderEventResponse: (json) => OrderEventResponse.fromJson(json),
    LifeTimeReportResponse: (json) => LifeTimeReportResponse.fromJson(json),
    SportWiseReportResponse: (json) => SportWiseReportResponse.fromJson(json),
    RunnerWiseReportResponse: (json) => RunnerWiseReportResponse.fromJson(json),
    PlayerBetHistoryResponse: (json) => PlayerBetHistoryResponse.fromJson(json),
    BalanceLogSummaryResponse: (json) => BalanceLogSummaryResponse.fromJson(json),
    TopPlayerExposureResponse: (json) => TopPlayerExposureResponse.fromJson(json),
    PlayerProfitAndLossResponse: (json) => PlayerProfitAndLossResponse.fromJson(json),
  }),
  interceptors: [ApiAuthInterceptor(), ApiResponseInterceptor(), ApiRequestInterceptor()],
  errorConverter: const JsonConverter(),
);

@ChopperApi(baseUrl: OrdersApiConstants.baseUrl)
abstract class OrdersApiServices extends ChopperService {
  ///Don't modify
  static OrdersApiServices create() {
    return _$OrdersApiServices(_ordersApiClient);
  }

  @GET(path: OrdersApiConstants.topExposures)
  Future<TopPlayerExposureResponse> getTopExposurePlayers(
    @Query("userName") String userName,
  );

  @GET(path: OrdersApiConstants.riskManagement)
  Future<Response<OpenOddsResponse>> getOpenOdds(
    @Query("userName") String userName,
    @Query("bettingType") int bettingType,
  );

  @GET(path: OrdersApiConstants.riskManagement)
  Future<Response<OpenBMResponse>> getBM(
    @Query("userName") String userName,
    @Query("bettingType") int bettingType,
  );

  @GET(path: OrdersApiConstants.riskManagement)
  Future<Response<OpenFancyResponse>> getFancy(
    @Query("userName") String userName,
    @Query("bettingType") int bettingType,
  );

  @GET(path: OrdersApiConstants.betlist)
  Future<BetResponse> getBetList(
    @Query("userName") String? userName,
    @Query("from") String? from,
    @Query("to") String? to,
    @Query("sid") int? sid,
    @Query("marketIds") String? marketIds,
    @Query("eventIds") String? eventIds,
    @Query("sports") List<String> sports,
    @Query("isDone") bool? isDone,
    @Query("status") String? status,
    @Query("bettingType") int? bettingType,
    @Query("page") int? page,
    @Query("limit") int? limit,
    @Query("ip") String? ip,
    @Query("isp") String? isp,
    @Query("column") String? column,
    @Query("isASC") bool? isAscending,
    @Query("BetIds") String? betIds,
    @Query("stake") double? stake,
    @Query("diffOdds") double? diffOdds,
    @Query("stakeGreater") bool? stakeGreater,
    @Query("oddDiffGreater") bool? oddDiffGreater,
    @Query("side") String? side,
  );

  @GET(path: OrdersApiConstants.riskMonitoring)
  Future<BetResponse> getRiskMonitoring(
    @Query("userName") String? userName,
    @Query("from") String? from,
    @Query("to") String? to,
    @Query("sid") int? sid,
    @Query("marketIds") String? marketIds,
    @Query("eventIds") String? eventIds,
    @Query("sports") List<String> sports,
    @Query("isDone") bool? isDone,
    @Query("status") String? status,
    @Query("bettingType") int? bettingType,
    @Query("page") int? page,
    @Query("limit") int? limit,
    @Query("ip") String? ip,
    @Query("isp") String? isp,
    @Query("column") String? column,
    @Query("isASC") bool? isAscending,
    @Query("BetIds") String? betIds,
    @Query("stake") double? stake,
    @Query("diffOdds") double? diffOdds,
    @Query("stakeGreater") bool? stakeGreater,
    @Query("oddDiffGreater") bool? oddDiffGreater,
    @Query("side") String? side,
    @Query("SameSelectionBL") bool? sameSelectionBL,
    @Query("DiffSelectionBB") bool? diffSelectionBB,
    @Query("DiffSelectionLL") bool? diffSelectionLL,
    @Query("TimePeriod") int? timePeriod,
  );

  @GET(path: OrdersApiConstants.orderEvents)
  Future<OrderEventResponse> getOrderEvents(
    @Query("userName") String? userName,
    @Query("from") String? from,
    @Query("to") String? to,
    @Query("sid") int? sid,
    @Query("marketIds") String? marketIds,
    @Query("eventIds") String? eventIds,
    @Query("sports") List<String> sports,
    @Query("isDone") bool? isDone,
    @Query("status") String? status,
    @Query("bettingType") int? bettingType,
    @Query("page") int? page,
    @Query("limit") int? limit,
    @Query("ip") String? ip,
    @Query("isp") String? isp,
    @Query("column") String? column,
    @Query("isASC") bool? isAscending,
    @Query("BetIds") String? betIds,
    @Query("stake") double? stake,
    @Query("diffOdds") double? diffOdds,
    @Query("stakeGreater") bool? stakeGreater,
    @Query("oddDiffGreater") bool? oddDiffGreater,
    @Query("side") String? side,
  );

  @POST(path: OrdersApiConstants.groupProfitLoss)
  Future<MarketPlModel> getMarketPl({@Body() required Map<String, dynamic> body});

  @POST(path: OrdersApiConstants.profitLoss)
  Future<PlayerProfitAndLossResponse> getPlayerProfitAndLoss({@Body() required Map<String, dynamic> body});

  @POST(path: OrdersApiConstants.orderReport)
  Future<PlayerBetHistoryResponse> getPlayerBetHistory({@Body() required Map<String, dynamic> body});

  @POST(path: OrdersApiConstants.matchBook)
  Future<FancyBookResponse> getFancyBook({@Body() required Map<String, dynamic> body});

  @GET(path: OrdersApiConstants.userBook)
  Future<BMBookResponse> getBMBook(
    @Query("marketId") String? marketId,
    @Query("userId") String? userId,
    @Query("username") String? userName,
  );

  @POST(path: OrdersApiConstants.orderLogSummary)
  Future<BalanceLogSummaryResponse> getBalanceLogsSummary({@Body() required Map<String, dynamic> body});

  @POST(path: OrdersApiConstants.negativeOrderLogSummary)
  Future<BalanceLogSummaryResponse> getNegativeBalanceLogsSummary({@Body() required Map<String, dynamic> body});

  @GET(path: OrdersApiConstants.lifeTimeReport)
  Future<LifeTimeReportResponse> getLifeTimeReport(
    @Query("userNames") String? userName,
  );

  @GET(path: OrdersApiConstants.runnerWiseReport)
  Future<RunnerWiseReportResponse> getRunnerWiseReport(
    @Query("marketId") String marketId,
    @Query("runnerId") String runnerId,
    @Query("userName") String userName,
  );

  @GET(path: OrdersApiConstants.sportWiseReport)
  Future<SportWiseReportResponse> getSportWiseReport(
    @Query("sid") String sid,
    @Query("username") String username,
    @Query("eventId") String? eventId,
    @Query("bettingType") int bettingType,
  );
}
