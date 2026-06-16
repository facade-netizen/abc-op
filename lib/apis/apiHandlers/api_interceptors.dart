import 'dart:async';

import 'package:chopper/chopper.dart';

import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class ApiResponseInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final response = await chain.proceed(chain.request);
    // if (!kDebugMode) {
    //   debugPrint(
    //     "[Received Response] >>\n[Status Code] ${response.statusCode}\n[FROM] ${response.base.request!.url}\n[METHOD] ${response.base.request!.method}\n[BODY STRING] : ${response.bodyString}",
    //   );
    // }
    if (response.toString() == "null") {
      // debugPrint("Null API Response");
      // debugPrint("[Received Response] >>\n[FROM] ${chain.request.baseUri.toString()}\n[METHOD] ${chain.request.method}");
    }

    return response;
  }
}

class ApiRequestInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final request = await chain.proceed(chain.request);
    // if (kDebugMode) {
    //   debugPrint("[Request sent to] >> ${chain.request.url} ");
    //   if (chain.request.method.contains(RegExp('POST|PUT|GET'))) {
    //     debugPrint("[Request body sent:] >>\n${request.body}");
    //   }
    //   if (chain.request.parameters.isNotEmpty) {
    //     debugPrint("[Request query params sent:] >>\n${chain.request.parameters}");
    //   }
    //   if (request.headers.isNotEmpty) {
    //     debugPrint("[Request headers sent:] >>\n${request.headers}");
    //   }
    // }
    if (request.statusCode != 200) {
      // if (kDebugMode) debugPrint('ApiRequestInterceptor ${request.statusCode}');
    }
    return request;
  }
}

class ApiAuthInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    SaveLoginTokenModel? savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
    final authToken = savedData!.token ?? '';
    Request request = applyHeader(chain.request, 'Authorization', 'Bearer $authToken', override: true);
    if (request.method == "Get" || request.method == "POST") {
      request = applyHeaders(request, {'Content-Type': 'application/json'});
    }
    final response = await chain.proceed(request);
    if (response.statusCode != 200) {
      // if (kDebugMode) debugPrint("Status Code ${response.statusCode}");
      // if (kDebugMode) debugPrint("Response ${response.bodyString}");
    }
    return response;
  }
}
