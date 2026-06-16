// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_api_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$OrdersApiServices extends OrdersApiServices {
  _$OrdersApiServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = OrdersApiServices;

  @override
  Future<TopPlayerExposureResponse> getTopExposurePlayers(
      String userName) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/topExposures');
    final Map<String, dynamic> $params = <String, dynamic>{
      'userName': userName
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response $response = await client
        .send<TopPlayerExposureResponse, TopPlayerExposureResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<Response<OpenOddsResponse>> getOpenOdds(
    String userName,
    int bettingType,
  ) {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/riskManagement');
    final Map<String, dynamic> $params = <String, dynamic>{
      'userName': userName,
      'bettingType': bettingType,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<OpenOddsResponse, OpenOddsResponse>($request);
  }

  @override
  Future<Response<OpenBMResponse>> getBM(
    String userName,
    int bettingType,
  ) {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/riskManagement');
    final Map<String, dynamic> $params = <String, dynamic>{
      'userName': userName,
      'bettingType': bettingType,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<OpenBMResponse, OpenBMResponse>($request);
  }

  @override
  Future<Response<OpenFancyResponse>> getFancy(
    String userName,
    int bettingType,
  ) {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/riskManagement');
    final Map<String, dynamic> $params = <String, dynamic>{
      'userName': userName,
      'bettingType': bettingType,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<OpenFancyResponse, OpenFancyResponse>($request);
  }

  @override
  Future<BetResponse> getBetList(
    String? userName,
    String? from,
    String? to,
    int? sid,
    String? marketIds,
    String? eventIds,
    List<String> sports,
    bool? isDone,
    String? status,
    int? bettingType,
    int? page,
    int? limit,
    String? ip,
    String? isp,
    String? column,
    bool? isAscending,
    String? betIds,
    double? stake,
    double? diffOdds,
    bool? stakeGreater,
    bool? oddDiffGreater,
    String? side,
  ) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/betlist');
    final Map<String, dynamic> $params = <String, dynamic>{
      'userName': userName,
      'from': from,
      'to': to,
      'sid': sid,
      'marketIds': marketIds,
      'eventIds': eventIds,
      'sports': sports,
      'isDone': isDone,
      'status': status,
      'bettingType': bettingType,
      'page': page,
      'limit': limit,
      'ip': ip,
      'isp': isp,
      'column': column,
      'isASC': isAscending,
      'BetIds': betIds,
      'stake': stake,
      'diffOdds': diffOdds,
      'stakeGreater': stakeGreater,
      'oddDiffGreater': oddDiffGreater,
      'side': side,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response $response =
        await client.send<BetResponse, BetResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<BetResponse> getRiskMonitoring(
    String? userName,
    String? from,
    String? to,
    int? sid,
    String? marketIds,
    String? eventIds,
    List<String> sports,
    bool? isDone,
    String? status,
    int? bettingType,
    int? page,
    int? limit,
    String? ip,
    String? isp,
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
  ) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/riskMonitoring');
    final Map<String, dynamic> $params = <String, dynamic>{
      'userName': userName,
      'from': from,
      'to': to,
      'sid': sid,
      'marketIds': marketIds,
      'eventIds': eventIds,
      'sports': sports,
      'isDone': isDone,
      'status': status,
      'bettingType': bettingType,
      'page': page,
      'limit': limit,
      'ip': ip,
      'isp': isp,
      'column': column,
      'isASC': isAscending,
      'BetIds': betIds,
      'stake': stake,
      'diffOdds': diffOdds,
      'stakeGreater': stakeGreater,
      'oddDiffGreater': oddDiffGreater,
      'side': side,
      'SameSelectionBL': sameSelectionBL,
      'DiffSelectionBB': diffSelectionBB,
      'DiffSelectionLL': diffSelectionLL,
      'TimePeriod': timePeriod,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response $response =
        await client.send<BetResponse, BetResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<OrderEventResponse> getOrderEvents(
    String? userName,
    String? from,
    String? to,
    int? sid,
    String? marketIds,
    String? eventIds,
    List<String> sports,
    bool? isDone,
    String? status,
    int? bettingType,
    int? page,
    int? limit,
    String? ip,
    String? isp,
    String? column,
    bool? isAscending,
    String? betIds,
    double? stake,
    double? diffOdds,
    bool? stakeGreater,
    bool? oddDiffGreater,
    String? side,
  ) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/orderEvents');
    final Map<String, dynamic> $params = <String, dynamic>{
      'userName': userName,
      'from': from,
      'to': to,
      'sid': sid,
      'marketIds': marketIds,
      'eventIds': eventIds,
      'sports': sports,
      'isDone': isDone,
      'status': status,
      'bettingType': bettingType,
      'page': page,
      'limit': limit,
      'ip': ip,
      'isp': isp,
      'column': column,
      'isASC': isAscending,
      'BetIds': betIds,
      'stake': stake,
      'diffOdds': diffOdds,
      'stakeGreater': stakeGreater,
      'oddDiffGreater': oddDiffGreater,
      'side': side,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response $response =
        await client.send<OrderEventResponse, OrderEventResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<MarketPlModel> getMarketPl(
      {required Map<String, dynamic> body}) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/groupProfitLoss');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response =
        await client.send<MarketPlModel, MarketPlModel>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<PlayerProfitAndLossResponse> getPlayerProfitAndLoss(
      {required Map<String, dynamic> body}) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/profitLoss-void');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response = await client.send<PlayerProfitAndLossResponse,
        PlayerProfitAndLossResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<PlayerBetHistoryResponse> getPlayerBetHistory(
      {required Map<String, dynamic> body}) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/orderReport');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response = await client
        .send<PlayerBetHistoryResponse, PlayerBetHistoryResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<FancyBookResponse> getFancyBook(
      {required Map<String, dynamic> body}) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/matchBook');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response =
        await client.send<FancyBookResponse, FancyBookResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<BMBookResponse> getBMBook(
    String? marketId,
    String? userId,
    String? userName,
  ) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/userBook-OP');
    final Map<String, dynamic> $params = <String, dynamic>{
      'marketId': marketId,
      'userId': userId,
      'username': userName,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response $response =
        await client.send<BMBookResponse, BMBookResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<BalanceLogSummaryResponse> getBalanceLogsSummary(
      {required Map<String, dynamic> body}) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/orderLogSummary');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response = await client
        .send<BalanceLogSummaryResponse, BalanceLogSummaryResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<BalanceLogSummaryResponse> getNegativeBalanceLogsSummary(
      {required Map<String, dynamic> body}) async {
    final Uri $url =
        Uri.parse('https://abcorder.dmxchge.com/negative-OrderLogSummary');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response = await client
        .send<BalanceLogSummaryResponse, BalanceLogSummaryResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<LifeTimeReportResponse> getLifeTimeReport(String? userName) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/lifeTimeReport');
    final Map<String, dynamic> $params = <String, dynamic>{
      'userNames': userName
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response $response = await client
        .send<LifeTimeReportResponse, LifeTimeReportResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<RunnerWiseReportResponse> getRunnerWiseReport(
    String marketId,
    String runnerId,
    String userName,
  ) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/runnerWiseReport');
    final Map<String, dynamic> $params = <String, dynamic>{
      'marketId': marketId,
      'runnerId': runnerId,
      'userName': userName,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response $response = await client
        .send<RunnerWiseReportResponse, RunnerWiseReportResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<SportWiseReportResponse> getSportWiseReport(
    String sid,
    String username,
    String? eventId,
    int bettingType,
  ) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/sportWiseReport');
    final Map<String, dynamic> $params = <String, dynamic>{
      'sid': sid,
      'username': username,
      'eventId': eventId,
      'bettingType': bettingType,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response $response = await client
        .send<SportWiseReportResponse, SportWiseReportResponse>($request);
    return $response.bodyOrThrow;
  }
}
