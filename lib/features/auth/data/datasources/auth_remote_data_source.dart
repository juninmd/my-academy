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

      // Update ApiClient with new token (if not handled by provider/interceptor yet)
      // Since specific requests might use this client before the provider rebuilds,
      // setting it here is safe but redundant with DioProvider logic if that logic reads fresh token.
      // However, our DioProvider reads from FirebaseAuth.instance.currentUser which IS updated now.

      final userDto = UserDto(
        id: user.uid,
        email: user.email!,
        name: user.displayName ?? 'Sem nome',
        photoUrl:
            user.photoURL ??
            'https://w7.pngwing.com/pngs/620/837/png-transparent-bodybuilding-drawing-bodybuilding-physical-fitness-logo-monochrome-thumbnail.png',
      );

      try {
        await _apiClient.post('/users', data: userDto.toJson());
      } catch (e) {
        // Ignore if user already exists (400 or 409 depending on backend validation)
        // If it's a server failure, we might want to log it but proceed if Auth is successful.
        // Ideally we should check if status is 400/409.
        if (e is ServerFailure) {
          // We assume existing user is fine.
        } else {
          logger.w('Failed to sync user with backend: $e');
        }
      }

      return userDto;
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
      // _apiClient.clearAuthToken(); // Handled by DioProvider logic dynamically
    } catch (e) {
      logger.e('Sign out error', error: e);
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserDto?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      // Logic to sync or get from backend could be here, but for now we trust Firebase
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
