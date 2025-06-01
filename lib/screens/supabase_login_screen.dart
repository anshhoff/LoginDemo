import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pinput.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'dart:developer' as developer;

class SupabaseLoginScreen extends StatefulWidget {
  const SupabaseLoginScreen({super.key});

  @override
  State<SupabaseLoginScreen> createState() => _SupabaseLoginScreenState();
}

class _SupabaseLoginScreenState extends State<SupabaseLoginScreen> {
  final _authService = AuthService();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _phoneNumber;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
    developer.log('Login screen initialized', name: 'LoginScreen');
  }

  void _onPhoneChanged() {
    if (_errorMessage != null) {
      developer.log(
        'Clearing error message on phone change',
        name: 'LoginScreen',
      );
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) {
      developer.log(
        'Form validation failed',
        name: 'LoginScreen',
        error: 'Invalid form data',
      );
      return;
    }

    try {
      developer.log(
        'Attempting to send OTP',
        name: 'LoginScreen',
      );

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final phone = _phoneController.text;
      setState(() {
        _phoneNumber = phone;
      });

      await _authService.sendOTP(phone);

      setState(() {
        _isOtpSent = true;
        _isLoading = false;
      });
      
      developer.log(
        'OTP sent successfully',
        name: 'LoginScreen',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully!')),
        );
      }
    } catch (e) {
      developer.log(
        'Error sending OTP',
        name: 'LoginScreen',
        error: e.toString(),
        stackTrace: StackTrace.current,
      );
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      developer.log(
        'Invalid OTP length',
        name: 'LoginScreen',
        error: 'OTP length: ${_otpController.text.length}',
      );
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    try {
      developer.log(
        'Attempting to verify OTP',
        name: 'LoginScreen',
      );

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (_phoneNumber == null) {
        developer.log(
          'Phone number is null during verification',
          name: 'LoginScreen',
          error: 'Phone number not set',
        );
        return;
      }

      final response = await _authService.verifyOTP(_phoneNumber!, _otpController.text);

      developer.log(
        'OTP verified successfully',
        name: 'LoginScreen',
      );

      if (response.user != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      developer.log(
        'Error verifying OTP',
        name: 'LoginScreen',
        error: e.toString(),
        stackTrace: StackTrace.current,
      );
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _resendOTP() async {
    try {
      developer.log(
        'Attempting to resend OTP',
        name: 'LoginScreen',
      );

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (_phoneNumber == null) {
        developer.log(
          'Phone number is null during resend',
          name: 'LoginScreen',
          error: 'Phone number not set',
        );
        return;
      }

      await _authService.sendOTP(_phoneNumber!);

      setState(() {
        _isLoading = false;
      });

      developer.log(
        'OTP resent successfully',
        name: 'LoginScreen',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully!')),
        );
      }
    } catch (e) {
      developer.log(
        'Error resending OTP',
        name: 'LoginScreen',
        error: e.toString(),
        stackTrace: StackTrace.current,
      );
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Phone Login'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isOtpSent) ...[
                          IntlPhoneField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              border: const OutlineInputBorder(),
                              errorText: _errorMessage,
                            ),
                            initialCountryCode: 'IN',
                            onChanged: (phone) {
                              setState(() {
                                _errorMessage = null;
                              });
                            },
                            onCountryChanged: (country) {
                              setState(() {
                                _errorMessage = null;
                              });
                            },
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _sendOTP(),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _sendOTP,
                            child: const Text('Send OTP'),
                          ),
                        ] else ...[
                          Pinput(
                            controller: _otpController,
                            length: 6,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _verifyOTP(),
                            defaultPinTheme: PinTheme(
                              width: 56,
                              height: 56,
                              textStyle: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _verifyOTP,
                            child: const Text('Verify OTP'),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: _isLoading ? null : _resendOTP,
                            child: const Text('Resend OTP'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    developer.log(
      'Disposing login screen',
      name: 'LoginScreen',
    );
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
} 