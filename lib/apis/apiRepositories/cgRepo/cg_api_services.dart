import 'package:chopper/chopper.dart';

import '../../../model/bet_list_model.dart';
import '../../../model/casino_balance_log_model.dart';
import '../../../model/casino_history_model.dart';
import '../../../model/order_events_model.dart';
import '../../../model/premium_runner_wise_report_model.dart';
import '../../../model/premium_sport_model.dart';
import '../../../model/sport_book_pl_model.dart';
import '../../../model/sports_book_model.dart';
import '../../apiHandlers/api_constants.dart';
import '../../apiHandlers/api_interceptors.dart';
import '../../apiHandlers/json_to_type_converter.dart';

part 'cg_api_services.chopper.dart';

final _cgApiClient = ChopperClient(
  baseUrl: Uri.parse(CGApiConstants.baseUrl),
  converter: JsonSerializableConverter(
    {
      BetResponse: (json) => BetResponse.fromJson(json),
      OrderEventResponse: (json) => OrderEventResponse.fromJson(json),
      SportsBookResponse: (json) => SportsBookResponse.fromJson(json),
      SportBookPlResponse: (json) => SportBookPlResponse.fromJson(json),
      PremiumSportResponse: (json) => PremiumSportResponse.fromJson(json),
      CasinoHistoryResponse: (json) => CasinoHistoryResponse.fromJson(json),
      CasinoBalanceLogResponse: (json) => CasinoBalanceLogResponse.fromJson(json),
      PremiumRunnerWiseReportResponse: (json) => PremiumRunnerWiseReportResponse.fromJson(json),
    },
  ),
  interceptors: [ApiAuthInterceptor(), ApiResponseInterceptor(), ApiRequestInterceptor()],
  errorConverter: const JsonConverter(),
);

@ChopperApi(baseUrl: CGApiConstants.baseUrl)
abstract class CGApiServices extends ChopperService {
  ///Don't modify
  static CGApiServices create() {
    return _$CGApiServices(_cgApiClient);
  }

  @GET(path: CGApiConstants.history)
  Future<Response<CasinoHistoryResponse>> getCGHistory(
    @Query("userName") String? userName,
    @Query("from") String? from,
    @Query("to") String? to,
    @Query("page") int? page,
    @Query("limit") int? limit,
  );

  @GET(path: CGApiConstants.casinoHistory)
  Future<Response<CasinoBalanceLogResponse>> getCGBalanceLog(
    @Query("status") String? status,
    @Query("userName") String? userName,
    @Query("from") String? from,
    @Query("to") String? to,
    @Query("page") int? page,
    @Query("limit") int? limit,
  );

  @GET(path: CGApiConstants.sportsBook)
  Future<Response<SportsBookResponse>> getCGSportsBook(
    @Query("status") String? status,
    @Query("userName") String? userName,
    @Query("from") String? from,
    @Query("to") String? to,
    @Query("page") int? page,
    @Query("limit") int? limit,
    @Query("orderIds") String? orderIds,
  );

  @GET(path: CGApiConstants.sportsBookDetail)
  Future<Response<SportBookPlResponse>> getCGSportsBookDetail(
    @Query("userName") String? userName,
    @Query("from") String? from,
    @Query("to") String? to,
    @Query("page") int? page,
    @Query("limit") int? limit,
  );

  @GET(path: CGApiConstants.sportBookBetList)
  Future<BetResponse> getCGSportsBookBetList(
    @Query("status") String? status,
    @Query("sport") String? sport,
    @Query("orderIds") String? orderIds,
    @Query("UserName") String? userName,
    @Query("UserId") String? userId,
    @Query("From") String? from,
    @Query("TO") String? to,
    @Query("Limit") int? limit,
    @Query("Page") int? page,
    @Query("EventIds") String? eventIds,
    @Query("MarketIds") String? marketIds,
    @Query("IP") String? ip,
    @Query("ISP") String? isp,
    @Query("OddDiff") String? oddDiff,
    @Query("OddDiffGreater") bool? oddDiffGreater,
    @Query("Stake") String? stake,
    @Query("column") String? column,
    @Query("columnAsc") bool? isAscending,
    @Query("StakeGreater") bool? stakeGreater,
  );

  @GET(path: CGApiConstants.premiumSport)
  Future<Response<PremiumSportResponse>> getCGPremiumSport(
    @Query("sportName") String? sportName,
    @Query("userName") String? userName,
  );

  @GET(path: CGApiConstants.premiumRunnerReport)
  Future<PremiumRunnerWiseReportResponse> getPremiumRunnerWiseReport(
    @Query("marketId") String marketId,
    @Query("runnerName") String runnerName,
    @Query("username") String userName,
  );

  @GET(path: CGApiConstants.sportBookBetEventsList)
  Future<OrderEventResponse> getSportBookBetEventsList(
    @Query("status") String? status,
    @Query("sport") String? sport,
    @Query("orderIds") String? orderIds,
    @Query("UserName") String? userName,
    @Query("UserId") String? userId,
    @Query("From") String? from,
    @Query("TO") String? to,
    @Query("Limit") int? limit,
    @Query("Page") int? page,
    @Query("EventIds") String? eventIds,
    @Query("MarketIds") String? marketIds,
    @Query("IP") String? ip,
    @Query("ISP") String? isp,
    @Query("OddDiff") String? oddDiff,
    @Query("OddDiffGreater") bool? oddDiffGreater,
  );
}
