import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/core/exceptions/failure.dart';
import 'package:my_academy/core/network/api_client.dart';
import 'package:my_academy/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:my_academy/features/auth/data/models/user_dto.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<GoogleSignIn>(),
  MockSpec<GoogleSignInAccount>(),
  MockSpec<GoogleSignInAuthentication>(),
  MockSpec<UserCredential>(),
  MockSpec<User>(),
])
import 'auth_remote_data_source_test.mocks.dart';

// Manual Mock for ApiClient
class MockApiClientManual implements ApiClient {
  String? capturedAuthToken;
  bool clearAuthTokenCalled = false;
  final List<String> postCalls = [];

  @override
  void setAuthToken(String token) {
    capturedAuthToken = token;
  }

  @override
  void clearAuthToken() {
    clearAuthTokenCalled = true;
  }

  @override
  Future<dynamic> post(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
  }) async {
    postCalls.add(path);
    return null;
  }

  @override
  Future delete(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
  }) async => null;

  @override
  Future get(String path, {Map<String, dynamic>? queryParameters}) async =>
      null;

  @override
  Future put(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
  }) async => null;
}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockApiClientManual mockApiClient;
  late AuthRemoteDataSourceImpl dataSource;

  late MockGoogleSignInAccount mockGoogleUser;
  late MockGoogleSignInAuthentication mockGoogleAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockApiClient = MockApiClientManual();
    dataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
      apiClient: mockApiClient,
    );

    mockGoogleUser = MockGoogleSignInAccount();
    mockGoogleAuth = MockGoogleSignInAuthentication();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
  });

  group('signInWithGoogle', () {
    test('should return UserDto when successful', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleUser);
      when(mockGoogleUser.authentication)
          .thenAnswer((_) async => mockGoogleAuth);
      when(mockGoogleAuth.accessToken).thenReturn('access_token');
      when(mockGoogleAuth.idToken).thenReturn('id_token');

      // Note: We cannot easily mock the static GoogleAuthProvider.credential.
      // However, we mock signInWithCredential to accept ANY credential.
      when(mockFirebaseAuth.signInWithCredential(any))
          .thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('1');
      when(mockUser.email).thenReturn('email');
      when(mockUser.displayName).thenReturn('name');
      when(mockUser.photoURL).thenReturn('url');
      when(mockUser.getIdToken()).thenAnswer((_) async => 'token');

      final result = await dataSource.signInWithGoogle();

      expect(result, isA<UserDto>());
      // Verify manual mock state
      expect(mockApiClient.capturedAuthToken, 'token');
      expect(mockApiClient.postCalls, contains('/users'));
    });

    test('should throw AuthFailure when Google Sign In is canceled', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      expect(
        () => dataSource.signInWithGoogle(),
        throwsA(isA<AuthFailure>()),
      );
    });
  });

  group('signOut', () {
    test('should call signOut on dependencies', () async {
      // Explicitly stub signOut to return void Future
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await dataSource.signOut();

      verify(mockGoogleSignIn.signOut()).called(1);
      verify(mockFirebaseAuth.signOut()).called(1);

      // Verify manual mock
      expect(mockApiClient.clearAuthTokenCalled, true);
    });
  });

  group('getCurrentUser', () {
    test('should return UserDto when user is logged in', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('1');
      when(mockUser.email).thenReturn('email');
      when(mockUser.displayName).thenReturn('name');
      when(mockUser.photoURL).thenReturn('url');
      when(mockUser.getIdToken()).thenAnswer((_) async => 'token');

      final result = await dataSource.getCurrentUser();
      expect(result, isA<UserDto>());
      expect(mockApiClient.capturedAuthToken, 'token');
    });

    test('should return null when user is not logged in', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      final result = await dataSource.getCurrentUser();
      expect(result, null);
    });
  });
}
