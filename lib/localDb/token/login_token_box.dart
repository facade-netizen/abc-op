import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../constants/hive_strings.dart';
import 'login_token_model.dart';

class SaveTokenBox with HiveStrings {
  static const String hiveBoxKey = HiveStrings.hiveBoxKey;
  static const String loginTokenBoxKey = HiveStrings.credentialsBoxKey;
  late Box _loginTokenBox;
  SaveTokenBox._() {
    _loginTokenBox = Hive.box(hiveBoxKey);
  }
  static final SaveTokenBox _singleton = SaveTokenBox._();
  factory SaveTokenBox() => _singleton;

  ///for public use
  static SaveTokenBox get loginTokenBox => _singleton;

  ///save data to db
  set saveLoginToken(SaveLoginTokenModel value) {
    _loginTokenBox.put(loginTokenBoxKey, value).catchError(
      (error, stack) {
        if (kDebugMode) debugPrint("Hive Token saving error >>, $error  $stack");
      },
    );
  }

  ///fetch data from db
  SaveLoginTokenModel? get fetchLoginToken {
    late SaveLoginTokenModel? value;
    try {
      value = _loginTokenBox.get(loginTokenBoxKey);
      return value;
    } catch (e) {
      if (kDebugMode) debugPrint("Hive Token fetching error >> >>, $e");
      return value;
    }
  }

  Future<void> clearLoginToken() async {
    try {
      await _loginTokenBox.delete(loginTokenBoxKey);
    } catch (e) {
      if (kDebugMode) debugPrint("Hive Token clearing error >>, $e");
    }
  }
}
