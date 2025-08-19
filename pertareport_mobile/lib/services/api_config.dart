// services/api_config.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web / Chrome
      return "http://127.0.0.1:8000/report/api";
    } else if (Platform.isAndroid) {
      // Android Emulator
      return "http://10.0.2.2:8000/report/api";
    } else if (Platform.isIOS) {
      // iOS Simulator
      return "http://127.0.0.1:8000/report/api";
    } else {
      // fallback untuk desktop
      return "http://127.0.0.1:8000/report/api";
    }
  }
}
