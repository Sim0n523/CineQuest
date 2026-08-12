import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus status = AuthStatus.unknown;
  UserModel? currentUser;
  String? errorMessage;
  bool isLoading = false;

  StreamSubscription<User?>? _authSub;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _authSub = _authService.authStateChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      status = AuthStatus.unauthenticated;
      currentUser = null;
      notifyListeners();
      return;
    }

    final profile = await _authService.fetchUserProfile(firebaseUser.uid);
    if (profile != null) {
      currentUser = profile;
    }
    // If the doc doesn't exist yet (e.g. this fires mid-registration,
    // before the Firestore write completes), keep whatever currentUser
    // already is — register() below fills it in directly rather than
    // waiting on this listener, to avoid that race.
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) {
    return _run(() => _authService.signIn(email: email, password: password));
  }

  Future<bool> register(String username, String email, String password) async {
    final success = await _run(() => _authService.register(
          username: username,
          email: email,
          password: password,
        ));

    if (success) {
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        currentUser = UserModel(uid: uid, username: username, email: email, createdAt: DateTime.now());
        notifyListeners();
      }
    }
    return success;
  }

  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      errorMessage = _friendlyError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _friendlyError(Object e) {
    final message = e.toString();
    if (message.contains('email-already-in-use')) {
      return 'That email is already registered.';
    }
    if (message.contains('invalid-credential') || message.contains('wrong-password')) {
      return 'Incorrect email or password.';
    }
    if (message.contains('weak-password')) {
      return 'Password should be at least 6 characters.';
    }
    if (message.contains('invalid-email')) {
      return 'That email address looks invalid.';
    }
    if (message.contains('user-not-found')) {
      return 'No account found with that email.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> signOut() => _authService.signOut();

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
