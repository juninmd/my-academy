import 'dart:async'; // Added here

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/constants.dart';

// Unified Auth User
class AuthUser {
  AuthUser({required this.id, this.email, this.displayName, this.photoUrl});

  factory AuthUser.fromFirebase(User user) => AuthUser(
    id: user.uid,
    email: user.email,
    displayName: user.displayName,
    photoUrl: user.photoURL,
  );
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
}

abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;
  AuthUser? get currentUser;
  Future<AuthUser?> signInWithGoogle();
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // GoogleSignIn provider - requires proper Firebase/Google configuration
  // TODO: Fix GoogleSignIn API usage
  GoogleSignIn? _googleSignIn;

  @override
  Stream<AuthUser?> get authStateChanges => _auth.authStateChanges().map(
    (user) => user != null ? AuthUser.fromFirebase(user) : null,
  );

  @override
  AuthUser? get currentUser =>
      _auth.currentUser != null
          ? AuthUser.fromFirebase(_auth.currentUser!)
          : null;

  @override
  Future<AuthUser?> signInWithGoogle() async {
    // TODO: Implement proper Google Sign-In
    // This requires firebase_core and proper Google configuration
    throw UnimplementedError('Google Sign-In not configured');
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn?.signOut();
    await _auth.signOut();
  }
}

class MockAuthRepository implements AuthRepository {
  MockAuthRepository() {
    // Initialize with null or persisted state logic if needed
    // For now, start as null (logged out)
    _controller.add(null);
  }
  final _mockUser = AuthUser(
    id: 'db6i035Vjtb77a7cBDnXQVPd3oL2',
    displayName: 'Mock User',
    email: 'mock@example.com',
    photoUrl: 'https://i.pravatar.cc/150?u=db6i035Vjtb77a7cBDnXQVPd3oL2',
  );

  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser?> signInWithGoogle() async {
    print('[MockAuthRepository] signInWithGoogle() called - using MOCK auth');
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
    _currentUser = _mockUser;
    _controller.add(_mockUser);
    print('[MockAuthRepository] Mock user emitted: ${_mockUser.email}');
    return _mockUser;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    _controller.add(null);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (useMockAuth) {
    return MockAuthRepository();
  } else {
    return FirebaseAuthRepository();
  }
});
