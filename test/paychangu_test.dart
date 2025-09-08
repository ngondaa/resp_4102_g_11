// Simple test file to verify PayChangu service initialization
import 'package:flutter_test/flutter_test.dart';
import '../lib/services/paychangu_service.dart';

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
