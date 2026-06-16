import 'dart:async';
import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../apis/apiRepositories/settleManageRepo/ms_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../model/settle_history_model.dart';
import 'handle_error.dart';

class FetchSettleHistoryBloc extends Bloc<FetchSettleHistoryEvent, FetchSettleHistoryState> {
  final SettleApiRepository _settleApiRepository;

  Timer? _timer;
  String? fromDate;
  String? toDate;
  String? marketId;
  String? eventId;

  FetchSettleHistoryBloc(this._settleApiRepository) : super(FetchSettleHistoryInitial()) {
    /// Manual Refresh
    on<FetchSettleHistory>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchSettleHistory');
      fromDate = event.fromDate;
      toDate = event.toDate;
      marketId = event.marketId;
      eventId = event.eventId;

      emit(FetchSettleHistoryProgress());
      await _fetchData(emit);
    });

    /// Auto Refresh Timer Start
    on<StartAutoRefresh>((event, emit) {
      if (kDebugMode) debugPrint('Called StartAutoRefresh with ${event.seconds} seconds');
      marketId = event.marketId;
      eventId = event.eventId;

      _timer?.cancel();

      if (event.seconds == 0) return;

      _timer = Timer.periodic(Duration(seconds: event.seconds), (_) {
        add(AutoRefreshSettleHistory());
      });
    });

    /// Auto Refresh API Call (no loader)
    on<AutoRefreshSettleHistory>((event, emit) async {
      await _fetchData(emit, showLoader: false);
    });

    /// Stop Auto Refresh
    on<StopAutoRefresh>((event, emit) {
      if (kDebugMode) debugPrint('Called StopAutoRefresh');
      _timer?.cancel();
    });

    on<FetchSettleHistoryInt>((event, emit) {
      if (kDebugMode) debugPrint('Called FetchSettleHistoryInt');
      emit(FetchSettleHistoryInitial());
    });
  }

  Future<void> _fetchData(Emitter<FetchSettleHistoryState> emit, {bool showLoader = true}) async {
    //checking authentication
    SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

    try {
      if (savedTokenData != null) {
        final Response<SettleHistoryResponse> response = await _settleApiRepository.getSettleHistory(fromDate, toDate, marketId, eventId);

        if (response.statusCode == 200) {
          final settleHistory = response.body!.data;

          if (settleHistory.isNotEmpty) {
            emit(FetchSettleHistorySuccess(settleHistory: settleHistory, response: response.body!));
          } else if (response.body!.message.isNotEmpty && response.body!.message.toLowerCase() != 'success') {
            emit(FetchSettleHistoryFailure(response.body?.message ?? 'Unknown error'));
          } else {
            emit(FetchSettleHistoryFailure('No settlement history available for this market/event.'));
          }
        } else {
          if (kDebugMode) debugPrint("fetch_settle_history_bloc.dart [response error]>> ${response.statusCode}");
          emit(FetchSettleHistoryFailure(response.body?.message ?? 'Error: ${response.statusCode}'));
        }
      } else {
        emit(FetchSettleHistoryFailure('Your session has expired. Please log in again to proceed.'));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('fetch_settle_history_bloc.dart [Try Block Exception]>> \n $e');
      emit(FetchSettleHistoryFailure(handleError(e)));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

//// STATES
abstract class FetchSettleHistoryState {}

class FetchSettleHistoryInitial extends FetchSettleHistoryState {}

class FetchSettleHistoryProgress extends FetchSettleHistoryState {}

class FetchSettleHistorySuccess extends FetchSettleHistoryState {
  final List<SettleHistoryData> settleHistory;
  final SettleHistoryResponse response;

  FetchSettleHistorySuccess({
    required this.settleHistory,
    required this.response,
  });
}

class FetchSettleHistoryFailure extends FetchSettleHistoryState {
  final String error;
  FetchSettleHistoryFailure(this.error);
}

//// EVENTS
abstract class FetchSettleHistoryEvent {}

class FetchSettleHistory extends FetchSettleHistoryEvent {
  final String? marketId;
  final String? eventId;
  final String? fromDate;
  final String? toDate;
  FetchSettleHistory({
    this.marketId,
    this.eventId,
    this.fromDate,
    this.toDate,
  });
}

class FetchSettleHistoryInt extends FetchSettleHistoryEvent {}

/// Auto Refresh Events
class StartAutoRefresh extends FetchSettleHistoryEvent {
  final int seconds;
  final String? marketId;
  final String? eventId;
  StartAutoRefresh({required this.seconds, this.marketId, this.eventId});
}

class StopAutoRefresh extends FetchSettleHistoryEvent {}

class AutoRefreshSettleHistory extends FetchSettleHistoryEvent {}
