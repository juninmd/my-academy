import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/invites_repository.dart';
import '../../domain/entities/invite_entity.dart';

final invitesRepositoryProvider = Provider<InvitesRepository>((ref) {
  return InvitesRepository(ref.watch(apiClientProvider));
});

final invitesProvider = FutureProvider.autoDispose<List<InviteEntity>>((ref) async {
  final result = await ref.watch(invitesRepositoryProvider).list();
  return result.fold((failure) => throw Exception(failure.message), (l) => l);
});

/// Admin screen: create a sign-up code and see the recent ones.
class InvitesPage extends ConsumerWidget {
  const InvitesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invites = ref.watch(invitesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Convites')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Novo convite'),
        onPressed: () async {
          final result = await ref.read(invitesRepositoryProvider).create();
          if (!context.mounted) return;
          result.fold(
            (failure) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            ),
            (code) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Código: $code')),
            ),
          );
          ref.invalidate(invitesProvider);
        },
      ),
      body: invites.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text('Nenhum convite ainda.'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final invite = list[index];
                  return ListTile(
                    title: SelectableText(invite.code),
                    subtitle: Text(_statusOf(invite, DateTime.now())),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Não foi possível carregar: $error')),
      ),
    );
  }

  static String _statusOf(InviteEntity invite, DateTime now) {
    if (invite.isUsed) return 'Usado';
    if (invite.isExpiredAt(now)) return 'Expirado';
    return 'Válido até ${invite.expiresAt.toLocal().toString().split('.').first}';
  }
}
