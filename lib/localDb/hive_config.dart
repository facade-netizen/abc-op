import 'package:hive/hive.dart';
import '../constants/hive_strings.dart';
import 'login/login_credentials_box.dart';
import 'login/login_credentials_model.dart';
import 'token/login_token_box.dart';
import 'token/login_token_model.dart';

class AppHiveConfig {
  AppHiveConfig._();

  static Future<void> init() async {
    Hive.registerAdapter(LoginCredentialsModelAdapter());
    Hive.registerAdapter(SaveLoginTokenModelAdapter());
    await Future.wait([Hive.openBox(HiveStrings.hiveBoxKey), Hive.openBox(SaveTokenBox.loginTokenBoxKey), Hive.openBox(LoginCredentialsBox.loginCredentialsBoxKey)]);
  }
}
