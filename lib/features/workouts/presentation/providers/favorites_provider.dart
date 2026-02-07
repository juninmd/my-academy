import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<int>>(FavoritesNotifier.new);

class FavoritesNotifier extends AsyncNotifier<Set<int>> {
  static const _key = 'favorite_exercises';

  @override
  FutureOr<Set<int>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => int.tryParse(e) ?? -1).where((e) => e != -1).toSet();
  }

  Future<void> toggleFavorite(int exerciseId) async {
    final current = state.value ?? {};
    final newSet = {...current};
    if (newSet.contains(exerciseId)) {
      newSet.remove(exerciseId);
    } else {
      newSet.add(exerciseId);
    }
    // Optimistic update
    state = AsyncData(newSet);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newSet.map((e) => e.toString()).toList());
  }
}
