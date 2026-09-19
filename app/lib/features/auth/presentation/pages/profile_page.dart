import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../gym/presentation/widgets/memberships_card.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).value;
      if (user != null) {
        _nameController.text = user.name ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.hasValue && next.value != null && !_isEditing) {
        if (_nameController.text != (next.value?.name ?? '')) {
          _nameController.text = next.value?.name ?? '';
        }
      }
    });

    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Nenhum usuário logado.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: UserAvatar(
                    name: user.name ?? user.email,
                    photoUrl: user.photoUrl,
                    radius: 50,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Nome de Exibição',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        enabled: _isEditing,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: _isEditing ? 'Salvar nome' : 'Editar nome',
                      icon: Icon(_isEditing ? Icons.check : Icons.edit),
                      onPressed: () async {
                        if (_isEditing) {
                          // Save changes
                          await ref
                              .read(authNotifierProvider.notifier)
                              .updateName(_nameController.text);
                          if (mounted) {
                            setState(() {
                              _isEditing = false;
                            });
                          }
                        } else {
                          setState(() {
                            _isEditing = true;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(user.email, style: const TextStyle(fontSize: 16)),
                const MembershipsCard(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }
}
