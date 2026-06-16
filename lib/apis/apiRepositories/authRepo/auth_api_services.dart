import 'package:chopper/chopper.dart';

import '../../apiHandlers/api_constants.dart';
import '../../apiHandlers/api_interceptors.dart';
import '../../apiHandlers/json_to_type_converter.dart';

part 'auth_api_services.chopper.dart';

final _authApiClient = ChopperClient(
  baseUrl: Uri.parse(AuthApiConstants.baseUrl),
  converter: JsonSerializableConverter({}),
  interceptors: [ApiAuthInterceptor(), ApiResponseInterceptor(), ApiRequestInterceptor()],
  errorConverter: const JsonConverter(),
);

@ChopperApi(baseUrl: AuthApiConstants.baseUrl)
abstract class AuthApiServices extends ChopperService {
  ///Don't modify
  static AuthApiServices create() {
    return _$AuthApiServices(_authApiClient);
  }

  @POST(path: AuthApiConstants.changePassword)
  Future<Response> changeNewPassword({@Body() required Map<String, dynamic> body});

  @POST(path: AuthApiConstants.updateUserAccess)
  Future<Response> updateUserAccess({@Body() required List<Map<String, dynamic>> body});
}
