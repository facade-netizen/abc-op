// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$AuthApiServices extends AuthApiServices {
  _$AuthApiServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = AuthApiServices;

  @override
  Future<Response<dynamic>> changeNewPassword(
      {required Map<String, dynamic> body}) {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/Auth/change-password');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateUserAccess(
      {required List<Map<String, dynamic>> body}) {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/Auth/updateUserAcccess-OP');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
