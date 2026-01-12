import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<UserDto> signInWithGoogle();
  Future<void> signOut();
  Future<UserDto?> getCurrentUser();
  Future<String> getAuthToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required ApiClient apiClient,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn,
       _apiClient = apiClient;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final ApiClient _apiClient;

  @override
  Future<UserDto> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthFailure('Google Sign-In canceled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw const AuthFailure('Failed to sign in with Firebase');
      }

      final token = await user.getIdToken();
      if (token == null) {
        throw const AuthFailure('Failed to retrieve ID Token');
      }

      // Update ApiClient with new token
      _apiClient.setAuthToken(token);

      return UserDto(
        id: user.uid,
        email: user.email!,
        name: user.displayName,
        photoUrl: user.photoURL,
      );
    } catch (e) {
      if (e is AuthFailure) rethrow;
      logger.e('Sign in error', error: e);
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      _apiClient.clearAuthToken();
    } catch (e) {
      logger.e('Sign out error', error: e);
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserDto?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }
      return UserDto(
        id: user.uid,
        email: user.email!,
        name: user.displayName,
        photoUrl: user.photoURL,
      );
    }
    return null;
  }

  @override
  Future<String> getAuthToken() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return await user.getIdToken() ?? '';
    }
    return '';
  }
}
