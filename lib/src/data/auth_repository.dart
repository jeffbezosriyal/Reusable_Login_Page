import '../domain/models.dart';

/// Backend contract. Any backend (Firebase, Mock, Custom API) must implement this.
abstract class AuthRepository {
  /// Request that an email OTP be sent to `email`.
  /// Returns true if the request was accepted (not necessarily delivered).
  Future<bool> requestEmailOtp(String email);

  /// Verify the OTP for the given email.
  /// On success returns AuthSuccess; on failure returns AuthFailure.
  Future<AuthResult> verifyEmailOtp(String email, String otp);

  /// Sign up (create) a user with email & password. Used if we choose to create user
  /// in the backend after OTP verification. Implementations can no-op and return success
  /// if they create user elsewhere.
  Future<AuthResult> signUpWithEmail(String email, String password);

  /// Sign in with email & password (traditional flow).
  Future<AuthResult> signInWithEmail(String email, String password);

  /// Sign in with an OAuth provider token (google/apple).
  /// `provider` is an identifier like "google" or "apple".
  Future<AuthResult> signInWithOAuthCredential(String provider, String token);

  /// Sign out current user.
  Future<void> signOut();
}
