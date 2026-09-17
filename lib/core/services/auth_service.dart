import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/favorite_movie.dart';

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

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'username': username,
      'usernameLower': username.toLowerCase(),
      'email': email,
      'avatarBase64': null,
      'favoriteMovies': [],
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

  Future<UserModel?> fetchUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(uid, doc.data()!);
  }

  /// Self-healing for accounts created before `usernameLower` existed —
  /// Find Friends' prefix search queries against that field, and
  /// Firestore excludes any doc that's missing an orderBy field
  /// entirely, so without this, pre-existing accounts would simply
  /// never appear in search results. Called on every login
  /// (AuthProvider._onAuthChanged) — cheap, idempotent single-field
  /// write, safe to repeat.
  Future<void> backfillUsernameLower(String uid, String username) {
    return _firestore.collection('users').doc(uid).update({
      'usernameLower': username.toLowerCase(),
    });
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateAvatar(String uid, String avatarBase64) {
    return _firestore.collection('users').doc(uid).update({'avatarBase64': avatarBase64});
  }

  Future<void> updateFavoriteMovies(String uid, List<FavoriteMovie> favorites) {
    return _firestore.collection('users').doc(uid).update({
      'favoriteMovies': favorites.map((f) => f.toMap()).toList(),
    });
  }
}
