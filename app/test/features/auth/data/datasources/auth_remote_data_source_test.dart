import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:my_academy/core/exceptions/failure.dart';
import 'package:my_academy/core/network/api_client.dart';
import 'package:my_academy/features/auth/data/datasources/auth_remote_data_source.dart';

import 'auth_remote_data_source_test.mocks.dart';

// Since UserCredential cannot be cleanly generated we mock it here.
class MockUserCredential extends Mock implements UserCredential {
  final User? _user;
  MockUserCredential(this._user);

  @override
  User? get user => _user;
}

@GenerateMocks([
  FirebaseAuth,
  GoogleSignIn,
  User,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
])
void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockApiClientManual mockApiClient;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockApiClient = MockApiClientManual();

    dataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
      apiClient: mockApiClient,
    );
  });

  group('signInWithGoogle', () {
    test('should return UserDto when successful', () async {
      final mockGoogleAccount = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();
      final mockUser = MockUser();
      final mockUserCredential = MockUserCredential(mockUser);

      when(mockGoogleSignIn.initialize()).thenAnswer((_) async {});
      when(
        mockGoogleSignIn.authenticate(),
      ).thenAnswer((_) async => mockGoogleAccount);
      when(mockGoogleAccount.authentication).thenReturn(mockGoogleAuth);
      when(mockGoogleAuth.idToken).thenReturn('test_id_token');

      when(
        mockFirebaseAuth.signInWithCredential(any),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      when(mockUser.uid).thenReturn('123');
      when(mockUser.email).thenReturn('test@test.com');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.photoURL).thenReturn('url');

      // mock ID token
      when(mockUser.getIdToken()).thenAnswer((_) async => 'fake_token');

      final result = await dataSource.signInWithGoogle();

      expect(result.id, '123');
      expect(result.email, 'test@test.com');
    });

    test('should throw AuthFailure when Google Sign In is canceled', () async {
      when(mockGoogleSignIn.initialize()).thenAnswer((_) async {});
      when(mockGoogleSignIn.authenticate()).thenThrow(
        const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
      );

      expect(() => dataSource.signInWithGoogle(), throwsA(isA<AuthFailure>()));
    });
  });

  group('signOut', () {
    test('should call signOut on dependencies', () async {
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async {});
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await dataSource.signOut();

      verify(mockGoogleSignIn.signOut());
      verify(mockFirebaseAuth.signOut());
    });
  });

  group('getCurrentUser', () {
    test('should return UserDto when user is logged in', () async {
      final mockUser = MockUser();
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      when(mockUser.uid).thenReturn('123');
      when(mockUser.email).thenReturn('test@test.com');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.photoURL).thenReturn('url');

      // Sync backend
      when(mockUser.getIdToken()).thenAnswer((_) async => 'fake_token');

      final result = await dataSource.getCurrentUser();

      expect(result?.id, '123');
    });

    test('should return null when user is not logged in', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      final result = await dataSource.getCurrentUser();

      expect(result, isNull);
    });
  });
}

class MockApiClientManual implements ApiClient {
  String? token;

  @override
  void setAuthToken(String token) {
    this.token = token;
  }

  @override
  void clearAuthToken() {
    token = null;
  }

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return {
      'id': '123',
      'email': 'test@test.com',
      'name': 'Test User',
      'avatarUrl': 'url',
      'role': 'USER',
    } as T;
  }

  @override
  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    throw UnimplementedError();
  }
}
