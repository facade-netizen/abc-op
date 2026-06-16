import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiHandlers/api_constants.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class FetchAllWlBloc extends Bloc<FetchAllWlEvent, FetchAllWlState> {
  FetchAllWlBloc() : super(FetchAllWlInitial()) {
    on<FetchAllWl>((event, emit) async {
      emit(FetchAllWlProgress());
      debugPrint(" Called FetchAllWlBloc");
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          // ✅ Changed from POST to GET
          final response = await http.get(
            Uri.parse(WLApiConstants.getAll),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${savedTokenData.token}',
              'accept': 'text/plain',
            },
          );

          if (response.statusCode == 200) {
            final decoded = jsonDecode(response.body);
            if (decoded["status"] == 200) {
              final List<dynamic> data = decoded["data"];
              // Extract only appName from each object
              final List<String> wlNames = data.map((item) => (item["appName"] as String).toUpperCase()).toList();
              emit(FetchAllWlSuccess(wlList: wlNames.isEmpty ? ["No Site Found"] : wlNames));
            } else {
              final errorMsg = decoded["data"] is String ? decoded["data"] : "Something went wrong";
              if (kDebugMode) debugPrint("Request failure >> $errorMsg");
              emit(FetchAllWlFailure(errorMsg));
            }
          } else {
            emit(FetchAllWlFailure("${response.reasonPhrase}"));
          }
        } else {
          emit(FetchAllWlFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint("FetchAllWlBloc [Catch Exception] >>error: $e");
        emit(FetchAllWlFailure(e));
      }
    });
  }
}

//states
abstract class FetchAllWlState {}

//events
abstract class FetchAllWlEvent {}

//states implementation
class FetchAllWlInitial extends FetchAllWlState {}

class FetchAllWlProgress extends FetchAllWlState {}

class FetchAllWlSuccess extends FetchAllWlState {
  final List<String> wlList;
  FetchAllWlSuccess({required this.wlList});
}

class FetchAllWlFailure extends FetchAllWlState {
  final dynamic error;
  FetchAllWlFailure(this.error);
}

//events implementation
class FetchAllWl extends FetchAllWlEvent {}
