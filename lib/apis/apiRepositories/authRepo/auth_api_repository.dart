import 'package:chopper/chopper.dart';

import 'auth_api_services.dart';

class AuthApiRepository {
  AuthApiRepository() : _authApiServices = AuthApiServices.create();
  final AuthApiServices _authApiServices;

  Future<Response> changeNewPassword({required Map<String, dynamic> body}) async {
    return await _authApiServices.changeNewPassword(body: body);
  }

  Future<Response> updateUserAccess({required List<Map<String, dynamic>> body}) async {
    return await _authApiServices.updateUserAccess(body: body);
  }
}
