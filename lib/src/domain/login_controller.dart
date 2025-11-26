import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../data/auth_repository.dart';
import 'models.dart';

/// The public state exposed to UI.
/// Keep fields minimal — UI should render based on these only.
class LoginState {
  final bool loading;
  final String? error; // last visible error message
  final bool otpRequested; // whether OTP was requested (show OTP input)
  final bool authenticated; // whether auth succeeded
  final int otpAttempts; // attempts used for the current OTP (informational)
  final bool isOAuthFlow; // whether currently in an OAuth attempt

  const LoginState({
    this.loading = false,
    this.error,
    this.otpRequested = false,
    this.authenticated = false,
    this.otpAttempts = 0,
    this.isOAuthFlow = false,
  });

  LoginState copyWith({
    bool? loading,
    String? error,
    bool? otpRequested,
    bool? authenticated,
    int? otpAttempts,
    bool? isOAuthFlow,
  }) {
    return LoginState(
      loading: loading ?? this.loading,
      error: error,
      otpRequested: otpRequested ?? this.otpRequested,
      authenticated: authenticated ?? this.authenticated,
      otpAttempts: otpAttempts ?? this.otpAttempts,
      isOAuthFlow: isOAuthFlow ?? this.isOAuthFlow,
    );
  }
}

/// Controller contains all domain logic: validation, flow orchestration, mapping errors.
/// It exposes a ValueNotifier[LoginState] so UI can bind with ValueListenableBuilder.
class LoginController {
  final AuthRepository repo;

  // Public state notifier
  final ValueNotifier<LoginState> state = ValueNotifier(const LoginState());

  // Optional internal timers/cancellations
  Timer? _otpCooldownTimer;

  // Keep a single GoogleSignIn instance for the controller
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email'],
    forceCodeForRefreshToken: true,
  );

  LoginController({required this.repo});

  void dispose() {
    _otpCooldownTimer?.cancel();
    state.dispose();
  }

  // Helper setters
  void _setLoading(bool v) => state.value = state.value.copyWith(loading: v, error: null);
  void _setError(String message) => state.value = state.value.copyWith(loading: false, error: message);
  void _setAuthenticated() => state.value = state.value.copyWith(loading: false, authenticated: true, error: null);
  void _setOtpRequested() => state.value = state.value.copyWith(loading: false, otpRequested: true, otpAttempts: 0, error: null);

  // Presentation-level validation helpers. These are intentionally simple.
  bool _isValidEmail(String email) {
    final e = email.trim();
    return e.isNotEmpty && RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(e);
  }

  bool _isValidPassword(String pwd) {
    return pwd.length >= 6; // domain rule: minimum 6 chars
  }

  /// Step A: request an OTP for the given email.
  Future<void> requestOtp(String email) async {
    if (!_isValidEmail(email)) {
      _setError('Enter a valid email.');
      return;
    }

    _setLoading(true);
    try {
      final ok = await repo.requestEmailOtp(email.trim().toLowerCase());
      if (ok) {
        _setOtpRequested();
      } else {
        _setError('Could not send OTP. Try again later.');
      }
    } catch (e) {
      _setError(_mapExceptionToMessage(e));
    }
  }

  /// Step B: verify the previously requested OTP.
  Future<void> verifyOtp(String email, String otp) async {
    if (otp.trim().isEmpty) {
      _setError('Enter OTP.');
      return;
    }

    _setLoading(true);
    try {
      final res = await repo.verifyEmailOtp(email.trim().toLowerCase(), otp.trim());
      if (res is AuthSuccess) {
        _setAuthenticated();
      } else if (res is AuthFailure) {
        // increment attempt counter visible to UI
        final attempts = (state.value.otpAttempts) + 1;
        state.value = state.value.copyWith(loading: false, otpAttempts: attempts, error: res.message);
        // if too many attempts, trigger a short cooldown (domain rule)
        if (attempts >= 3) {
          _startOtpCooldown();
        }
      } else {
        _setError('Unknown response from auth backend.');
      }
    } catch (e) {
      _setError(_mapExceptionToMessage(e));
    }
  }

  /// Traditional email/password sign-in (without OTP flow)
  Future<void> signInWithEmail(String email, String password) async {
    if (!_isValidEmail(email)) {
      _setError('Enter a valid email.');
      return;
    }
    if (!_isValidPassword(password)) {
      _setError('Password must be at least 6 characters.');
      return;
    }

    _setLoading(true);
    try {
      final res = await repo.signInWithEmail(email.trim().toLowerCase(), password);
      if (res is AuthSuccess) {
        _setAuthenticated();
      } else if (res is AuthFailure) {
        _setError(res.message);
      } else {
        _setError('Unknown response from auth backend.');
      }
    } catch (e) {
      _setError(_mapExceptionToMessage(e));
    }
  }

  /// OAuth flow: provider = "google" | "apple", token = provider token/credential
  Future<void> signInWithOAuth(String provider, String token) async {
    if (provider.isEmpty || token.isEmpty) {
      _setError('Invalid OAuth parameters.');
      return;
    }

    state.value = state.value.copyWith(isOAuthFlow: true, loading: true, error: null);
    try {
      final res = await repo.signInWithOAuthCredential(provider, token);
      if (res is AuthSuccess) {
        _setAuthenticated();
      } else if (res is AuthFailure) {
        _setError(res.message);
      } else {
        _setError('Unknown response from auth backend.');
      }
    } catch (e) {
      _setError(_mapExceptionToMessage(e));
    } finally {
      state.value = state.value.copyWith(isOAuthFlow: false, loading: false);
    }
  }

  /// Google Sign-In helper that ensures the account chooser is shown.
  ///
  /// This method signs out/disconnects any existing cached Google account for the app
  /// so the account selection popup appears every time. It then obtains the idToken
  /// (or accessToken if needed) and calls the backend via signInWithOAuth.
  Future<void> signInWithGoogle() async {
    // Guard: don't start multiple concurrent OAuth flows
    if (state.value.isOAuthFlow || state.value.loading) return;

    state.value = state.value.copyWith(isOAuthFlow: true, loading: true, error: null);

    try {
      // Force Google to show account chooser by clearing existing sign-in state.
      // This only affects this app's GoogleSignIn session, not the device account.
      try {
        // Best-effort: signOut + disconnect. Some platforms may throw; swallow non-fatal errors.
        await googleSignIn.signOut();
        await googleSignIn.disconnect();
      } catch (_) {
        // ignore signOut/disconnect errors; continue to attempt signIn
      }

      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        // user dismissed account chooser
        state.value = state.value.copyWith(isOAuthFlow: false, loading: false);
        _setError('Google sign-in cancelled.');
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      // Choose the best token available for your backend. Prefer idToken for Firebase-like backends.
      final token = auth.idToken ?? auth.accessToken;
      if (token == null || token.isEmpty) {
        _setError('Failed to obtain Google credential.');
        return;
      }

      // Reuse existing generic OAuth flow to contact backend
      await signInWithOAuth('google', token);
    } catch (e) {
      // Map known google sign-in errors to friendlier messages where possible.
      final s = e.toString();
      if (s.contains('ApiException: 10') || s.contains('DEVELOPER_ERROR')) {
        _setError('Google Sign-In configuration error (check SHA & OAuth client).');
      } else {
        _setError(_mapExceptionToMessage(e));
      }
    } finally {
      // ensure isOAuthFlow false if not authenticated
      if (!state.value.authenticated) {
        state.value = state.value.copyWith(isOAuthFlow: false, loading: false);
      }
    }
  }

  /// Sign out
  Future<void> signOut() async {
    // Attempt to sign out from Google (best-effort) then backend signOut
    try {
      await googleSignIn.signOut();     // clears local session
      await googleSignIn.disconnect();  // clears cached Google account on device
    } catch (_) {
      // ignore
    }

    await repo.signOut();
    state.value = const LoginState();
  }

  // Private helpers
  void _startOtpCooldown() {
    // Example domain rule: lock OTP verification for 60 seconds after 3 failed attempts locally.
    // True enforcement must happen on server — this is only a UI-side cooldown to avoid hammering API.
    _otpCooldownTimer?.cancel();
    state.value = state.value.copyWith(error: 'Too many attempts. Try again after 60s.');
    _otpCooldownTimer = Timer(const Duration(seconds: 60), () {
      state.value = state.value.copyWith(otpAttempts: 0, error: null);
    });
  }

  String _mapExceptionToMessage(Object e) {
    // Centralize exception -> user message mapping. Expand as needed.
    final s = e.toString();
    if (s.contains('Network')) return 'Network error. Check your connection.';
    if (s.contains('timeout')) return 'Request timed out. Try again.';
    return 'Unexpected error: $s';
  }
}
