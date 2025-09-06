import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/consent_service.dart';
import '../../state/app_state.dart';
// import '../../models/models.dart';
import '../../widgets/consent_dialog.dart';

class OtpVerifyPage extends StatefulWidget {
  final String identifier;
  final bool isEmail;
  final String? debugCode;
  
  const OtpVerifyPage({
    super.key,
    required this.identifier,
    required this.isEmail,
    this.debugCode,
  });

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final _authService = AuthService();
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  bool _isLoading = false;
  String? _errorMessage;
  int _secondsRemaining = 300; // 5 minutes
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _startTimer();
    
    // Auto-fill code in development mode
    if (widget.debugCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (int i = 0; i < widget.debugCode!.length && i < 6; i++) {
          _controllers[i].text = widget.debugCode![i];
        }
      });
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }
  
  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  String get _otpCode {
    return _controllers.map((c) => c.text).join();
  }
  
  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Call the real backend API for OTP verification
      final result = await _authService.verifyOtp(
        email: widget.isEmail ? widget.identifier : null,
        phone: !widget.isEmail ? widget.identifier : null,
        code: _otpCode,
      );
      
      if (result.success) {
        // Token is already saved by AuthService.verifyOtp
      // Check if user has agreed to terms from database
      final consentRes = await ConsentService().getConsentStatus();
      final hasAgreedToTerms = consentRes.success && (consentRes.data?.hasAgreedToTerms ?? false);
      final hasAgreedToPrivacy = consentRes.success && (consentRes.data?.hasAgreedToPrivacyPolicy ?? false);
      final hasAgreedToDataProcessing = consentRes.success && (consentRes.data?.hasAgreedToDataProcessing ?? false);
        
        // If any consent is missing, show consent dialog
        if ((!hasAgreedToTerms || !hasAgreedToPrivacy || !hasAgreedToDataProcessing) && mounted) {
          // Show consent dialog for users who haven't consented
          final agreed = await showConsentDialog(context);
          if (!agreed) {
            // User did not agree to terms, don't proceed
            setState(() {
              _errorMessage = 'You must agree to the terms to continue';
            });
            return;
          }
        }
        
        // Update app state with user info and token
        if (!mounted) return;
        final appState = Provider.of<AppState>(context, listen: false);
        
        // Store user information
        if (result.user != null) {
          appState.currentUser = result.user;
          appState.isAuthenticated = true;
          await appState.setPlan(result.user!.plan);
          await appState.setModelTier(result.user!.modelTier);
        }
        
        // Navigate to main app
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Invalid or expired code';
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
  
  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final result = await _authService.sendOtp(
        email: widget.isEmail ? widget.identifier : null,
        phone: !widget.isEmail ? widget.identifier : null,
      );
      
      if (result.success) {
        setState(() {
          _secondsRemaining = 300;
        });
        _startTimer();
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New code sent successfully')),
        );
        
        // Clear existing code
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Failed to resend code';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _onDigitChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Auto-submit when all digits are entered
    if (_otpCode.length == 6) {
      _verifyOtp();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Code'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Icon(
                widget.isEmail ? Icons.email_outlined : Icons.phone_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Enter Verification Code',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Description
              Text(
                'We sent a 6-digit code to',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.identifier,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // OTP input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: theme.textTheme.headlineSmall,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorBorder: _errorMessage != null
                            ? OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.error,
                                ),
                              )
                            : null,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      onChanged: (value) => _onDigitChanged(value, index),
                      enabled: !_isLoading,
                    ),
                  );
                }),
              ),
              
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Timer
              Text(
                'Code expires in $_formattedTime',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _secondsRemaining < 60 
                      ? theme.colorScheme.error 
                      : theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Verify button
              FilledButton(
                onPressed: _isLoading ? null : _verifyOtp,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify'),
                ),
              ),
              const SizedBox(height: 16),
              
              // Resend button
              TextButton(
                onPressed: (_isLoading || _secondsRemaining > 240) 
                    ? null 
                    : _resendOtp,
                child: Text(
                  _secondsRemaining > 240 
                      ? 'Resend code in ${(_secondsRemaining - 240) ~/ 60}:${((_secondsRemaining - 240) % 60).toString().padLeft(2, '0')}'
                      : 'Resend Code',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
