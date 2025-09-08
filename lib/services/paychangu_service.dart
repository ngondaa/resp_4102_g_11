import 'package:paychangu_flutter/paychangu_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PayChanguService {
  static PayChanguService? _instance;
  PayChangu? _paychangu;
  bool _isInitialized = false;

  PayChanguService._internal() {
    _initialize();
  }

  static PayChanguService get instance {
    _instance ??= PayChanguService._internal();
    return _instance!;
  }

  void _initialize() {
    try {
      final config = PayChanguConfig(
        secretKey: _getSecretKey(),
        isTestMode: kDebugMode, // Automatically use test mode in debug
      );
      _paychangu = PayChangu(config);
      _isInitialized = true;
      
      if (kDebugMode) {
        print('PayChangu service initialized successfully');
      }
    } catch (e) {
      _isInitialized = false;
      if (kDebugMode) {
        print('PayChangu service initialization failed: $e');
      }
    }
  }

  String _getSecretKey() {
    // In production, fetch this from secure storage or environment variables
    if (kDebugMode) {
      return 'sec-test-d4JbRT2yzs7TnLPWrSy7kTjmuQnxpTJZ'; // Your test key from config
    } else {
      return 'your_production_secret_key_here';
    }
  }

  PayChangu? get paychangu => _paychangu;
  bool get isInitialized => _isInitialized;

  // Wrapper methods for common operations
  Future<dynamic> verifyTransaction(String txRef) async {
    if (!_isInitialized || _paychangu == null) {
      throw Exception('PayChangu service not initialized');
    }
    try {
      return await _paychangu!.verifyTransaction(txRef);
    } catch (e) {
      if (kDebugMode) {
        print('PayChangu verification error: $e');
      }
      rethrow;
    }
  }

  bool validatePayment(
    dynamic verification, {
    required String expectedTxRef,
    required String expectedCurrency,
    required double expectedAmount,
  }) {
    if (!_isInitialized || _paychangu == null) {
      if (kDebugMode) {
        print('PayChangu service not initialized');
      }
      return false;
    }
    try {
      // Convert amount to smallest currency unit (tambala for MWK)
      final expectedAmountInTambala = (expectedAmount * 100).round();
      
      return _paychangu!.validatePayment(
        verification,
        expectedTxRef: expectedTxRef,
        expectedCurrency: expectedCurrency,
        expectedAmount: expectedAmountInTambala,
      );
    } catch (e) {
      if (kDebugMode) {
        print('PayChangu validation error: $e');
      }
      return false;
    }
  }

  Widget launchPayment({
    required PaymentRequest request,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
    required VoidCallback onCancel,
  }) {
    if (!_isInitialized || _paychangu == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('PayChangu service not available'),
          ],
        ),
      );
    }
    return _paychangu!.launchPayment(
      request: request,
      onSuccess: onSuccess,
      onError: onError,
      onCancel: onCancel,
    );
  }

  // Helper method to create payment request
  PaymentRequest createPaymentRequest({
    required String merchantId,
    required double amount,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    Map<String, dynamic>? customFields,
  }) {
    final txRef = 'tx-${merchantId}-${DateTime.now().millisecondsSinceEpoch}';
    // Convert amount to smallest currency unit (tambala for MWK)
    final amountInTambala = (amount * 100).round();
    
    return PaymentRequest(
      txRef: txRef,
      firstName: firstName ?? AppPayChanguConfig.defaultFirstName,
      lastName: lastName ?? AppPayChanguConfig.defaultLastName,
      email: email ?? AppPayChanguConfig.defaultEmail,
      currency: Currency.MWK,
      amount: amountInTambala, // PayChangu expects amount in smallest unit
      callbackUrl: AppPayChanguConfig.callbackUrl,
      returnUrl: AppPayChanguConfig.returnUrl,
    );
  }

  // Generate PayChangu payment URL for QR code
  String generatePaymentUrl({
    required String merchantId,
    required double amount,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
  }) {
    final txRef = 'tx-${merchantId}-${DateTime.now().millisecondsSinceEpoch}';
    final amountInTambala = (amount * 100).round();
    
    // Build PayChangu payment URL with parameters
    final params = <String, String>{
      'tx_ref': txRef,
      'amount': amountInTambala.toString(),
      'currency': AppPayChanguConfig.currency,
      'first_name': firstName ?? AppPayChanguConfig.defaultFirstName,
      'last_name': lastName ?? AppPayChanguConfig.defaultLastName,
      'email': email ?? AppPayChanguConfig.defaultEmail,
      'callback_url': AppPayChanguConfig.callbackUrl,
      'return_url': AppPayChanguConfig.returnUrl,
    };
    
    // Add phone number if provided
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      params['phone_number'] = phoneNumber;
    }
    
    // Build query string
    final uri = Uri.parse(AppPayChanguConfig.basePaymentUrl).replace(
      queryParameters: params,
    );
    
    return uri.toString();
  }
}

// Configuration class (should be in separate file: lib/config/paychangu_config.dart)
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
  static const String currency = 'MWK'; // Malawian Kwacha
 
  // Environment detection - automatically uses test mode in debug builds
  static bool get isTestMode => kDebugMode;
 
  // Get the appropriate secret key based on environment
  static String get secretKey {
    return isTestMode ? testSecretKey : productionSecretKey;
  }
  
  // PayChangu payment base URLs
  static String get basePaymentUrl {
    return isTestMode
        ? 'https://api.paychangu.com/test/payment'
        : 'https://api.paychangu.com/payment';
  }
  
  // Webhook configuration (for backend integration)
  static const String webhookUrl = 'https://your-domain.com/webhook/paychangu';
}

// Model for payment result
class PaymentResult {
  final bool isSuccess;
  final String? transactionId;
  final double? amount;
  final String? currency;
  final String? status;
  final String? message;
  final DateTime timestamp;

  PaymentResult({
    required this.isSuccess,
    this.transactionId,
    this.amount,
    this.currency,
    this.status,
    this.message,
    required this.timestamp,
  });

  factory PaymentResult.success({
    required String transactionId,
    required double amount,
    required String currency,
    required String status,
  }) {
    return PaymentResult(
      isSuccess: true,
      transactionId: transactionId,
      amount: amount,
      currency: currency,
      status: status,
      timestamp: DateTime.now(),
    );
  }

  factory PaymentResult.failure(String message) {
    return PaymentResult(
      isSuccess: false,
      message: message,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSuccess': isSuccess,
      'transactionId': transactionId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}