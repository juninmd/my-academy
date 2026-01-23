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
  MockSpec<ApiClient>(),
])
import 'auth_remote_data_source_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockApiClient mockApiClient;
  late AuthRemoteDataSourceImpl dataSource;

  late MockGoogleSignInAccount mockGoogleUser;
  late MockGoogleSignInAuthentication mockGoogleAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockApiClient = MockApiClient();
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
      when(mockGoogleUser.authentication).thenAnswer((_) async => mockGoogleAuth);
      when(mockGoogleAuth.accessToken).thenReturn('access_token');
      when(mockGoogleAuth.idToken).thenReturn('id_token');

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
      verify(mockApiClient.setAuthToken('token'));
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
      await dataSource.signOut();
      verify(mockGoogleSignIn.signOut());
      verify(mockFirebaseAuth.signOut());
      verify(mockApiClient.clearAuthToken());
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
      verify(mockApiClient.setAuthToken('token'));
    });

    test('should return null when user is not logged in', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      final result = await dataSource.getCurrentUser();
      expect(result, null);
    });
  });
}
