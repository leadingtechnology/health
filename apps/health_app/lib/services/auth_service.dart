import 'dart:convert';
import 'api_service.dart';
import '../models/models.dart';

class AuthService {
  final ApiService _api = ApiService();
  
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  User? _currentUser;
  User? get currentUser => _currentUser;
  
  Future<AuthResult> sendOtp({String? email, String? phone}) async {
    if (email == null && phone == null) {
      return AuthResult(success: false, error: 'Email or phone is required');
    }
    
    try {
      final response = await _api.post('/auth/otp/send', {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'purpose': 'login',
      });
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthResult(
          success: true, 
          otpId: data['otpId'],
          identifier: data['identifier'],
          expiresAt: DateTime.parse(data['expiresAt']),
          // In dev mode, the code might be returned for testing
          debugCode: data['code'],
        );
      } else {
        String error = 'Failed to send OTP';
        try {
          final data = jsonDecode(response.body);
          error = data['message'] ?? data['error'] ?? error;
        } catch (_) {}
        return AuthResult(success: false, error: error);
      }
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }
  
  Future<AuthResult> verifyOtp({
    String? email, 
    String? phone, 
    required String code,
  }) async {
    if (email == null && phone == null) {
      return AuthResult(success: false, error: 'Email or phone is required');
    }
    
    try {
      final response = await _api.post('/auth/otp/verify', {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'code': code,
        'purpose': 'login',
      });
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['accessToken'];
        final expiresAt = DateTime.parse(data['expiresAt']);
        
        await _api.saveToken(token, expiresAt);
        
        _currentUser = User(
          email: data['email'],
          phone: data['phone'],
          name: data['name'] ?? '',
          plan: _parsePlan(data['plan']),
          modelTier: _parseModelTier(data['modelTier']),
        );
        
        return AuthResult(success: true, user: _currentUser);
      } else if (response.statusCode == 401) {
        return AuthResult(success: false, error: 'Invalid or expired OTP');
      } else {
        String error = 'Verification failed';
        try {
          final data = jsonDecode(response.body);
          error = data['message'] ?? data['error'] ?? error;
        } catch (_) {}
        return AuthResult(success: false, error: error);
      }
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }
  
  // Legacy password login
  Future<AuthResult> loginWithPassword({
    String? email,
    String? phone,
    required String password,
  }) async {
    if (email == null && phone == null) {
      return AuthResult(success: false, error: 'Email or phone is required');
    }
    
    try {
      final response = await _api.post('/auth/login', {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'password': password,
      });
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['accessToken'];
        final expiresAt = DateTime.parse(data['expiresAt']);
        
        await _api.saveToken(token, expiresAt);
        
        _currentUser = User(
          email: data['email'],
          phone: data['phone'],
          name: data['name'] ?? '',
          plan: _parsePlan(data['plan']),
          modelTier: _parseModelTier(data['modelTier']),
        );
        
        return AuthResult(success: true, user: _currentUser);
      } else {
        String error = 'Invalid credentials';
        try {
          final data = jsonDecode(response.body);
          error = data['message'] ?? data['error'] ?? error;
        } catch (_) {}
        return AuthResult(success: false, error: error);
      }
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }
  
  Future<AuthResult> register({
    String? email,
    String? phone,
    String? password,
    String name = '',
  }) async {
    if (email == null && phone == null) {
      return AuthResult(success: false, error: 'Email or phone is required');
    }
    
    try {
      final response = await _api.post('/auth/register', {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (password != null) 'password': password,
        'name': name,
      });
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['accessToken'];
        final expiresAt = DateTime.parse(data['expiresAt']);
        
        await _api.saveToken(token, expiresAt);
        
        _currentUser = User(
          email: data['email'],
          phone: data['phone'],
          name: data['name'] ?? '',
          plan: _parsePlan(data['plan']),
          modelTier: _parseModelTier(data['modelTier']),
        );
        
        return AuthResult(success: true, user: _currentUser);
      } else {
        String error = 'Registration failed';
        try {
          final data = jsonDecode(response.body);
          error = data['message'] ?? data['error'] ?? error;
        } catch (_) {}
        return AuthResult(success: false, error: error);
      }
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }
  
  Future<void> logout() async {
    await _api.clearToken();
    _currentUser = null;
  }
  
  Future<AuthResult> fetchCurrentUser() async {
    try {
      final response = await _api.get('/users/me');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = User(
          email: data['email'],
          phone: data['phone'],
          name: data['name'] ?? '',
          plan: _parsePlan(data['plan']),
          modelTier: _parseModelTier(data['modelTier']),
        );
        return AuthResult(success: true, user: _currentUser);
      } else {
        await logout();
        return AuthResult(success: false, error: 'Session expired');
      }
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }
  
  Plan _parsePlan(String? plan) {
    switch (plan?.toLowerCase()) {
      case 'standard':
        return Plan.standard;
      case 'pro':
        return Plan.pro;
      default:
        return Plan.free;
    }
  }
  
  ModelTier _parseModelTier(String? tier) {
    switch (tier?.toLowerCase()) {
      case 'enhanced':
        return ModelTier.enhanced;
      case 'realtime':
        return ModelTier.realtime;
      default:
        return ModelTier.basic;
    }
  }
}

class AuthResult {
  final bool success;
  final String? error;
  final User? user;
  final String? otpId;
  final String? identifier;
  final DateTime? expiresAt;
  final String? debugCode;
  
  AuthResult({
    required this.success,
    this.error,
    this.user,
    this.otpId,
    this.identifier,
    this.expiresAt,
    this.debugCode,
  });
}