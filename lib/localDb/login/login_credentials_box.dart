import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../constants/hive_strings.dart';
import 'login_credentials_model.dart';

class LoginCredentialsBox with HiveStrings {
  static const String hiveBoxKey = HiveStrings.hiveBoxKey;
  static String loginCredentialsBoxKey = HiveStrings.loginsCredentialsBoxKey;
  late Box _loginCredentialsBox;
  LoginCredentialsBox._() {
    _loginCredentialsBox = Hive.box(hiveBoxKey);
  }
  static final LoginCredentialsBox _singleton = LoginCredentialsBox._();
  factory LoginCredentialsBox() => _singleton;

  ///for public use
  static LoginCredentialsBox get loginCredentialsBox => _singleton;

  ///save data to db
  set saveLoginCredentials(LoginCredentialsModel value) {
    _loginCredentialsBox.put(loginCredentialsBoxKey, value).catchError((error, stack) {
      if (kDebugMode) debugPrint("Hive Token saving error saveLoginCredentials >>, $error  $stack");
    });
  }

  ///fetch data from db
  LoginCredentialsModel? get fetchLoginCredentials {
    late LoginCredentialsModel? value;
    try {
      value = _loginCredentialsBox.get(loginCredentialsBoxKey);
      return value;
    } catch (e) {
      if (kDebugMode) debugPrint("Hive Token fetching error fetchLoginCredentials >> >>, $e");
      return value;
    }
  }
}
