import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/authRepo/auth_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final AuthApiRepository _authApiRepository;
  ChangePasswordBloc(this._authApiRepository) : super(ChangePasswordInitial()) {
    on<ChangePassword>((event, emit) async {
      emit(ChangePasswordProgress());
      debugPrint(" Called ChangePasswordBloc");
      SaveLoginTokenModel? savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      if (savedData != null) {
        try {
          final response = await _authApiRepository.changeNewPassword(body: event.changePassword);
          final responseData = response.body;
          final status = responseData["status"];
          final data = responseData["data"];
          if (status == 200) {
            emit(ChangePasswordSuccess());
          } else {
            final errorMsg = data is String ? data : "Something went wrong";
            if (kDebugMode) debugPrint("Request failure >> $errorMsg");
            emit(ChangePasswordFailure(errorMsg));
          }
        } catch (e) {
          debugPrint("ChangePasswordBloc [Catch Exception] >>error: $e");
          emit(ChangePasswordFailure(e));
        }
      } else {
        emit(ChangePasswordFailure("User not logged in"));
      }
    });
  }
}

//states
abstract class ChangePasswordState {}

//events
abstract class ChangePasswordEvent {}

//states implementation
class ChangePasswordInitial extends ChangePasswordState {}

class ChangePasswordProgress extends ChangePasswordState {}

class ChangePasswordSuccess extends ChangePasswordState {}

class ChangePasswordFailure extends ChangePasswordState {
  final dynamic error;
  ChangePasswordFailure(this.error);
}

//events implementation
class ChangePassword extends ChangePasswordEvent {
  ChangePassword({required this.changePassword});
  final Map<String, dynamic> changePassword;
}
