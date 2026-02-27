import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/daily_notes_provider.dart';
import 'quick_note_dialog.dart';

class DailyNoteCard extends ConsumerWidget {
  const DailyNoteCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(dailyNotesNotifierProvider);

    return noteAsync.when(
      data: (note) {
        if (note == null) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 24),
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const QuickNoteDialog(),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_note, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Diário de Hoje',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        note.mood,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.note,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}
