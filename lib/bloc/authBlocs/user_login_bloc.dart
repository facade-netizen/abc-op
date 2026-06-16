import 'dart:convert';
import 'package:web/web.dart' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../apis/apiHandlers/api_constants.dart';
import '../../constants/app_constant.dart';
import '../../localDb/login/login_credentials_box.dart';
import '../../localDb/login/login_credentials_model.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class UserLoginBloc extends Bloc<UserLoginEvent, UserLoginState> {
  UserLoginBloc() : super(UserLoginInitial()) {
    on<UserLogin>((event, emit) async {
      emit(UserLoginProgress());
      try {
        // Format current time
        final now = DateTime.now();
        final formattedLoginTime = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(now);
        final response = await http.post(
          Uri.parse(AuthApiConstants.login),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "username": event.username,
            "password": event.password,
            "loginTime": formattedLoginTime,
            "isp": isp.value,
            "ip": ip.value,
            "agent": agent.value,
            "address": address.value,
          }),
        );
        final decoded = jsonDecode(response.body);
        if (kDebugMode) debugPrint("User Login Response >> $decoded");
        if (response.statusCode == 200) {
          if (decoded["status"] == 200) {
            final data = decoded['data'];
            if (data == null) {
              emit(UserLoginFailure(decoded['message'] ?? 'Login failed'));
              return;
            }
            if (data["changePassword"] == true) {
              emit(UserLoginResetPasswordRequiredSuccess(userName: event.username));
            } else {
              final role = data['role'];
              if (role == 'opManager') {
                SaveTokenBox.loginTokenBox.saveLoginToken = SaveLoginTokenModel(
                  token: data['token'],
                  refreshToken: data['refreshToken'],
                  validTill: data['validTill'],
                  savedAt: DateTime.now(),
                  userId: data['userId'],
                  userName: data['userName'],
                  role: role,
                );
                if (kIsWeb) {
                  html.window.localStorage.removeItem('app_logout');
                }
                LoginCredentialsBox.loginCredentialsBox.saveLoginCredentials = LoginCredentialsModel(
                  userId: event.username,
                  password: event.password,
                  savedAt: DateTime.now(),
                );
                emit(UserLoginSuccess());
              } else {
                emit(UserLoginFailure("Login failed! User can't allow to login"));
              }
            }
          } else {
            emit(UserLoginFailure("${decoded["message"]}"));
          }
        } else {
          emit(UserLoginFailure(decoded['message'] ?? 'Login failed'));
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint("User Login Exception >> $e");
        }
        emit(UserLoginFailure('Login failed!'));
      }
    });
    on<SetLoginToInitial>((event, emit) async {
      emit(UserLoginInitial());
    });
  }
}

//event
abstract class UserLoginEvent {}

//state
abstract class UserLoginState {}

//event impl
class UserLogin extends UserLoginEvent {
  final String username;
  final String password;
  UserLogin({required this.username, required this.password});
}

//states impl
class UserLoginInitial extends UserLoginState {}

class UserLoginProgress extends UserLoginState {}

class UserLoginSuccess extends UserLoginState {
  UserLoginSuccess();
}

class UserLoginResetPasswordRequiredSuccess extends UserLoginState {
  UserLoginResetPasswordRequiredSuccess({required this.userName});
  final String userName;
}

class UserLoginFailure extends UserLoginState {
  final String error;
  UserLoginFailure(this.error);
}

class SetLoginToInitial extends UserLoginEvent {}
