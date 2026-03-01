import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/daily_notes_repository.dart';

final dailyNotesProvider = FutureProvider.autoDispose<DailyNote?>((ref) async {
  final repository = ref.watch(dailyNotesRepositoryProvider);
  return repository.getNoteForToday();
});

class DailyNotesNotifier extends AsyncNotifier<DailyNote?> {
  @override
  Future<DailyNote?> build() async {
    final repository = ref.watch(dailyNotesRepositoryProvider);
    return repository.getNoteForToday();
  }

  Future<void> saveNote(String mood, String text, int energyLevel) async {
    final repository = ref.read(dailyNotesRepositoryProvider);
    state = const AsyncValue.loading();
    try {
      final note = DailyNote(
        date: DateTime.now(),
        mood: mood,
        note: text,
        energyLevel: energyLevel,
      );
      await repository.saveNote(note);
      state = AsyncValue.data(note);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}

final dailyNotesNotifierProvider =
    AsyncNotifierProvider<DailyNotesNotifier, DailyNote?>(
      DailyNotesNotifier.new,
    );
