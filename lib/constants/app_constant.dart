import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appTitle = 'OP System';
  static const String appVersion = "0.0.1";
  static const String build = "46";
}

ValueNotifier<String> ip = ValueNotifier("Blocked");
ValueNotifier<String> isp = ValueNotifier("Blocked");
ValueNotifier<String> agent = ValueNotifier("Blocked");
ValueNotifier<String> address = ValueNotifier("Blocked");
