import 'package:supabase_flutter/supabase_flutter.dart';

class MerchantAuthService {
  final supabase = Supabase.instance.client;

  // allow merchants to sign in using email and password
  Future<bool> loginMerchant(String email, String password) async {
    // supabase auth function for sign-in
    final AuthResponse response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final User? user = response.user;

    return user != null;
  }

  // allow merchants to sign out
  Future<bool> logoutMerchant() async {
    // supabase auth function for sign-out
    await supabase.auth.signOut();

    return true;
  }

  // retrieve merchant profile information for the merchant currently signed in
  Future<Map<String, dynamic>?> getMerchantProfile() async {
    //supabase auth function to retrieve information for the current user
    final User? user = supabase.auth.currentUser;

    if (user != null) {
      final profile = await supabase
          .from('merchant_profiles')
          .select('*')
          .eq("id", user.id)
          .single();

      return profile;
    }
    return null;
  }
}