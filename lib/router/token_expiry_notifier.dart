import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../bloc/authBlocs/user_logout_bloc.dart';
import '../localDb/token/login_token_box.dart';
import '../localDb/token/login_token_model.dart';

class TokenExpiryNotifier extends ChangeNotifier {
  DateTime? _expiryTime;
  Timer? _timer;

  DateTime? get expiryTime => _expiryTime;

  bool get isExpired => _expiryTime != null && DateTime.now().isAfter(_expiryTime!);

  Duration get timeRemaining => _expiryTime != null ? _expiryTime!.difference(DateTime.now()) : Duration.zero;

  DateTime? _parseExpiry(String validTillString) {
    try {
      final formatter = DateFormat("dd:MM:yyyy HH:mm:ss");
      return formatter.parse(validTillString);
    } catch (_) {
      return DateTime.tryParse(validTillString);
    }
  }

  DateTime? _parseExpiryFromJwt(String? token) {
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;

    try {
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final data = jsonDecode(decoded) as Map<String, dynamic>;
      final expValue = data['exp'];
      final expSeconds = expValue is int ? expValue : int.tryParse(expValue?.toString() ?? '');
      if (expSeconds == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Initialize from saved token
  void initFromStorage() {
    try {
      SaveLoginTokenModel? savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      if (savedData == null) {
        log("No token found");
        _timer?.cancel();
        _expiryTime = null;
        notifyListeners();
        return;
      }

      final rawDate = savedData.validTill;
      final expiryFromString = rawDate != null ? _parseExpiry(rawDate) : null;
      final expiryFromJwt = _parseExpiryFromJwt(savedData.token);
      final expiry = [expiryFromString, expiryFromJwt].where((element) => element != null).cast<DateTime>().fold<DateTime?>(null, (latest, value) {
        return latest == null || value.isAfter(latest) ? value : latest;
      });

      if (expiry == null) {
        log("Failed to parse token expiry from validTill and JWT");
        _timer?.cancel();
        _expiryTime = null;
        notifyListeners();
        return;
      }

      _expiryTime = expiry;
      log("Token expiry loaded: $_expiryTime");
      _scheduleExpiry();
      notifyListeners();
    } catch (e) {
      log("Error loading token expiry: $e");
    }
  }

  /// Update token time after login/refresh
  void updateValidTill(String validTillString) {
    try {
      final expiry = _parseExpiry(validTillString);
      if (expiry == null) {
        log("Invalid token expiry format: $validTillString");
        return;
      }

      _expiryTime = expiry;
      log("Token expiry updated: $_expiryTime");
      _scheduleExpiry();
      notifyListeners();
    } catch (e) {
      log("Error parsing expiry date: $e");
    }
  }

  void clearExpiry() {
    _timer?.cancel();
    _expiryTime = null;
    notifyListeners();
  }

  void _scheduleExpiry() {
    _timer?.cancel();

    if (_expiryTime == null) return;

    final timeUntilExpiry = _expiryTime!.difference(DateTime.now());
    log("Time remaining: $timeUntilExpiry");

    if (timeUntilExpiry.isNegative) {
      log("Token already expired");
      notifyListeners();
      return;
    }

    _timer = Timer(timeUntilExpiry, () {
      log("Token expired");
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

///
class TokenExpiryListener extends StatefulWidget {
  const TokenExpiryListener({super.key, required this.child});
  final Widget child;

  @override
  State<TokenExpiryListener> createState() => _TokenExpiryListenerState();
}

class _TokenExpiryListenerState extends State<TokenExpiryListener> {
  TokenExpiryNotifier? _notifier;
  bool _handled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newNotifier = context.read<TokenExpiryNotifier>();
    if (_notifier == newNotifier) return;
    _notifier?.removeListener(_onTokenChange);
    _notifier = newNotifier;
    _notifier!.addListener(_onTokenChange);
  }

  void _onTokenChange() {
    if (!mounted) return;

    final notifier = _notifier;
    if (notifier == null) return;

    if (!notifier.isExpired) {
      _handled = false;
      return;
    }

    if (_handled) return;
    _handled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserLogoutBloc>().add(UserLogoutListener(context: context));
    });
  }

  @override
  void dispose() {
    _notifier?.removeListener(_onTokenChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
