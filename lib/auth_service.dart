import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'models.dart';

class AuthResult {
  final bool success;
  final String? error;
  AuthResult({required this.success, this.error});
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      User? fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        _currentUser = AppUser(
          id: fbUser.uid,
          name: fbUser.displayName ?? fbUser.email!.split('@').first,
          email: fbUser.email ?? '',
        );
      }
    } catch (_) {}
  }

  Future<AuthResult> signIn(String email, String password) async {
    String clean = email.trim().toLowerCase();
    if (clean.isEmpty || password.isEmpty) {
      return AuthResult(success: false, error: 'Please enter your email and password.');
    }
    if (!clean.contains('@') || !clean.contains('.')) {
      return AuthResult(success: false, error: 'Please enter a valid email address.');
    }
    if (password.length < 6) {
      return AuthResult(success: false, error: 'Password must be at least 6 characters.');
    }
    try {
      UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: clean,
        password: password,
      );
      User? user = credential.user;
      if (user != null) {
        _currentUser = AppUser(
          id: user.uid,
          name: user.displayName ?? clean.split('@').first,
          email: user.email ?? clean,
        );
      }
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: e.message ?? 'Authentication failed.');
    } catch (e) {
      return AuthResult(success: false, error: 'Firebase error: ${e.toString()}');
    }
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    String phone = '+880 1712-345678',
    required String gender,
  }) async {
    String clean = email.trim().toLowerCase();
    if (gender.isEmpty || (gender != 'Male' && gender != 'Female' && gender != 'Boy' && gender != 'Girl')) {
      return AuthResult(success: false, error: 'Please select your gender to create an account.');
    }
    if (name.length < 2) {
      return AuthResult(success: false, error: 'Please enter your real full name (at least 2 characters).');
    }
    if (!clean.contains('@') || !clean.contains('.')) {
      return AuthResult(success: false, error: 'Please enter a valid email address (e.g. name@domain.com).');
    }
    if (password.length < 6) {
      return AuthResult(success: false, error: 'Password must be at least 6 characters.');
    }
    try {
      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: clean,
        password: password,
      );
      User? user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        _currentUser = AppUser(
          id: user.uid,
          name: name,
          email: user.email ?? clean,
          phone: phone,
          gender: gender,
        );
      }
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: e.message ?? 'Registration failed.');
    } catch (e) {
      return AuthResult(success: false, error: 'Firebase error: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    _currentUser = null;
  }

  Future<String> resetPassword(String email) async {
    String clean = email.trim().toLowerCase();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: clean);
      return 'Password reset link sent to $clean';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to send reset email.';
    } catch (e) {
      return 'Firebase error: ${e.toString()}';
    }
  }
}
