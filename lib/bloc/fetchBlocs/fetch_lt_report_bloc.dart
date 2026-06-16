import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/life_time_report_model.dart';
import 'handle_error.dart';

class FetchLtReportBloc extends Bloc<FetchLtReportEvent, FetchLtReportState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchLtReportBloc(this._ordersApiRepository) : super(FetchLtReportInitial()) {
    on<FetchLtReport>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchLtReportBloc');
      emit(FetchLtReportProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final response = await _ordersApiRepository.getLifeTimeReportData(userName: event.userName);
          if (response.status == 200) {
            emit(FetchLtReportSuccess(ltReportData: response.data, createdTime: event.createdTime));
          } else {
            if (kDebugMode) debugPrint("fetch_lt_report_bloc.dart [response error]>> ${response.status}");
            emit(FetchLtReportFailure('fetch_lt_report_bloc.dart [response error]>> ${response.status}'));
          }
        } else {
          emit(FetchLtReportFailure('Your session has expired. Please log in again to proceed.'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_lt_report_bloc.dart [Try Block Exception]>> \n $e');
        emit(FetchLtReportFailure(handleError(e)));
      }
    });

    on<FetchLtReportInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchLtReportInt');
      emit(FetchLtReportInitial());
    });
  }
}

// states
abstract class FetchLtReportState {}

// events
abstract class FetchLtReportEvent {}

// states implementation
class FetchLtReportInitial extends FetchLtReportState {}

class FetchLtReportProgress extends FetchLtReportState {}

class FetchLtReportSuccess extends FetchLtReportState {
  FetchLtReportSuccess({required this.ltReportData, required this.createdTime});
  final List<LifeTimeReport> ltReportData;
  final String createdTime;
}

class FetchLtReportFailure extends FetchLtReportState {
  FetchLtReportFailure(this.error);
  final String error;
}

// events implementation
class FetchLtReport extends FetchLtReportEvent {
  FetchLtReport({required this.userName, required this.createdTime});
  final String userName;
  final String createdTime;
}

class FetchLtReportInt extends FetchLtReportEvent {}
