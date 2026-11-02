import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/network/api_client.dart';
import 'package:my_academy/features/workouts/data/sources/favorites_remote_source.dart';
import 'package:my_academy/features/workouts/presentation/providers/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRemote extends FavoritesRemoteSource {
  FakeRemote({
    this.serverIds = const {},
    this.failList = false,
    this.failWrites = false,
  }) : super(ApiClient(baseUrl: 'http://api.test/'));

  final Set<int> serverIds;
  final bool failList;
  final bool failWrites;
  final Set<int> added = {};
  final Set<int> removed = {};

  @override
  Future<Set<int>> list(String userId) async {
    if (failList) throw Exception('offline');
    return serverIds;
  }

  @override
  Future<void> add(String userId, int exerciseId) async {
    if (failWrites) throw Exception('offline');
    added.add(exerciseId);
  }

  @override
  Future<void> remove(String userId, int exerciseId) async {
    if (failWrites) throw Exception('offline');
    removed.add(exerciseId);
  }
}

ProviderContainer containerWith({String? userId, required FakeRemote remote}) {
  return ProviderContainer(
    overrides: [
      favoritesUserIdProvider.overrideWithValue(userId),
      favoritesRemoteProvider.overrideWithValue(remote),
    ],
  );
}

/// Lets the fire-and-forget sync calls finish.
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'favorite_exercises': ['1'],
    });
  });

  test(
    'merges device and server favourites and pushes the device-only ones',
    () async {
      final remote = FakeRemote(serverIds: {2});
      final container = containerWith(userId: 'u1', remote: remote);
      addTearDown(container.dispose);

      expect(await container.read(favoritesProvider.future), {1, 2});
      await settle();
      expect(remote.added, {1});
    },
  );

  test('keeps local favourites when the server cannot be reached', () async {
    final container = containerWith(
      userId: 'u1',
      remote: FakeRemote(failList: true),
    );
    addTearDown(container.dispose);

    expect(await container.read(favoritesProvider.future), {1});
  });

  test('stays on the device when nobody is signed in', () async {
    final remote = FakeRemote(failList: true, failWrites: true);
    final container = containerWith(remote: remote);
    addTearDown(container.dispose);

    expect(await container.read(favoritesProvider.future), {1});
    await container.read(favoritesProvider.notifier).toggleFavorite(5);
    await settle();
    expect(container.read(favoritesProvider).value, {1, 5});
    expect(remote.added, isEmpty);
  });

  test(
    'toggling syncs the change and keeps the local copy when the call fails',
    () async {
      final remote = FakeRemote();
      final container = containerWith(userId: 'u1', remote: remote);
      addTearDown(container.dispose);
      await container.read(favoritesProvider.future);

      await container.read(favoritesProvider.notifier).toggleFavorite(3);
      await settle();
      expect(remote.added, contains(3));
      expect(container.read(favoritesProvider).value, {1, 3});

      await container.read(favoritesProvider.notifier).toggleFavorite(3);
      await settle();
      expect(remote.removed, contains(3));
      expect(container.read(favoritesProvider).value, {1});

      final failing = FakeRemote(failWrites: true);
      final offline = containerWith(userId: 'u1', remote: failing);
      addTearDown(offline.dispose);
      await offline.read(favoritesProvider.future);
      await offline.read(favoritesProvider.notifier).toggleFavorite(7);
      await settle();
      expect(offline.read(favoritesProvider).value, {1, 7});
    },
  );
}
