import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authNotifierProvider);
    final user = userState.value;

    final nameController = useTextEditingController(text: user?.name ?? '');
    final emailController = useTextEditingController(text: user?.email ?? '');

    // Listen to user changes to update controllers
    useEffect(() {
      nameController.text = user?.name ?? '';
      emailController.text = user?.email ?? '';
      return null;
    }, [user]);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body:
          user == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                // Added ScrollView
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        backgroundImage:
                            user.photoUrl != null
                                ? NetworkImage(user.photoUrl!)
                                : null,
                        child:
                            user.photoUrl == null
                                ? Text(
                                  user.name?.isNotEmpty == true
                                      ? user.name![0].toUpperCase()
                                      : '?',
                                  style:
                                      Theme.of(context).textTheme.headlineLarge,
                                )
                                : null,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Form Fields
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true, // For now read-only as per legacy
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),

                    const SizedBox(height: 32),

                    // Actions
                    ElevatedButton.icon(
                      onPressed: () {
                        // Implement Edit functionality later
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edição em breve')),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar Perfil'),
                    ),

                    const SizedBox(height: 16),

                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(authNotifierProvider.notifier).signOut();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sair'),
                    ),
                  ],
                ),
              ),
    );
  }
}
