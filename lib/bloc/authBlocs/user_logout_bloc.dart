import 'package:web/web.dart' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import 'user_changed_bloc.dart';
import 'user_login_bloc.dart';

class UserLogoutBloc extends Bloc<UserLogoutEvent, UserLogoutState> {
  UserLogoutBloc() : super(UserLogoutInitial()) {
    on<UserLogoutListener>((event, emit) async {
      if (kDebugMode) debugPrint('Called UserLogoutBloc');
      emit(UserLogoutProgress());
      SaveLoginTokenModel? savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      if (savedData != null && savedData.token != null && savedData.validTill != null) {
        await SaveTokenBox.loginTokenBox.clearLoginToken();
        if (kIsWeb) {
          html.window.localStorage.setItem('app_logout', DateTime.now().toIso8601String());
        }
        if (event.context.mounted) {
          event.context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
          event.context.read<UserLoginBloc>().add(SetLoginToInitial());
        }
        emit(UserLogoutSuccess());
      } else {
        emit(UserLogoutFailure());
      }
    });
  }
}

//states
abstract class UserLogoutState {}

//events
abstract class UserLogoutEvent {}

//states implementation
class UserLogoutInitial extends UserLogoutState {}

class UserLogoutProgress extends UserLogoutState {}

class UserLogoutSuccess extends UserLogoutState {}

class UserLogoutFailure extends UserLogoutState {}

//events implementation
class UserLogoutListener extends UserLogoutEvent {
  UserLogoutListener({required this.context});
  BuildContext context;
}
