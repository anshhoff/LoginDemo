import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Validate phone number format for Indian numbers
  bool isValidPhoneNumber(String phone) {
    // Remove any spaces and special characters except + and digits
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    print('=== Phone Validation Debug ===');
    print('Original phone: $phone');
    print('Cleaned phone: $cleanPhone');
    print('Length: ${cleanPhone.length}');
    print('===========================');

    // For Indian numbers, we expect either:
    // 1. 10 digits starting with 6-9 (e.g., 9179982488)
    // 2. +91 followed by 10 digits starting with 6-9 (e.g., +919179982488)
    final isValid = RegExp(r'^(\+91[6-9]\d{9}|[6-9]\d{9})$').hasMatch(cleanPhone);
    
    if (!isValid) {
      print('=== Validation Failed ===');
      print('Phone number must be either:');
      print('1. 10 digits starting with 6-9 (e.g., 9179982488)');
      print('2. +91 followed by 10 digits starting with 6-9 (e.g., +919179982488)');
      print('Current format: $cleanPhone');
      print('=======================');
    }
    
    return isValid;
  }

  // Format phone number to ensure proper Indian format
  String formatPhoneNumber(String phone) {
    // Remove any spaces and special characters except + and digits
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    print('=== Phone Formatting Debug ===');
    print('Original phone: $phone');
    print('Cleaned phone: $cleanPhone');
    print('Length: ${cleanPhone.length}');
    print('============================');

    String formattedPhone;
    
    // Handle different input formats
    if (cleanPhone.startsWith('+91') && cleanPhone.length == 13) {
      // Already in correct format (+91 + 10 digits)
      formattedPhone = cleanPhone;
      print('Already has correct +91 prefix');
    } else if (cleanPhone.length == 10 && RegExp(r'^[6-9]').hasMatch(cleanPhone)) {
      // 10-digit number starting with 6-9, simply add +91
      formattedPhone = '+91$cleanPhone';
      print('Added +91 prefix to 10-digit number');
    } else {
      // Invalid format
      print('Invalid phone number format - length: ${cleanPhone.length}');
      throw AuthException(
        'Invalid phone number format. Please enter a valid 10-digit Indian number (e.g., 9179982488)'
      );
    }

    print('Final formatted phone: $formattedPhone');
    
    // Double-check the final format
    if (!RegExp(r'^\+91[6-9]\d{9}$').hasMatch(formattedPhone)) {
      print('ERROR: Final formatted number is invalid: $formattedPhone');
      throw AuthException(
        'Phone number formatting failed. Please enter a valid 10-digit Indian number.'
      );
    }
    
    return formattedPhone;
  }

  // Send OTP
  Future<void> sendOTP(String phone) async {
    try {
      print('\n=== Attempting to send OTP ===');
      print('Input phone: $phone');

      // Format the phone number
      final formattedPhone = formatPhoneNumber(phone);
      
      // Validate the formatted number
      if (!isValidPhoneNumber(formattedPhone)) {
        print('\n=== Validation Error ===');
        print('Invalid phone number format: $formattedPhone');
        print('=======================');
        throw AuthException(
          'Invalid phone number format. Please enter a valid 10-digit Indian number (e.g., 9179982488)'
        );
      }

      print('\n=== Sending OTP to Supabase ===');
      print('Formatted phone: $formattedPhone');

      // Send OTP request to Supabase
      await _supabase.auth.signInWithOtp(
        phone: formattedPhone,
      );

      print('OTP sent successfully!');
      print('===========================');

    } on AuthException catch (e) {
      print('\n=== Supabase Auth Error ===');
      print('Error message: ${e.message}');
      print('Error details: ${e.toString()}');
      print('==========================');
      
      // Handle specific Twilio errors
      if (e.message?.contains('Invalid From Number') ?? false) {
        throw AuthException(
          'SMS service configuration error. Please contact support.'
        );
      }
      
      // Handle phone provider errors
      if (e.message?.contains('phone_provider_disabled') ?? false) {
        throw AuthException(
          'Phone authentication is not enabled. Please contact support.'
        );
      }
      
      rethrow; // Re-throw the original exception
    } catch (e, stackTrace) {
      print('\n=== Unexpected Error ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: $stackTrace');
      print('=======================');
      
      throw AuthException('An error occurred. Please try again.');
    }
  }

  // Verify OTP
  Future<AuthResponse> verifyOTP(String phone, String otp) async {
    try {
      print('\n=== Attempting to verify OTP ===');
      print('Phone: $phone');
      print('OTP: $otp');
      print('OTP length: ${otp.length}');

      // Format the phone number
      final formattedPhone = formatPhoneNumber(phone);
      
      // Validate the formatted number
      if (!isValidPhoneNumber(formattedPhone)) {
        print('\n=== Validation Error ===');
        print('Invalid phone number format: $formattedPhone');
        print('=======================');
        throw AuthException('Invalid phone number format.');
      }

      print('\n=== Verifying OTP with Supabase ===');
      print('Formatted phone: $formattedPhone');

      final response = await _supabase.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms,
      );

      print('OTP verified successfully!');
      print('User: ${response.user?.id}');
      print('============================');

      return response;
    } on AuthException catch (e) {
      print('\n=== Supabase Auth Error ===');
      print('Error message: ${e.message}');
      print('Error details: ${e.toString()}');
      print('==========================');
      
      if (e.message?.contains('Invalid token') ?? false) {
        throw AuthException('Invalid OTP. Please try again.');
      } else if (e.message?.contains('expired') ?? false) {
        throw AuthException('OTP has expired. Please request a new one.');
      }
      
      rethrow; // Re-throw the original exception
    } catch (e, stackTrace) {
      print('\n=== Unexpected Error ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: $stackTrace');
      print('=======================');
      
      throw AuthException('An error occurred. Please try again.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      developer.log(
        'Attempting to sign out user',
        name: 'AuthService',
      );
      await _supabase.auth.signOut();
      developer.log(
        'User signed out successfully',
        name: 'AuthService',
      );
    } catch (e) {
      developer.log(
        'Error signing out',
        name: 'AuthService',
        error: e.toString(),
        stackTrace: StackTrace.current,
      );
      throw AuthException('Error signing out. Please try again.');
    }
  }

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Stream of auth state changes
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;
}
