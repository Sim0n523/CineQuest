import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/watch_history_entry.dart';
import '../services/auth_service.dart';
import '../services/progression_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final ProgressionService _progressionService;

  AuthStatus status = AuthStatus.unknown;
  UserModel? currentUser;
  String? errorMessage;
  bool isLoading = false;

  StreamSubscription<User?>? _authSub;

  AuthProvider({AuthService? authService, ProgressionService? progressionService})
      : _authService = authService ?? AuthService(),
        _progressionService = progressionService ?? ProgressionService() {
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

  /// Only called for a brand-new log, never an edit — see the note on
  /// ProgressionService for why. Returns null (rather than throwing) if
  /// progression fails, since the movie itself is already logged either
  /// way by this point; it isn't worth blocking that on a stats update.
  Future<ProgressionResult?> recordMovieLogged({
    required List<WatchHistoryEntry> updatedHistory,
    required bool wroteReview,
  }) async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final result = await _progressionService.processMovieLogged(
        uid: user.uid,
        updatedHistory: updatedHistory,
        wroteReview: wroteReview,
        currentXp: user.xp,
      );

      currentUser = user.copyWith(
        xp: result.newXp,
        level: result.newLevel,
        moviesWatched: updatedHistory.length,
        reviewsWritten:
            updatedHistory.where((e) => (e.review ?? '').trim().isNotEmpty).length,
        achievementsUnlocked: result.totalAchievementsUnlocked,
      );
      notifyListeners();
      return result;
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
