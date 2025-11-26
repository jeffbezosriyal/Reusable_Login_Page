// lib/src/data/firebase_auth_repository.dart

import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../domain/models.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  FirebaseAuthRepository();

  // OAuth (Google / Apple) - token is provider ID token (Google ID token / Apple identity token)
  @override
  Future<AuthResult> signInWithOAuthCredential(String provider, String token) async {
    try {
      fb.AuthCredential credential;
      if (provider == 'google') {
        credential = fb.GoogleAuthProvider.credential(idToken: token);
      } else if (provider == 'apple') {
        credential = fb.OAuthProvider("apple.com").credential(idToken: token);
      } else {
        return AuthFailure('Unsupported provider: $provider');
      }

      final userCred = await _auth.signInWithCredential(credential);
      final u = userCred.user;
      if (u == null) return AuthFailure('Authentication failed (no user).');

      return AuthSuccess(uid: u.uid, email: u.email ?? '');
    } on fb.FirebaseAuthException catch (e) {
      return AuthFailure(_mapFirebaseAuthException(e));
    } catch (e) {
      return AuthFailure(e.toString());
    }
  }

  @override
  Future<bool> requestEmailOtp(String email) async {
    // We are using Firebase Auth email verification flow instead of custom OTP here.
    // For a true OTP-by-email, you need Cloud Functions to send codes.
    // This method currently triggers sending an email verification to an existing user.
    try {
      final current = _auth.currentUser;
      if (current != null && current.email == email) {
        await current.sendEmailVerification();
        return true;
      }
      // If user not signed in, optionally create a temporary user or return false.
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthResult> verifyEmailOtp(String email, String otp) async {
    // Firebase Auth doesn't support arbitrary numeric OTP verification via client.
    // This method should call your Cloud Function which verifies OTP and returns a custom token.
    return AuthFailure('verifyEmailOtp is not implemented. Use Cloud Functions for OTP.');
  }

  @override
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final u = userCred.user;
      if (u == null) return AuthFailure('Sign-in failed (no user).');
      return AuthSuccess(uid: u.uid, email: u.email ?? '');
    } on fb.FirebaseAuthException catch (e) {
      return AuthFailure(_mapFirebaseAuthException(e));
    } catch (e) {
      return AuthFailure(e.toString());
    }
  }

  @override
  Future<AuthResult> signUpWithEmail(String email, String password) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final u = userCred.user;
      if (u == null) return AuthFailure('Sign-up failed (no user).');
      // Optionally send email verification
      await u.sendEmailVerification();
      return AuthSuccess(uid: u.uid, email: u.email ?? '');
    } on fb.FirebaseAuthException catch (e) {
      return AuthFailure(_mapFirebaseAuthException(e));
    } catch (e) {
      return AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _mapFirebaseAuthException(fb.FirebaseAuthException e) {
    // Map common errors to friendlier messages.
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'account-exists-with-different-credential':
        return 'Account exists with different credentials.';
      case 'invalid-credential':
        return 'Invalid credentials provided.';
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'Authentication error: ${e.message ?? e.code}';
    }
  }
}
