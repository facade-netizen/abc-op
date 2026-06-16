import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/accountsRepo/account_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/agency_model.dart';
import 'handle_error.dart';

class FetchAgencyBloc extends Bloc<FetchAgencyEvent, FetchAgencyState> {
  final AccountApiRepository _accountApiRepository;
  FetchAgencyBloc(this._accountApiRepository) : super(FetchAgencyInitial()) {
    on<FetchAgency>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchAgencyBloc');
      emit(FetchAgencyProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final response = await _accountApiRepository.getAgency(body: event.body);
          if (response.status == 200 && response.message.toLowerCase() == "success" && response.data.isNotEmpty) {
            emit(FetchAgencySuccess(agency: response.data));
          } else {
            if (kDebugMode) debugPrint("fetch_agency_bloc.dart [response error]>> ${response.status}");
            emit(FetchAgencyFailure(response.message));
          }
        } else {
          emit(FetchAgencyFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_agency_bloc.dart.dart [Try Block Exception]>> \n $e');
        emit(FetchAgencyFailure(handleError(e)));
      }
    });
    on<FetchAgencyInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchAgencyInt');
      emit(FetchAgencyInitial());
    });
  }
}

// states
abstract class FetchAgencyState {}

// events
abstract class FetchAgencyEvent {}

// states implementation
class FetchAgencyInitial extends FetchAgencyState {}

class FetchAgencyProgress extends FetchAgencyState {}

class FetchAgencySuccess extends FetchAgencyState {
  FetchAgencySuccess({required this.agency});
  final List<AgencyModel> agency;
}

class FetchAgencyFailure extends FetchAgencyState {
  FetchAgencyFailure(this.error);
  final String error;
}

// events implementation
class FetchAgency extends FetchAgencyEvent {
  FetchAgency({required this.body});
  final Map<String, dynamic> body;
}

class FetchAgencyInt extends FetchAgencyEvent {}
