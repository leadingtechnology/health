import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get apiUrl {
    // 1) Prefer .env configuration
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      // Android emulator cannot reach host via "localhost"
      if (!kIsWeb && _isAndroid && envUrl.contains('localhost')) {
        return envUrl.replaceFirst('localhost', '10.0.2.2');
      }
      return envUrl;
    }

    // 2) Sensible development defaults
    if (kDebugMode) {
      // .NET dev ports from launchSettings.json: http 61676, https 61675
      // Use HTTP for simplicity to avoid self-signed cert issues.
      final localBase = _isAndroid ? 'http://10.0.2.2:61676/api' : 'http://localhost:61676/api';
      return localBase;
    }

    // 3) Production default
    return 'https://api.ldetch.co.jp/api';
  }

  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => !kDebugMode;

  static bool get _isAndroid => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || _platformIsAndroid);
  static bool get _platformIsAndroid {
    try {
      return Platform.isAndroid;
    } catch (_) {
      return false; // Not available on web
    }
  }

  // Database configuration (for reference)
  static const Map<String, dynamic> database = {
    'host': '35.187.209.229',
    'port': 5432,
    'database': 'postgres',
    'schema': 'health',
  };

  // JWT configuration
  static const Map<String, String> jwt = {
    'issuer': 'https://api.ldetch.co.jp',
    'audience': 'https://app.ldetch.co.jp',
  };

  // Domain configuration
  static const String primaryDomain = 'ldetch.co.jp';
  static const String apiDomain = 'api.ldetch.co.jp';
  static const String appDomain = 'app.ldetch.co.jp';
}
