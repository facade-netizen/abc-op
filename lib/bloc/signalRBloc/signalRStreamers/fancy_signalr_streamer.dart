import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/open_fancy_bets_model.dart';
import '../signalr_event_listener_bloc.dart';

class FancySignalRStreamerBloc extends Bloc<FancySignalRStreamerEvent, FancySignalRStreamerState> {
  final List<FancyRisk> fancyList = [];
  StreamSubscription<FancyRisk>? _subscription;
  FancySignalRStreamerBloc() : super(FancySignalRStreamerInitial()) {
    on<FancySignalRStreamerListener>(_onListen);
    on<_EmitFancyInternal>(_onEmitFancy);
    on<_EmitFancyErrorInternal>(_onEmitFancyError);
    on<SetToInitialSignalRFancy>(_onReset);
  }
  Future<void> _onListen(FancySignalRStreamerListener event, Emitter<FancySignalRStreamerState> emit) async {
    if (kDebugMode) debugPrint("FancySignalRStreamerListener started");
    await _subscription?.cancel();
    fancyList.clear();
    emit(FancySignalRStreamerProgress());
    _subscription = fancyMarketStream.listen(
      (line) {
        // if (kDebugMode) {
        //   for (var r in line.runners) {
        //     debugPrint(
        //       "fancy"
        //       "marketName:${line.marketName} "
        //       "Market:${line.marketId} "
        //       "Status:${line.status} "
        //       "sportingEvent:${line.sportingEvent} "
        //       "maxBet:${line.marketCondition?.maxBet ?? 0.0} "
        //       "minBet:${line.marketCondition?.minBet ?? 0.0} "
        //       "Back1:${r.backs.isNotEmpty ? r.backs.first.price : '-'} "
        //       "BackLine1:${r.backs.isNotEmpty ? r.backs.first.line : '-'} "
        //       "Lay1:${r.lays.isNotEmpty ? r.lays.first.price : '-'} "
        //       "LayLine1:${r.lays.isNotEmpty ? r.lays.first.line : '-'}",
        //     );
        //   }
        // }
        final index = fancyList.indexWhere((f) => f.marketId == line.marketId);
        bool changed = false;
        if (index != -1) {
          final old = fancyList[index];
          if (_hasChanged(old, line)) {
            fancyList[index] = line;
            changed = true;
          }
        } else {
          fancyList.insert(0, line);
          changed = true;
        }
        if (changed) {
          add(_EmitFancyInternal(List<FancyRisk>.from(fancyList)));
        }
      },
      onError: (e) {
        add(_EmitFancyErrorInternal(e));
      },
    );
  }

  void _onEmitFancy(_EmitFancyInternal event, Emitter<FancySignalRStreamerState> emit) {
    emit(FancySignalRStreamerSuccess(event.fancyData));
  }

  void _onEmitFancyError(_EmitFancyErrorInternal event, Emitter<FancySignalRStreamerState> emit) {
    emit(FancySignalRStreamerFailure(event.error));
  }

  Future<void> _onReset(SetToInitialSignalRFancy event, Emitter<FancySignalRStreamerState> emit) async {
    await _subscription?.cancel();
    _subscription = null;
    fancyList.clear();
    emit(FancySignalRStreamerInitial());
  }

  bool _hasChanged(FancyRisk old, FancyRisk updated) {
    // Check market condition changes (min/max)
    final oldMin = old.marketCondition?.minBet;
    final oldMax = old.marketCondition?.maxBet;
    final newMin = updated.marketCondition?.minBet;
    final newMax = updated.marketCondition?.maxBet;

    if (oldMin != newMin || oldMax != newMax) return true;

    // Check status and sportingEvent
    if (old.status != updated.status) return true;
    if (old.sportingEvent != updated.sportingEvent) return true;

    // Check runners length
    if (old.runners.length != updated.runners.length) return true;

    // Check runner details
    for (int i = 0; i < old.runners.length; i++) {
      final o = old.runners[i];
      final u = updated.runners[i];

      // Determine max indices to check (up to 3)
      final maxBackIndex = [o.backs.length, u.backs.length, 3].reduce((a, b) => a < b ? a : b);
      final maxLayIndex = [o.lays.length, u.lays.length, 3].reduce((a, b) => a < b ? a : b);

      // Check backs
      for (int j = 0; j < maxBackIndex; j++) {
        final oldBackPrice = o.backs[j].price;
        final oldBackLine = o.backs[j].line;
        final newBackPrice = u.backs[j].price;
        final newBackLine = u.backs[j].line;

        if (oldBackPrice != newBackPrice || oldBackLine != newBackLine) {
          return true;
        }
      }

      // Check lays
      for (int j = 0; j < maxLayIndex; j++) {
        final oldLayPrice = o.lays[j].price;
        final oldLayLine = o.lays[j].line;
        final newLayPrice = u.lays[j].price;
        final newLayLine = u.lays[j].line;

        if (oldLayPrice != newLayPrice || oldLayLine != newLayLine) {
          return true;
        }
      }
    }

    return false;
  }

  // ---------------- DISPOSE ----------------

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

//
// EVENTS
//

abstract class FancySignalRStreamerEvent {}

class FancySignalRStreamerListener extends FancySignalRStreamerEvent {}

class SetToInitialSignalRFancy extends FancySignalRStreamerEvent {}

class _EmitFancyInternal extends FancySignalRStreamerEvent {
  final List<FancyRisk> fancyData;
  _EmitFancyInternal(this.fancyData);
}

class _EmitFancyErrorInternal extends FancySignalRStreamerEvent {
  final dynamic error;
  _EmitFancyErrorInternal(this.error);
}

//
// STATES
//

abstract class FancySignalRStreamerState {}

class FancySignalRStreamerInitial extends FancySignalRStreamerState {}

class FancySignalRStreamerProgress extends FancySignalRStreamerState {}

class FancySignalRStreamerSuccess extends FancySignalRStreamerState {
  final List<FancyRisk> fancyCatalogues;
  FancySignalRStreamerSuccess(this.fancyCatalogues);
}

class FancySignalRStreamerFailure extends FancySignalRStreamerState {
  final dynamic error;
  FancySignalRStreamerFailure(this.error);
}
