import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/core/exceptions/failure.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/domain/repositories/auth_repository.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('AuthNotifier', () {
    test('build should return user when getCurrentUser is successful', () async {
      const user = UserEntity(id: '1', email: 'test@test.com');

      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(user));

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );

      final result = await container.read(authNotifierProvider.future);
      expect(result, user);
      verify(mockAuthRepository.getCurrentUser()).called(1);
    });

    test('build should return null when getCurrentUser fails', () async {
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(ServerFailure('Error')));

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );

      final result = await container.read(authNotifierProvider.future);
      expect(result, null);
    });

    test('signInWithGoogle should update state with user on success', () async {
      const user = UserEntity(id: '1', email: 'test@test.com');

      // Mock initial load
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));

      when(mockAuthRepository.signInWithGoogle())
          .thenAnswer((_) async => const Right(user));

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );

      // Initialize
      container.read(authNotifierProvider);

      // Perform action
      await container.read(authNotifierProvider.notifier).signInWithGoogle();

      // Check state
      final state = container.read(authNotifierProvider);
      expect(state.value, user);
    });

    test('signInWithGoogle should update state with error on failure', () async {
      // Mock initial load
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));

      when(mockAuthRepository.signInWithGoogle())
          .thenAnswer((_) async => const Left(ServerFailure('Error login')));

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );

      // Initialize
      container.read(authNotifierProvider);

      // Perform action
      await container.read(authNotifierProvider.notifier).signInWithGoogle();

      // Check state
      final state = container.read(authNotifierProvider);
      expect(state.hasError, true);
    });

    test('signOut should update state to null', () async {
       // Mock initial load
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(UserEntity(id: '1', email: 't')));

      when(mockAuthRepository.signOut())
          .thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );

       // Initialize
      await container.read(authNotifierProvider.future);

      // Perform action
      await container.read(authNotifierProvider.notifier).signOut();

      // Check state
      final state = container.read(authNotifierProvider);
      expect(state.value, null);
    });
  });
}
