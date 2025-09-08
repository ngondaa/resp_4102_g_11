# PayChangu Integration Setup Guide

This guide will help you set up PayChangu payment integration in your Flutter app.

## Files Created/Modified

### 1. PayChangu Service (`lib/services/paychangu_service.dart`)
- Singleton service for PayChangu operations
- Handles payment requests, verification, and validation
- Provides wrapper methods for common operations

### 2. Configuration File (`lib/config/paychangu_config.dart`)
- Contains all PayChangu configuration settings
- **IMPORTANT**: Update this file with your actual API keys

### 3. Updated Home Page (`lib/pages/home_page/home_page_widget.dart`)
- Added PayChangu payment button alongside QR generation
- Integrated payment flow with success/error handling
- Added payment validation and verification

### 4. Dependencies (`pubspec.yaml`)
- Added `paychangu_flutter: ^0.0.1` dependency

## Setup Instructions

### Step 1: Get PayChangu Credentials
1. Sign up at [https://paychangu.com](https://paychangu.com)
2. Go to your dashboard
3. Navigate to API Keys section
4. Copy your Secret Key (both test and production)

### Step 2: Configure API Keys
Edit `lib/config/paychangu_config.dart`:

```dart
class AppPayChanguConfig {
  // Replace with your actual test secret key
  static const String testSecretKey = 'your_actual_test_secret_key_here';
  
  // Replace with your actual production secret key
  static const String productionSecretKey = 'your_actual_production_secret_key_here';
  
  // Update with your actual domain
  static const String callbackUrl = 'https://your-actual-domain.com/callback';
  static const String returnUrl = 'https://your-actual-domain.com/return';
}
```

### Step 3: Update Customer Information (Optional)
You can customize the default customer information in the same config file:

```dart
static const String defaultFirstName = 'Customer';
static const String defaultLastName = 'Name';
static const String defaultEmail = 'customer@example.com';
```

### Step 4: Test the Integration
1. Run the app in debug mode (uses test environment)
2. Fill in Merchant ID and Transaction Amount
3. Click "Pay with PayChangu" button
4. Complete the test payment flow

### Step 5: Production Deployment
1. Update `productionSecretKey` with your live API key
2. Update callback and return URLs to your production domain
3. Build and deploy your app

## Features Implemented

### Payment Flow
- **Payment Request Creation**: Automatically generates transaction references
- **Payment Launch**: Opens PayChangu payment interface
- **Payment Verification**: Validates payment after completion
- **Success/Error Handling**: Shows appropriate dialogs for different outcomes

### QR Code Integration
- **PayChangu Payment URLs**: QR codes contain direct PayChangu payment links
- **Cross-Device Payments**: Any device can scan the QR and make payments
- **Automatic URL Generation**: Creates payment URLs with all necessary parameters
- **Timer-Based Expiry**: QR codes expire after 3 minutes for security

### UI Integration
- **Dual Payment Options**: Both QR code generation and direct PayChangu payment
- **Responsive Design**: Buttons adapt to screen size
- **Loading States**: Shows progress indicators during payment processing
- **Error Messages**: User-friendly error handling

### Security Features
- **Environment Detection**: Automatically switches between test/production
- **Payment Validation**: Verifies transaction details before confirmation
- **Secure Configuration**: Centralized configuration management

## Usage Example

```dart
// The service is already integrated in the home page
// Users can now:
// 1. Enter Merchant ID and Amount
// 2. Choose between "Generate Payment QR" or "Pay with PayChangu"
// 3. For QR: Display QR code that others can scan to pay
// 4. For Direct Payment: Complete payment through PayChangu interface
// 5. Receive confirmation of successful payment

// QR Code Flow:
// - Generates PayChangu payment URL with all parameters
// - Creates QR code containing the payment URL
// - Other devices can scan QR and be redirected to PayChangu payment page
// - Timer expires after 3 minutes for security
```

## Important Notes

### Security
- Never commit real API keys to version control
- Use environment variables for production keys
- Always validate payments on your backend
- Consider using a backend service for sensitive operations

### Testing
- Test thoroughly in test mode before going live
- Verify all payment scenarios (success, failure, cancellation)
- Test with different amounts and currencies

### Production Checklist
- [ ] Update production secret key
- [ ] Update callback and return URLs
- [ ] Test payment flow end-to-end
- [ ] Set up proper error monitoring
- [ ] Configure webhook endpoints (if needed)

## Support

For PayChangu-specific issues:
- Check [PayChangu Documentation](https://docs.paychangu.com)
- Contact PayChangu support

For integration issues:
- Review the service implementation in `lib/services/paychangu_service.dart`
- Check configuration in `lib/config/paychangu_config.dart`
- Verify all imports and dependencies are correct
