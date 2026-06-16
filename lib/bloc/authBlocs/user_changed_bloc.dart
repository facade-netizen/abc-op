import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../apis/apiHandlers/api_constants.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class UserAuthChangesBloc extends Bloc<UserAuthChangesEvent, UserAuthChangesState> {
  UserAuthChangesBloc() : super(UserAuthChangesInitial()) {
    on<StartUserChangeListener>((event, emit) async {
      if (kDebugMode) debugPrint('Called UserAuthChangesBloc');
      emit(UserAuthChangesProgress());
      SaveLoginTokenModel? savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      if (savedData != null && savedData.token != null) {
        final uri = Uri.parse(AuthApiConstants.verifyToken).replace(queryParameters: {'accessToken': savedData.token});
        final verifyTokenRes = await http.get(uri);
        Map<String, dynamic> decodedData = {};
        if (verifyTokenRes.statusCode == 200) {
          decodedData = jsonDecode(verifyTokenRes.body);
        }
        if (decodedData.isEmpty) {
          emit(UserAuthChangesFailure());
          return;
        }
        final apiStatus = decodedData['status'];
        final apiUserId = decodedData['data']?['UserId'];
        final rawDate = savedData.validTill;
        final formatter = DateFormat("dd:MM:yyyy HH:mm:ss");
        DateTime? expiryFromString;
        try {
          if (rawDate != null) {
            expiryFromString = formatter.parse(rawDate);
          }
        } catch (_) {
          expiryFromString = null;
        }

        DateTime? expiryFromJwt;
        try {
          final parts = savedData.token!.split('.');
          if (parts.length == 3) {
            final payload = base64Url.normalize(parts[1]);
            final decoded = utf8.decode(base64Url.decode(payload));
            final data = jsonDecode(decoded) as Map<String, dynamic>;
            final expValue = data['exp'];
            final expSeconds = expValue is int ? expValue : int.tryParse(expValue?.toString() ?? '');
            if (expSeconds != null) {
              expiryFromJwt = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true).toLocal();
            }
          }
        } catch (_) {
          expiryFromJwt = null;
        }

        final expiryCandidates = [expiryFromString, expiryFromJwt].whereType<DateTime>().toList();
        if (expiryCandidates.isEmpty) {
          emit(UserAuthChangesFailure());
          return;
        }
        final expiry = expiryCandidates.reduce((a, b) => a.isAfter(b) ? a : b);

        log("Token expiry: $expiry");
        final now = DateTime.now();
        if (kDebugMode) {
          debugPrint(
            "[Token - ${savedData.token}] | "
            "[User Id - ${savedData.userId}] | "
            "[Role - ${savedData.role}]",
          );
        }
        final isNotExpired = now.isBefore(expiry);
        final isValidStatus = apiStatus == 200;
        final isSameUser = apiUserId == savedData.userId;
        if (isNotExpired && isValidStatus && isSameUser) {
          emit(UserAuthChangesSuccess(savedData: savedData));
        } else {
          emit(UserAuthChangesFailure());
        }
      } else {
        emit(UserAuthChangesFailure());
      }
    });
  }
}

//states
abstract class UserAuthChangesState {}

//events
abstract class UserAuthChangesEvent {}

//states implementation
class UserAuthChangesInitial extends UserAuthChangesState {}

class UserAuthChangesProgress extends UserAuthChangesState {}

class UserAuthChangesSuccess extends UserAuthChangesState {
  UserAuthChangesSuccess({required this.savedData});
  final SaveLoginTokenModel? savedData;
}

class UserAuthChangesFailure extends UserAuthChangesState {}

//events implementation
class StartUserChangeListener extends UserAuthChangesEvent {}
