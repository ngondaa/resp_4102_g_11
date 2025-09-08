// File: lib/config/paychangu_config.dart
import 'package:flutter/foundation.dart';

class AppPayChanguConfig {
  // Test Mode Configuration
  static const String testSecretKey = 'sec-test-d4JbRT2yzs7TnLPWrSy7kTjmuQnxpTJZ';
 
  // Production Mode Configuration  
  static const String productionSecretKey = 'your_production_secret_key_here';
 
  // Callback URLs - IMPORTANT: Replace with your actual domain
  static const String callbackUrl = 'https://your-domain.com/callback';
  static const String returnUrl = 'https://your-domain.com/return';
 
  // Default customer information
  static const String defaultFirstName = 'Albert';
  static const String defaultLastName = 'Ngonda';
  static const String defaultEmail = 'ngondaamn@gmail.com';
 
  // Currency configuration
  static const String currency = 'MWK'; // Malawian Kwacha (request format)
  static const String currencyResponse = 'MK'; // Response format from API
 
  // Environment detection - automatically uses test mode in debug builds
  static bool get isTestMode => kDebugMode;
 
  // Get the appropriate secret key based on environment
  static String get secretKey {
    return isTestMode ? testSecretKey : productionSecretKey;
  }

  // PayChangu payment base URLs
  static String get basePaymentUrl {
    return isTestMode 
        ? 'https://api.paychangu.com/direct-charge/payments/initialize' 
        : 'https://api.paychangu.com/direct-charge/payments/initialize';
  }

  // Webhook configuration (for backend integration)
  static const String webhookUrl = 'https://your-domain.com/webhook/paychangu';
}