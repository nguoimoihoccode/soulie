import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const String _definedBaseUrl = String.fromEnvironment(
    'SOULIE_API_BASE_URL',
  );

  static String get apiBaseUrl {
    if (_definedBaseUrl.isNotEmpty) {
      return _definedBaseUrl;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://localhost:3000';
  }

  static Uri apiUri(String path) {
    final normalizedBase = apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }
}
