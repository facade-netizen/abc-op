import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

import '../../apis/apiHandlers/api_constants.dart';
import '../../constants/app_constant.dart';

class UserIPBloc extends Bloc<UserIPEvent, UserIPState> {
  UserIPBloc() : super(UserIPInitial()) {
    on<UserIP>((event, emit) async {
      emit(UserIPProgress());
      try {
        final responseIsp = await http.get(Uri.parse(AuthApiConstants.isp));
        final reposeIp = await http.get(Uri.parse(AuthApiConstants.ip));
        Map<String, dynamic> decodedIspData = {};
        if (responseIsp.statusCode == 200) {
          decodedIspData = jsonDecode(responseIsp.body);
        }
        Map<String, dynamic> decodedIPData = {};
        if (reposeIp.statusCode == 200) {
          decodedIPData = jsonDecode(reposeIp.body);
        }
        String getUserAgentType() {
          if (kIsWeb) {
            final ua = html.window.navigator.userAgent.toLowerCase();
            if (ua.contains("mobile") || ua.contains("android") || ua.contains("iphone")) {
              return "Browser (mobile)";
            } else {
              return "Browser (desktop)";
            }
          } else {
            if (Platform.isAndroid || Platform.isIOS) {
              return "App (mobile)";
            } else {
              return "App (desktop)";
            }
          }
        }

        ip = ValueNotifier(decodedIPData['ip']);
        isp = ValueNotifier(decodedIspData['org']);
        agent = ValueNotifier(getUserAgentType());
        address = ValueNotifier("${decodedIspData['city']}, ${decodedIspData['region']}, ${decodedIspData['country'].toString().toUpperCase()}");
        if (kDebugMode) debugPrint("user ip--${ip.value}");
        if (kDebugMode) debugPrint("user isp--${isp.value}");
        emit(UserIPSuccess());
      } catch (e) {
        debugPrint("User IP Error => $e");
        emit(UserIPFailure("User IP error"));
      }
    });
    on<SetLoginToInitial>((event, emit) async {
      emit(UserIPInitial());
    });
  }
}

//event
abstract class UserIPEvent {}

//state
abstract class UserIPState {}

//event impl
class UserIP extends UserIPEvent {}

//states impl
class UserIPInitial extends UserIPState {}

class UserIPProgress extends UserIPState {}

class UserIPSuccess extends UserIPState {}

class UserIPFailure extends UserIPState {
  final String error;
  UserIPFailure(this.error);
}

class SetLoginToInitial extends UserIPEvent {}
