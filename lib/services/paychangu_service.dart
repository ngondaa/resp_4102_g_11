import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/paychangu_config.dart';

class PayChanguService {
  static PayChanguService? _instance;
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
    // Use the secret key from the configuration
    return AppPayChanguConfig.secretKey;
  }

  bool get isInitialized => _isInitialized;

  // Direct card charge API call
  Future<PayChanguChargeResponse> chargeCard({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
    required double amount,
    required String currency,
    String? email,
    String? chargeId,
    required String redirectUrl,
  }) async {
    if (!_isInitialized) {
      throw Exception('PayChangu service not initialized');
    }

    try {
      final url = Uri.parse('https://api.paychangu.com/charge-card/payments');
      
      // Convert amount to string as required by API
      final amountString = (amount * 100).round().toString(); // Convert to smallest unit
      
      final body = {
        'card_number': cardNumber,
        'expiry': expiry,
        'cvv': cvv,
        'cardholder_name': cardholderName,
        'amount': amountString,
        'currency': currency,
        'charge_id': chargeId ?? 'charge_${DateTime.now().millisecondsSinceEpoch}',
        'redirect_url': redirectUrl,
      };

      // Add email if provided
      if (email != null && email.isNotEmpty) {
        body['email'] = email;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_getSecretKey()}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PayChanguChargeResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('API Error: ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('PayChangu charge error: $e');
      }
      rethrow;
    }
  }

  // Initialize bank transfer payment
  Future<PayChanguBankTransferResponse> initializeBankTransfer({
    required double amount,
    required String chargeId,
    String? firstName,
    String? lastName,
    String? email,
    bool createPermanentAccount = false,
  }) async {
    if (!_isInitialized) {
      throw Exception('PayChangu service not initialized');
    }

    try {
      final url = Uri.parse('https://api.paychangu.com/direct-charge/payments/initialize');
      
      // Convert amount to string as required by API
      final amountString = (amount * 100).round().toString(); // Convert to smallest unit
      
      final body = {
        'amount': amountString,
        'currency': AppPayChanguConfig.currency,
        'payment_method': 'mobile_bank_transfer',
        'charge_id': chargeId,
        'create_permanent_account': createPermanentAccount,
      };

      // Add optional fields if provided
      if (firstName != null && firstName.isNotEmpty) {
        body['first_name'] = firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        body['last_name'] = lastName;
      }
      if (email != null && email.isNotEmpty) {
        body['email'] = email;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_getSecretKey()}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PayChanguBankTransferResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('API Error: ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('PayChangu bank transfer error: $e');
      }
      rethrow;
    }
  }

  // Verify card charge using charge_id
  Future<PayChanguVerificationResponse> verifyCharge(String chargeId) async {
    if (!_isInitialized) {
      throw Exception('PayChangu service not initialized');
    }

    try {
      final url = Uri.parse('https://api.paychangu.com/charge-card/verify/$chargeId');
      
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_getSecretKey()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PayChanguVerificationResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('API Error: ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('PayChangu verification error: $e');
      }
      rethrow;
    }
  }

  // Helper method to create charge request
  PayChanguChargeRequest createChargeRequest({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
    required double amount,
    String? email,
    String? chargeId,
  }) {
    return PayChanguChargeRequest(
      cardNumber: cardNumber,
      expiry: expiry,
      cvv: cvv,
      cardholderName: cardholderName,
      amount: amount,
      currency: AppPayChanguConfig.currency,
      email: email ?? AppPayChanguConfig.defaultEmail,
      chargeId: chargeId ?? 'charge_${DateTime.now().millisecondsSinceEpoch}',
      redirectUrl: AppPayChanguConfig.returnUrl,
    );
  }

  // Generate PayChangu payment URL for QR code (Bank Transfer)
  // Create a URL that redirects to PayChangu's payment interface
  String generatePaymentUrl({
    required String merchantId,
    required double amount,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
  }) {
    final chargeId = 'PTC${merchantId}_${DateTime.now().millisecondsSinceEpoch}';
    final amountInTambala = (amount * 100).round();
    
    // Create a URL that can be opened in PayChangu's payment interface
    // This will redirect users to complete the bank transfer payment
    final params = <String, String>{
      'amount': amountInTambala.toString(),
      'currency': AppPayChanguConfig.currency,
      'payment_method': 'mobile_bank_transfer',
      'charge_id': chargeId,
      'first_name': firstName ?? AppPayChanguConfig.defaultFirstName,
      'last_name': lastName ?? AppPayChanguConfig.defaultLastName,
      'email': email ?? AppPayChanguConfig.defaultEmail,
    };
    
    // Add phone number if provided
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      params['phone_number'] = phoneNumber;
    }
    
    // Use PayChangu's payment interface URL
    final uri = Uri.parse('https://paychangu.com/payment').replace(
      queryParameters: params,
    );
    
    return uri.toString();
  }

  // Alternative: Generate a JSON payload for the QR code that can be processed
  Map<String, dynamic> generatePaymentPayload({
    required String merchantId,
    required double amount,
    String? firstName,
    String? lastName,
    String? email,
    bool createPermanentAccount = false,
  }) {
    final chargeId = 'PTC${merchantId}_${DateTime.now().millisecondsSinceEpoch}';
    final amountInTambala = (amount * 100).round();
    
    return {
      'amount': amountInTambala.toString(),
      'currency': AppPayChanguConfig.currency,
      'payment_method': 'mobile_bank_transfer',
      'charge_id': chargeId,
      'first_name': firstName ?? AppPayChanguConfig.defaultFirstName,
      'last_name': lastName ?? AppPayChanguConfig.defaultLastName,
      'email': email ?? AppPayChanguConfig.defaultEmail,
      'create_permanent_account': createPermanentAccount,
    };
  }
}


// PayChangu API Response Models
class PayChanguChargeResponse {
  final bool success;
  final bool requires3dsAuth;
  final String? orderReference;
  final String? auth3dsLink;
  final String? message;

  PayChanguChargeResponse({
    required this.success,
    required this.requires3dsAuth,
    this.orderReference,
    this.auth3dsLink,
    this.message,
  });

  factory PayChanguChargeResponse.fromJson(Map<String, dynamic> json) {
    return PayChanguChargeResponse(
      success: json['success'] ?? false,
      requires3dsAuth: json['requires_3ds_auth'] ?? false,
      orderReference: json['orderReference'],
      auth3dsLink: json['3ds_auth_link'],
      message: json['message'],
    );
  }
}

class PayChanguBankTransferResponse {
  final String status;
  final String message;
  final PayChanguBankAccountDetails? paymentAccountDetails;
  final PayChanguTransactionDetails? transaction;

  PayChanguBankTransferResponse({
    required this.status,
    required this.message,
    this.paymentAccountDetails,
    this.transaction,
  });

  factory PayChanguBankTransferResponse.fromJson(Map<String, dynamic> json) {
    return PayChanguBankTransferResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      paymentAccountDetails: json['data']?['payment_account_details'] != null
          ? PayChanguBankAccountDetails.fromJson(json['data']['payment_account_details'])
          : null,
      transaction: json['data']?['transaction'] != null
          ? PayChanguTransactionDetails.fromJson(json['data']['transaction'])
          : null,
    );
  }
}

class PayChanguBankAccountDetails {
  final String bankName;
  final String accountNumber;
  final String accountName;
  final int accountExpirationTimestamp;

  PayChanguBankAccountDetails({
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.accountExpirationTimestamp,
  });

  factory PayChanguBankAccountDetails.fromJson(Map<String, dynamic> json) {
    return PayChanguBankAccountDetails(
      bankName: json['bank_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      accountName: json['account_name'] ?? '',
      accountExpirationTimestamp: json['account_expiration_timestamp'] ?? 0,
    );
  }
}

class PayChanguTransactionDetails {
  final String chargeId;
  final String refId;
  final String? transId;
  final String currency;
  final int amount;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String type;
  final String traceId;
  final String status;
  final String mobile;
  final int attempts;
  final String mode;
  final String createdAt;
  final String? completedAt;
  final String eventType;
  final PayChanguTransactionCharges? transactionCharges;
  final PayChanguAuthorization? authorization;

  PayChanguTransactionDetails({
    required this.chargeId,
    required this.refId,
    this.transId,
    required this.currency,
    required this.amount,
    this.firstName,
    this.lastName,
    this.email,
    required this.type,
    required this.traceId,
    required this.status,
    required this.mobile,
    required this.attempts,
    required this.mode,
    required this.createdAt,
    this.completedAt,
    required this.eventType,
    this.transactionCharges,
    this.authorization,
  });

  factory PayChanguTransactionDetails.fromJson(Map<String, dynamic> json) {
    return PayChanguTransactionDetails(
      chargeId: json['charge_id'] ?? '',
      refId: json['ref_id'] ?? '',
      transId: json['trans_id'],
      currency: json['currency'] ?? '',
      amount: json['amount'] ?? 0,
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      type: json['type'] ?? '',
      traceId: json['trace_id'] ?? '',
      status: json['status'] ?? '',
      mobile: json['mobile'] ?? '',
      attempts: json['attempts'] ?? 0,
      mode: json['mode'] ?? '',
      createdAt: json['created_at'] ?? '',
      completedAt: json['completed_at'],
      eventType: json['event_type'] ?? '',
      transactionCharges: json['transaction_charges'] != null
          ? PayChanguTransactionCharges.fromJson(json['transaction_charges'])
          : null,
      authorization: json['authorization'] != null
          ? PayChanguAuthorization.fromJson(json['authorization'])
          : null,
    );
  }
}

class PayChanguTransactionCharges {
  final String currency;
  final String amount;

  PayChanguTransactionCharges({
    required this.currency,
    required this.amount,
  });

  factory PayChanguTransactionCharges.fromJson(Map<String, dynamic> json) {
    return PayChanguTransactionCharges(
      currency: json['currency'] ?? '',
      amount: json['amount'] ?? '',
    );
  }
}

class PayChanguAuthorization {
  final String channel;
  final String? cardNumber;
  final String? expiry;
  final String? brand;
  final String? provider;
  final String? mobileNumber;
  final String? payerBank;
  final String? payerAccountNumber;
  final String? payerAccountName;
  final String? completedAt;

  PayChanguAuthorization({
    required this.channel,
    this.cardNumber,
    this.expiry,
    this.brand,
    this.provider,
    this.mobileNumber,
    this.payerBank,
    this.payerAccountNumber,
    this.payerAccountName,
    this.completedAt,
  });

  factory PayChanguAuthorization.fromJson(Map<String, dynamic> json) {
    return PayChanguAuthorization(
      channel: json['channel'] ?? '',
      cardNumber: json['card_number'],
      expiry: json['expiry'],
      brand: json['brand'],
      provider: json['provider'],
      mobileNumber: json['mobile_number'],
      payerBank: json['payer_bank'],
      payerAccountNumber: json['payer_account_number'],
      payerAccountName: json['payer_account_name'],
      completedAt: json['completed_at'],
    );
  }
}

class PayChanguVerificationResponse {
  final bool success;
  final String? status;
  final String? chargeId;
  final String? amount;
  final String? currency;
  final String? message;
  final Map<String, dynamic>? data;

  PayChanguVerificationResponse({
    required this.success,
    this.status,
    this.chargeId,
    this.amount,
    this.currency,
    this.message,
    this.data,
  });

  factory PayChanguVerificationResponse.fromJson(Map<String, dynamic> json) {
    return PayChanguVerificationResponse(
      success: json['success'] ?? false,
      status: json['status'],
      chargeId: json['charge_id'],
      amount: json['amount'],
      currency: json['currency'],
      message: json['message'],
      data: json['data'],
    );
  }
}

class PayChanguChargeRequest {
  final String cardNumber;
  final String expiry;
  final String cvv;
  final String cardholderName;
  final double amount;
  final String currency;
  final String email;
  final String chargeId;
  final String redirectUrl;

  PayChanguChargeRequest({
    required this.cardNumber,
    required this.expiry,
    required this.cvv,
    required this.cardholderName,
    required this.amount,
    required this.currency,
    required this.email,
    required this.chargeId,
    required this.redirectUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'card_number': cardNumber,
      'expiry': expiry,
      'cvv': cvv,
      'cardholder_name': cardholderName,
      'amount': (amount * 100).round().toString(),
      'currency': currency,
      'email': email,
      'charge_id': chargeId,
      'redirect_url': redirectUrl,
    };
  }
}

// Legacy model for backward compatibility
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