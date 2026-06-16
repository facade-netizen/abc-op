import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiHandlers/api_constants.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  ResetPasswordBloc() : super(ResetPasswordInitial()) {
    on<ResetPassword>((event, emit) async {
      emit(ResetPasswordProgress());
      debugPrint(" Called ResetPasswordBloc");
      try {
        final response = await http.post(
          Uri.parse(AuthApiConstants.resetPassword),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(event.resetPassword),
        );
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final data = decoded["data"];
          if (decoded["status"] == 200) {
            final data = decoded["data"];
            emit(ResetPasswordSuccess(userName: data["username"], password: data["password"]));
          } else {
            final errorMsg = data is String ? data : "Something went wrong";
            if (kDebugMode) debugPrint("Request failure >> $errorMsg");
            emit(ResetPasswordFailure(errorMsg));
          }
        } else {
          emit(ResetPasswordFailure("${response.reasonPhrase}"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint("ResetPasswordBloc [Catch Exception] >>error: $e");
        emit(ResetPasswordFailure(e));
      }
    });
  }
}

//states
abstract class ResetPasswordState {}

//events
abstract class ResetPasswordEvent {}

//states implementation
class ResetPasswordInitial extends ResetPasswordState {}

class ResetPasswordProgress extends ResetPasswordState {}

class ResetPasswordSuccess extends ResetPasswordState {
  ResetPasswordSuccess({required this.userName, required this.password});
  final String userName;
  final String password;
}

class ResetPasswordFailure extends ResetPasswordState {
  final dynamic error;
  ResetPasswordFailure(this.error);
}

//events implementation
class ResetPassword extends ResetPasswordEvent {
  ResetPassword({required this.resetPassword});
  final Map<String, dynamic> resetPassword;
}
