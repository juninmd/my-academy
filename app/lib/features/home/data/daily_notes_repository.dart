import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyNote {
  final DateTime date;
  final String mood; // Emoji
  final String note;
  final int energyLevel; // 1 to 10

  DailyNote({
    required this.date,
    required this.mood,
    required this.note,
    this.energyLevel = 5,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mood': mood,
      'note': note,
      'energyLevel': energyLevel,
    };
  }

  factory DailyNote.fromJson(Map<String, dynamic> json) {
    return DailyNote(
      date: DateTime.parse(json['date']),
      mood: json['mood'],
      note: json['note'],
      energyLevel: json['energyLevel'] ?? 5,
    );
  }
}

class DailyNotesRepository {
  static const String _storageKey = 'daily_notes';

  Future<List<DailyNote>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];
    return jsonList
        .map((jsonStr) => DailyNote.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  Future<void> saveNote(DailyNote note) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getNotes();

    // Remove existing note for the same day
    notes.removeWhere(
      (n) =>
          n.date.year == note.date.year &&
          n.date.month == note.date.month &&
          n.date.day == note.date.day,
    );

    notes.add(note);

    // Save
    final jsonList = notes.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  Future<DailyNote?> getNoteForToday() async {
    final notes = await getNotes();
    final now = DateTime.now();
    return notes
        .where(
          (n) =>
              n.date.year == now.year &&
              n.date.month == now.month &&
              n.date.day == now.day,
        )
        .firstOrNull;
  }
}

final dailyNotesRepositoryProvider = Provider((ref) => DailyNotesRepository());
