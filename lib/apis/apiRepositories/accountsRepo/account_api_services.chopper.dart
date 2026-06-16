// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_api_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$AccountApiServices extends AccountApiServices {
  _$AccountApiServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = AccountApiServices;

  @override
  Future<Response<UserResponse>> getUserDetails() {
    final Uri $url = Uri.parse('https://abcuser.dmxchge.com/api/Account');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<UserResponse, UserResponse>($request);
  }

  @override
  Future<ActivityLogsResponse> getUserActivityLogs(
      {required Map<String, dynamic> body}) async {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/Account/activityLog');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response =
        await client.send<ActivityLogsResponse, ActivityLogsResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<ActivityLogsResponse> getOrderActivityLogs(
      {required Map<String, dynamic> body}) async {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/Account/orderActivityLog');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response =
        await client.send<ActivityLogsResponse, ActivityLogsResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<AgencyResponse> getAgencyData(
      {required Map<String, dynamic> body}) async {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/Account/agencyOP');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response =
        await client.send<AgencyResponse, AgencyResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<UserLogResponse> getUserLog(
    int? logType,
    String? from,
    String? to,
    String? updater,
    String? username,
  ) async {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/Account/userLogs');
    final Map<String, dynamic> $params = <String, dynamic>{
      'logType': logType,
      'from': from,
      'to': to,
      'updater': updater,
      'username': username,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response $response =
        await client.send<UserLogResponse, UserLogResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<AccountStatementResponse> getUserAccountStatement(
      {required Map<String, dynamic> body}) async {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/Account/balancelog-op');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response = await client
        .send<AccountStatementResponse, AccountStatementResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<IspIpLogsResponse> getUserISPData(
      {required Map<String, dynamic> body}) async {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/Account/activityLog-ISP');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response =
        await client.send<IspIpLogsResponse, IspIpLogsResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<ChangePassLogsResponse> getUserChangePassLogs(
    String? userName,
    String? from,
    String? to,
    int? page,
    int? limit,
  ) async {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/changePasswordLogs');
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
    final Response $response = await client
        .send<ChangePassLogsResponse, ChangePassLogsResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<TransferredResponse> getUserTransferredLogs(
    String? userName,
    String? from,
    String? to,
    int? page,
    int? limit,
  ) async {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/casinoTransferLogs');
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
    final Response $response =
        await client.send<TransferredResponse, TransferredResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<CreditLimitResponse> getUserCreditLimitLogs(
    String? userName,
    String? from,
    String? to,
    int? page,
    int? limit,
  ) async {
    final Uri $url = Uri.parse('https://abcuser.dmxchge.com/api/creditLogs');
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
    final Response $response =
        await client.send<CreditLimitResponse, CreditLimitResponse>($request);
    return $response.bodyOrThrow;
  }
}
