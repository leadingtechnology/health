import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment.dart';

class ApiService {
  static String get _baseUrl => Environment.apiUrl;
  static const String _tokenKey = 'auth_token';
  static const String _tokenExpiryKey = 'token_expiry';
  
  String? _token;
  DateTime? _tokenExpiry;
  
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final expiryStr = prefs.getString(_tokenExpiryKey);
    if (expiryStr != null) {
      _tokenExpiry = DateTime.parse(expiryStr);
    }
  }
  
  bool get isAuthenticated {
    return _token != null && 
           _tokenExpiry != null && 
           _tokenExpiry!.isAfter(DateTime.now());
  }
  
  Future<void> saveToken(String token, DateTime expiry) async {
    _token = token;
    _tokenExpiry = expiry;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
  }
  
  Future<void> clearToken() async {
    _token = null;
    _tokenExpiry = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenExpiryKey);
  }
  
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }
  
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    return await http.get(url, headers: _headers);
  }
  
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    return await http.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );
  }
  
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    return await http.put(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );
  }
  
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    return await http.delete(url, headers: _headers);
  }
  
  Future<ApiResult<T>> handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = jsonDecode(response.body);
        return ApiResult.success(fromJson(data));
      } catch (e) {
        return ApiResult.error('Failed to parse response: $e');
      }
    } else if (response.statusCode == 401) {
      await clearToken();
      return ApiResult.error('Authentication required');
    } else {
      String message = 'Request failed';
      try {
        final error = jsonDecode(response.body);
        message = error['message'] ?? error['error'] ?? message;
      } catch (_) {}
      return ApiResult.error(message);
    }
  }
}

class ApiResult<T> {
  final bool success;
  final T? data;
  final String? error;
  
  ApiResult.success(this.data) : success = true, error = null;
  ApiResult.error(this.error) : success = false, data = null;
}