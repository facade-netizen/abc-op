// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ms_api_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$SettleApiServices extends SettleApiServices {
  _$SettleApiServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = SettleApiServices;

  @override
  Future<Response<SettleHistoryResponse>> getSettleHistory(
    String? from,
    String? to,
    String? marketId,
    String? eventId,
  ) {
    final Uri $url =
        Uri.parse('https://abcmanager.dmxchge.com/getSettleHistory');
    final Map<String, dynamic> $params = <String, dynamic>{
      'from': from,
      'to': to,
      'marketId': marketId,
      'eventId': eventId,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<SettleHistoryResponse, SettleHistoryResponse>($request);
  }
}
