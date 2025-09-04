import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get apiUrl {
    // Try to get from .env file first
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Fallback to hardcoded values
    if (kDebugMode) {
      return 'http://localhost:61676/api';
    }
    return 'https://api.ldetch.co.jp/api';
  }
  
  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => !kDebugMode;
  
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