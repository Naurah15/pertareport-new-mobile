// services/api_config.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrlReport {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/report/api/";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8000/report/api/";
    } else if (Platform.isIOS) {
      return "http://127.0.0.1:8000/report/api/";
    } else {
      return "http://127.0.0.1:8000/report/api/";
    }
  }

  static String get baseUrlHistory {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/history/";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8000/history/";
    } else if (Platform.isIOS) {
      return "http://127.0.0.1:8000/history/";
    } else {
      return "http://127.0.0.1:8000/history/";
    }
  }
}

