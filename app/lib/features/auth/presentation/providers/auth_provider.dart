import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../utils/constants.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/mock_auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
GoogleSignIn googleSignIn(Ref ref) => GoogleSignIn();

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  if (useMockAuth) {
    return MockAuthRemoteDataSourceImpl(
      apiClient: ref.watch(apiClientProvider),
    );
  }
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
    apiClient: ref.watch(apiClientProvider),
  );
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<UserEntity?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final result = await repository.getCurrentUser();
    return result.fold((failure) => null, (user) => user);
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signInWithGoogle();

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      AsyncValue.data,
    );
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signInWithEmail(email, password);

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      AsyncValue.data,
    );
  }

  Future<void> signUpWithEmail(
    String email,
    String password, {
    String? role,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signUpWithEmail(email, password, role);

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      AsyncValue.data,
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> updateName(String name) async {
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.updateDisplayName(name);

    if (result.isRight()) {
      // Refresh the user state
      state = const AsyncValue.loading();
      final userResult = await repository.getCurrentUser();
      state = userResult.fold(
        (failure) => AsyncValue.error(failure.message, StackTrace.current),
        AsyncValue.data,
      );
    }
  }
}

// Alias for backward compatibility
final authNotifierProvider = authProvider;
