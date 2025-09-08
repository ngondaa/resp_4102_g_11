// Simple test file to verify PayChangu service initialization
import 'package:flutter_test/flutter_test.dart';
import 'services/paychangu_service.dart';

void main() {
  group('PayChangu Service Tests', () {
    test('PayChangu service initialization', () {
      print('Testing PayChangu Service...');
      
      try {
        final service = PayChanguService.instance;
        print('PayChangu service instance created: ${service.isInitialized}');
        
        if (service.isInitialized) {
          print('✅ PayChangu service initialized successfully');
          
          // Test charge request creation
          final chargeRequest = service.createChargeRequest(
            cardNumber: '4242424242424242',
            expiry: '12/30',
            cvv: '123',
            cardholderName: 'John Doe',
            amount: 100.0,
            email: 'test@example.com',
          );
          
          print('✅ Charge request created successfully');
          
          // Verify the request contains correct data
          expect(chargeRequest.cardNumber, '4242424242424242');
          expect(chargeRequest.expiry, '12/30');
          expect(chargeRequest.cvv, '123');
          expect(chargeRequest.cardholderName, 'John Doe');
          expect(chargeRequest.amount, 100.0);
          expect(chargeRequest.currency, 'MWK');
          expect(chargeRequest.email, 'test@example.com');
          
          // Test JSON conversion
          final json = chargeRequest.toJson();
          expect(json['card_number'], '4242424242424242');
          expect(json['amount'], '10000'); // 100.0 * 100 tambala
          expect(json['currency'], 'MWK');
          
          // Test payment URL generation for QR code
          final paymentUrl = service.generatePaymentUrl(
            merchantId: 'MRCH0002',
            amount: 100.0,
            firstName: 'Albert',
            lastName: 'Ngonda',
            email: 'ngondaamn@gmail.com',
          );
          
          print('✅ Payment URL generated: ${paymentUrl.substring(0, 50)}...');
          
          // Verify the URL contains the payment parameters
          expect(paymentUrl, contains('paychangu.com/payment'));
          expect(paymentUrl, contains('charge_id=PTCMRCH0002_'));
          expect(paymentUrl, contains('amount=10000')); // 100.0 * 100 tambala
          expect(paymentUrl, contains('currency=MWK'));
          expect(paymentUrl, contains('payment_method=mobile_bank_transfer'));
          
          // Test payment payload generation
          final paymentPayload = service.generatePaymentPayload(
            merchantId: 'MRCH0002',
            amount: 100.0,
            firstName: 'Albert',
            lastName: 'Ngonda',
            email: 'ngondaamn@gmail.com',
          );
          
          print('✅ Payment payload generated');
          expect(paymentPayload['amount'], '10000');
          expect(paymentPayload['currency'], 'MWK');
          expect(paymentPayload['payment_method'], 'mobile_bank_transfer');
          expect(paymentPayload['charge_id'], startsWith('PTCMRCH0002_'));
        } else {
          print('❌ PayChangu service failed to initialize');
          fail('PayChangu service failed to initialize');
        }
      } catch (e) {
        print('❌ Error testing PayChangu service: $e');
        fail('Error testing PayChangu service: $e');
      }
    });
  });
}
