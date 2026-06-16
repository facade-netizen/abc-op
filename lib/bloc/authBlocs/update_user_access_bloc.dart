import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/authRepo/auth_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class UpdateUserAccessBloc extends Bloc<UpdateUserAccessEvent, UpdateUserAccessState> {
  final AuthApiRepository _authApiRepository;

  UpdateUserAccessBloc(this._authApiRepository) : super(UpdateUserAccessInitial()) {
    on<UpdateUserAccess>((event, emit) async {
      emit(UpdateUserAccessProgress());
      if (kDebugMode) debugPrint("Called UpdateUserAccessBloc");

      SaveLoginTokenModel? savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      if (savedData != null) {
        try {
          final response = await _authApiRepository.updateUserAccess(body: event.map);
          if (response.statusCode == 200) {
            final decoded = jsonDecode(response.bodyString);
            if (decoded['status'] == 200) {
              final List<dynamic> dataList = decoded['data'] ?? [];

              List<UserAccessResult> results = [];
              for (var item in dataList) {
                final status = item is Map ? (item['status'] as int? ?? 0) : 0;
                final message = item is Map ? (item['message']?.toString() ?? '') : '';
                results.add(UserAccessResult(
                  status: status,
                  message: message,
                  isSuccess: status == 200,
                ));
              }

              final bool hasError = results.any((result) => !result.isSuccess);
              emit(UpdateUserAccessSuccess(
                message: hasError ? decoded['message'] ?? 'Partial error' : decoded['message'] ?? 'Success',
                results: results,
              ));
            } else {
              emit(UpdateUserAccessFailure('${decoded['message']}'));
            }
          } else {
            if (kDebugMode) debugPrint("UpdateUserAccessBloc None 200 [response error]>> ${response.statusCode}");
            emit(UpdateUserAccessFailure('UpdateUserAccessBloc None 200 [response error]>> ${response.statusCode}'));
          }
        } catch (e) {
          emit(UpdateUserAccessFailure(e.toString()));
          if (kDebugMode) debugPrint("UpdateUserAccessBloc [Catch Exception] >> Error: $e");
        }
      } else {
        emit(UpdateUserAccessFailure("User not logged in"));
      }
    });
  }
}

// Model for individual results
class UserAccessResult {
  final int status;
  final String message;
  final bool isSuccess;

  UserAccessResult({
    required this.status,
    required this.message,
    required this.isSuccess,
  });
}

// States
abstract class UpdateUserAccessState {}

// Events
abstract class UpdateUserAccessEvent {}

// States implementation
class UpdateUserAccessInitial extends UpdateUserAccessState {}

class UpdateUserAccessProgress extends UpdateUserAccessState {}

class UpdateUserAccessSuccess extends UpdateUserAccessState {
  final String? message;
  final List<UserAccessResult> results;

  UpdateUserAccessSuccess({
    this.message,
    this.results = const [],
  });
}

class UpdateUserAccessFailure extends UpdateUserAccessState {
  final String error;
  UpdateUserAccessFailure(this.error);
}

// Events implementation
class UpdateUserAccess extends UpdateUserAccessEvent {
  final List<Map<String, dynamic>> map;

  UpdateUserAccess({required this.map});
}
