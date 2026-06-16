// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cg_api_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$CGApiServices extends CGApiServices {
  _$CGApiServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = CGApiServices;

  @override
  Future<Response<CasinoHistoryResponse>> getCGHistory(
    String? userName,
    String? from,
    String? to,
    int? page,
    int? limit,
  ) {
    final Uri $url = Uri.parse('https://rgc.dmxchge.com/api/Casino/history-OP');
    final Map<String, dynamic> $params = <String, dynamic>{
      'userName': userName,
      'from': from,
      'to': to,
      'page': page,
      'limit': limit,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<CasinoHistoryResponse, CasinoHistoryResponse>($request);
  }

  @override
  Future<Response<CasinoBalanceLogResponse>> getCGBalanceLog(
    String? status,
    String? userName,
    String? from,
    String? to,
    int? page,
    int? limit,
  ) {
    final Uri $url =
        Uri.parse('https://rgc.dmxchge.com/api/Casino/casinoHistory');
    final Map<String, dynamic> $params = <String, dynamic>{
      'status': status,
      'userName': userName,
      'from': from,
      'to': to,
      'page': page,
      'limit': limit,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client
        .send<CasinoBalanceLogResponse, CasinoBalanceLogResponse>($request);
  }

  @override
  Future<Response<SportsBookResponse>> getCGSportsBook(
    String? status,
    String? userName,
    String? from,
    String? to,
    int? page,
    int? limit,
    String? orderIds,
  ) {
    final Uri $url =
        Uri.parse('https://rgc.dmxchge.com/api/Casino/sportHistory');
    final Map<String, dynamic> $params = <String, dynamic>{
      'status': status,
      'userName': userName,
      'from': from,
      'to': to,
      'page': page,
      'limit': limit,
      'orderIds': orderIds,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<SportsBookResponse, SportsBookResponse>($request);
  }

  @override
  Future<Response<SportBookPlResponse>> getCGSportsBookDetail(
    String? userName,
    String? from,
    String? to,
    int? page,
    int? limit,
  ) {
    final Uri $url =
        Uri.parse('https://rgc.dmxchge.com/api/Casino/sportHistoryDetail');
    final Map<String, dynamic> $params = <String, dynamic>{
      'userName': userName,
      'from': from,
      'to': to,
      'page': page,
      'limit': limit,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<SportBookPlResponse, SportBookPlResponse>($request);
  }

  @override
  Future<BetResponse> getCGSportsBookBetList(
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
  ) async {
    final Uri $url =
        Uri.parse('https://rgc.dmxchge.com/api/Casino/premiumsportBetList');
    final Map<String, dynamic> $params = <String, dynamic>{
      'status': status,
      'sport': sport,
      'orderIds': orderIds,
      'UserName': userName,
      'UserId': userId,
      'From': from,
      'TO': to,
      'Limit': limit,
      'Page': page,
      'EventIds': eventIds,
      'MarketIds': marketIds,
      'IP': ip,
      'ISP': isp,
      'OddDiff': oddDiff,
      'OddDiffGreater': oddDiffGreater,
      'Stake': stake,
      'column': column,
      'columnAsc': isAscending,
      'StakeGreater': stakeGreater,
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
  Future<Response<PremiumSportResponse>> getCGPremiumSport(
    String? sportName,
    String? userName,
  ) {
    final Uri $url =
        Uri.parse('https://rgc.dmxchge.com/api/Casino/premiumSportWiseReport');
    final Map<String, dynamic> $params = <String, dynamic>{
      'sportName': sportName,
      'userName': userName,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<PremiumSportResponse, PremiumSportResponse>($request);
  }

  @override
  Future<PremiumRunnerWiseReportResponse> getPremiumRunnerWiseReport(
    String marketId,
    String runnerName,
    String userName,
  ) async {
    final Uri $url =
        Uri.parse('https://rgc.dmxchge.com/api/Casino/premiumRunnerWiseReport');
    final Map<String, dynamic> $params = <String, dynamic>{
      'marketId': marketId,
      'runnerName': runnerName,
      'username': userName,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response $response = await client.send<
        PremiumRunnerWiseReportResponse,
        PremiumRunnerWiseReportResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<OrderEventResponse> getSportBookBetEventsList(
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
  ) async {
    final Uri $url = Uri.parse(
        'https://rgc.dmxchge.com/api/Casino/premiumsportBetEventsList');
    final Map<String, dynamic> $params = <String, dynamic>{
      'status': status,
      'sport': sport,
      'orderIds': orderIds,
      'UserName': userName,
      'UserId': userId,
      'From': from,
      'TO': to,
      'Limit': limit,
      'Page': page,
      'EventIds': eventIds,
      'MarketIds': marketIds,
      'IP': ip,
      'ISP': isp,
      'OddDiff': oddDiff,
      'OddDiffGreater': oddDiffGreater,
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
}
