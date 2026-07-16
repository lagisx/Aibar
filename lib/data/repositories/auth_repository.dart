import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_constants.dart';
import '../../core/utils/network_retry.dart';
import '../services/supabase_service.dart';

class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Stream<AuthState> get authStateChanges =>
      SupabaseService.client.auth.onAuthStateChange;

  User? get currentUser => SupabaseService.currentUser;

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await withRetry(
      () =>
          SupabaseService.client.auth.signUp(email: email, password: password),
    );
    return response.session != null;
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await withRetry(
      () => SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw Exception('Google Sign-In: не удалось получить idToken');
    }

    await SupabaseService.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> resetPasswordForEmail(String email) async {
    await SupabaseService.client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await SupabaseService.client.auth.signOut();
  }

  Future<void> deleteAccount() async {
    final response = await SupabaseService.client.functions.invoke(
      AppConstants.deleteAccountFunction,
    );
    if (response.status != 200) {
      throw Exception('Не удалось удалить аккаунт: ${response.data}');
    }
    await _googleSignIn.signOut();
    await SupabaseService.client.auth.signOut(scope: SignOutScope.local);
  }
}
