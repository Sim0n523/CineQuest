import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Wraps FirebaseAuth plus the matching Firestore user document.
/// AuthProvider is the only thing that should call this directly —
/// nothing above the provider layer should import firebase_auth or
/// cloud_firestore for account data.
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(username);

    // Seed the user document. XP/level/stats all start at zero —
    // ProgressionService takes over from here once movie logging exists.
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'username': username,
      'email': email,
      'avatarUrl': null,
      'xp': 0,
      'level': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'moviesWatched': 0,
      'reviewsWritten': 0,
      'currentStreak': 0,
      'longestStreak': 0,
      'achievementsUnlocked': 0,
      'collectionsCompleted': 0,
    });

    return credential;
  }

  /// Fetches the Firestore profile for a signed-in user, or null if the
  /// document doesn't exist (e.g. it hasn't been written yet).
  Future<UserModel?> fetchUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(uid, doc.data()!);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }
}
