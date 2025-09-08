// Simple test file to verify PayChangu service initialization
import 'services/paychangu_service.dart';

void testPayChanguService() {
  print('Testing PayChangu Service...');
  
  try {
    final service = PayChanguService.instance;
    print('PayChangu service instance created: ${service.isInitialized}');
    
    if (service.isInitialized) {
      print('✅ PayChangu service initialized successfully');
      
      // Test payment URL generation
      final paymentUrl = service.generatePaymentUrl(
        merchantId: 'MRCH0002',
        amount: 100.0,
        firstName: 'Test',
        lastName: 'User',
        email: 'test@example.com',
      );
      
      print('✅ Payment URL generated: ${paymentUrl.substring(0, 50)}...');
    } else {
      print('❌ PayChangu service failed to initialize');
    }
  } catch (e) {
    print('❌ Error testing PayChangu service: $e');
  }
}
