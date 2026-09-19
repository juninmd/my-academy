import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/exceptions/failure.dart';
import 'package:my_academy/core/network/api_client.dart';
import 'package:my_academy/features/auth/data/datasources/user_profile_sync.dart';
import 'package:my_academy/features/auth/data/models/user_dto.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_academy/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuth extends AuthNotifier {
  _FakeAuth(this.user);
  final UserEntity user;
  @override
  Future<UserEntity?> build() async => user;
}

class _FakeSync extends UserProfileSync {
  _FakeSync({this.fail = false}) : super(ApiClient(baseUrl: 'http://x/'));
  final bool fail;
  final marked = <String>[];
  @override
  Future<void> markOnboarded(String userId) async {
    if (fail) throw const NetworkFailure('offline');
    marked.add(userId);
  }
}

ProviderContainer _container(UserEntity user, _FakeSync sync) {
  final c = ProviderContainer(
    overrides: [
      authNotifierProvider.overrideWith(() => _FakeAuth(user)),
      userProfileSyncProvider.overrideWithValue(sync),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a returning user on a new device skips onboarding', () async {
    const user = UserEntity(id: 'u1', email: 'a@b.dev', onboarded: true);
    final c = _container(user, _FakeSync());
    await c.read(authNotifierProvider.future);
    expect(await c.read(onboardingProvider.future), isTrue);
  });

  test('finishing onboarding is saved on the server', () async {
    const user = UserEntity(id: 'u1', email: 'a@b.dev');
    final sync = _FakeSync();
    final c = _container(user, sync);
    await c.read(authNotifierProvider.future);
    expect(await c.read(onboardingProvider.future), isFalse);

    await c.read(onboardingProvider.notifier).completeOnboarding();
    expect(sync.marked, ['u1']);
    expect(c.read(onboardingProvider).value, isTrue);
  });

  test('offline completion still unblocks the user locally', () async {
    const user = UserEntity(id: 'u1', email: 'a@b.dev');
    final c = _container(user, _FakeSync(fail: true));
    await c.read(authNotifierProvider.future);
    await c.read(onboardingProvider.future);

    await c.read(onboardingProvider.notifier).completeOnboarding();
    expect(c.read(onboardingProvider).value, isTrue);
  });

  test('backend onboardedAt maps to onboarded', () {
    final dto = UserDto.fromJson({
      'id': 'u1',
      'email': 'a@b.dev',
      'onboardedAt': '2026-09-18T20:00:00.000Z',
    });
    expect(dto.onboarded, isTrue);
    expect(
      UserDto.fromJson({'id': 'u2', 'email': 'c@d.dev'}).onboarded,
      isFalse,
    );
  });
}
