import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../protoUsage/receive/receive.pb.dart';
import '../signalr_event_listener_bloc.dart';

class OddsSignalRStreamerBloc extends Bloc<OddsSignalRStreamerEvent, OddsSignalRStreamerState> {
  OddsSignalRStreamerBloc() : super(OddsSignalRStreamerInitial()) {
    on<OddsSignalRStreamerListener>((event, emit) async {
      if (kDebugMode) debugPrint("OddsSignalRStreamerListener started");
      emit(OddsSignalRStreamerProgress());
      try {
        await emit.forEach<ABCModel>(
          oddsStream,
          onData: (odds) {
            if (kDebugMode) {
              debugPrint("Odd Receive [ ${odds.eventId} | ${odds.runner.first.name} | ${odds.runner.last.name}| ${odds.runner.first.status} | ${odds.runner.last.status}]");
            }
            return OddsSignalRStreamerSuccess(odds);
          },
          onError: (error, stackTrace) {
            if (kDebugMode) debugPrint("ODDSData SignalR Error: $error");
            return OddsSignalRStreamerFailure(error);
          },
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Error in ODDSsSignalRBloc: $e');
        emit(OddsSignalRStreamerFailure(e));
      }
    });

    on<SetToInitialOddsSignalRStreamer>((event, emit) async {
      emit(OddsSignalRStreamerInitial());
    });
  }
}

//states
abstract class OddsSignalRStreamerState {}

//events
abstract class OddsSignalRStreamerEvent {}

//states implementation
class OddsSignalRStreamerInitial extends OddsSignalRStreamerState {}

class OddsSignalRStreamerProgress extends OddsSignalRStreamerState {}

class OddsSignalRStreamerSuccess extends OddsSignalRStreamerState {
  OddsSignalRStreamerSuccess(this.oddsData);
  ABCModel oddsData;
}

class OddsSignalRStreamerFailure extends OddsSignalRStreamerState {
  final dynamic error;
  OddsSignalRStreamerFailure(this.error);
}

//events implementation
class OddsSignalRStreamerListener extends OddsSignalRStreamerEvent {}

class SetToInitialOddsSignalRStreamer extends OddsSignalRStreamerEvent {}
