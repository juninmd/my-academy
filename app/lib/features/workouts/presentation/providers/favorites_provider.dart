import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/sources/favorites_remote_source.dart';

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<int>>(
  FavoritesNotifier.new,
);

final favoritesRemoteProvider = Provider<FavoritesRemoteSource>((ref) {
  return FavoritesRemoteSource(ref.watch(apiClientProvider));
});

/// Signed-in user id; null keeps favourites on this device only.
final favoritesUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).value?.id;
});

class FavoritesNotifier extends AsyncNotifier<Set<int>> {
  static const _key = 'favorite_exercises';

  @override
  FutureOr<Set<int>> build() async {
    final local = await _readLocal();
    final userId = ref.read(favoritesUserIdProvider);
    if (userId == null) return local;

    try {
      final remote = await ref.read(favoritesRemoteProvider).list(userId);
      final merged = {...local, ...remote};
      // Favourites made offline or before sign-in are pushed up once.
      for (final id in local.difference(remote)) {
        unawaited(_sync(userId, id, add: true));
      }
      await _writeLocal(merged);
      return merged;
    } catch (_) {
      return local;
    }
  }

  Future<void> toggleFavorite(int exerciseId) async {
    final current = state.value ?? {};
    final newSet = {...current};
    final add = !newSet.contains(exerciseId);
    if (add) {
      newSet.add(exerciseId);
    } else {
      newSet.remove(exerciseId);
    }
    // Optimistic update
    state = AsyncData(newSet);
    await _writeLocal(newSet);

    final userId = ref.read(favoritesUserIdProvider);
    if (userId != null) {
      unawaited(_sync(userId, exerciseId, add: add));
    }
  }

  /// Best effort: the local copy is already right, so a failed call is ignored.
  Future<void> _sync(String userId, int exerciseId, {required bool add}) async {
    try {
      final remote = ref.read(favoritesRemoteProvider);
      if (add) {
        await remote.add(userId, exerciseId);
      } else {
        await remote.remove(userId, exerciseId);
      }
    } catch (_) {
      // Ignored on purpose; the next sign-in merges the lists again.
    }
  }

  Future<Set<int>> _readLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => int.tryParse(e) ?? -1).where((e) => e != -1).toSet();
  }

  Future<void> _writeLocal(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.map((e) => e.toString()).toList());
  }
}
