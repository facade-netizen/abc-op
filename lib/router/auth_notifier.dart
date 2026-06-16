import 'dart:async';
import 'package:web/web.dart' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/authBlocs/user_changed_bloc.dart';
import '../bloc/authBlocs/user_logout_bloc.dart';

class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<UserAuthChangesState> _subscription;

  AuthNotifier(UserAuthChangesBloc bloc) {
    _subscription = bloc.stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class WebAuthSync extends StatefulWidget {
  const WebAuthSync({super.key, required this.child});
  final Widget child;

  @override
  State<WebAuthSync> createState() => _WebAuthSyncState();
}

class _WebAuthSyncState extends State<WebAuthSync> {
  static const Duration _idleTimeout = Duration(hours: 5);
  StreamSubscription<html.MouseEvent>? _mouseSubscription;
  StreamSubscription<html.KeyboardEvent>? _keyboardSubscription;
  StreamSubscription<html.TouchEvent>? _touchSubscription;
  StreamSubscription<html.Event>? _visibilitySubscription;
  Timer? _idleTimer;
  String? _lastLogoutSignalValue;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _lastLogoutSignalValue = html.window.localStorage.getItem('app_logout');
      _mouseSubscription = html.document.body?.onMouseDown.listen(_handleUserActivity);
      _keyboardSubscription = html.window.onKeyDown.listen(_handleUserActivity);
      _touchSubscription = html.document.body?.onTouchStart.listen(_handleUserActivity);
      _visibilitySubscription = html.document.onVisibilityChange.listen((_) {
        _checkLogoutSignal();
      });
      _resetIdleTimer();
    }
  }

  void _handleUserActivity(html.Event _) {
    _checkLogoutSignal();
    _resetIdleTimer();
    html.window.localStorage.setItem('app_last_activity', DateTime.now().toIso8601String());
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleTimeout, _handleIdleTimeout);
  }

  void _handleIdleTimeout() {
    if (!mounted) return;
    context.read<UserLogoutBloc>().add(UserLogoutListener(context: context));
  }

  void _checkLogoutSignal() {
    final currentLogoutSignal = html.window.localStorage.getItem('app_logout');
    if (currentLogoutSignal != null && currentLogoutSignal != _lastLogoutSignalValue) {
      _processLogoutSignal(currentLogoutSignal);
    }
  }

  void _processLogoutSignal(String? signalValue) {
    _lastLogoutSignalValue = signalValue;
    if (mounted) {
      context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
    }
  }

  @override
  void dispose() {
    _mouseSubscription?.cancel();
    _keyboardSubscription?.cancel();
    _touchSubscription?.cancel();
    _visibilitySubscription?.cancel();
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
