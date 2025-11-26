/// Base result type for auth operations.
abstract class AuthResult {
  const AuthResult();
}

class AuthSuccess extends AuthResult {
  final String uid;
  final String email;
  const AuthSuccess({required this.uid, required this.email});
}

class AuthFailure extends AuthResult {
  final String message;
  const AuthFailure(this.message);
}

/// Simple user model — minimal and intentionally small.
class User {
  final String uid;
  final String email;
  final String? displayName;
  const User({required this.uid, required this.email, this.displayName});
}
