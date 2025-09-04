import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import 'otp_verify_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEmail = true;
  String? _errorMessage;
  
  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }
  
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final identifier = _identifierController.text.trim();
      
      // Call the real backend API
      final result = await _authService.sendOtp(
        email: _isEmail ? identifier : null,
        phone: !_isEmail ? identifier : null,
      );
      
      if (result.success) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerifyPage(
              identifier: result.identifier ?? identifier,
              isEmail: _isEmail,
              debugCode: result.debugCode, // For testing in development
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Failed to send OTP';
        });
      }
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Cannot connect to server. Please check your connection.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  String? _validateIdentifier(String? value) {
    if (value == null || value.isEmpty) {
      return _isEmail ? 'Please enter your email' : 'Please enter your phone number';
    }
    
    if (_isEmail) {
      // Basic email validation
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    } else {
      // Basic phone validation (allows various formats)
      final digitsOnly = value.replaceAll(RegExp(r'[^\d+]'), '');
      if (digitsOnly.length < 10) {
        return 'Please enter a valid phone number';
      }
    }
    
    return null;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Icon
                  Icon(
                    Icons.health_and_safety,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    'Welcome to Health Assistant',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Sign in to continue',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Toggle between email and phone
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        icon: Icon(Icons.email_outlined),
                        label: Text('Email'),
                      ),
                      ButtonSegment(
                        value: false,
                        icon: Icon(Icons.phone_outlined),
                        label: Text('Phone'),
                      ),
                    ],
                    selected: {_isEmail},
                    onSelectionChanged: (Set<bool> selection) {
                      setState(() {
                        _isEmail = selection.first;
                        _identifierController.clear();
                        _errorMessage = null;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Input field
                  TextFormField(
                    controller: _identifierController,
                    keyboardType: _isEmail 
                        ? TextInputType.emailAddress 
                        : TextInputType.phone,
                    inputFormatters: _isEmail 
                        ? null 
                        : [FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\+\(\)]'))],
                    decoration: InputDecoration(
                      labelText: _isEmail ? 'Email Address' : 'Phone Number',
                      hintText: _isEmail 
                          ? 'user@example.com' 
                          : '+81 90 1234 5678',
                      prefixIcon: Icon(
                        _isEmail ? Icons.email_outlined : Icons.phone_outlined,
                      ),
                      border: const OutlineInputBorder(),
                      errorText: _errorMessage,
                    ),
                    validator: _validateIdentifier,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit button
                  FilledButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Send OTP Code'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Info text
                  Text(
                    _isEmail 
                        ? 'We\'ll send a verification code to your email'
                        : 'We\'ll send a verification code to your phone',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}