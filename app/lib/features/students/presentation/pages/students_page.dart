import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/student_repository.dart';
import '../../domain/entities/student_entity.dart';
import 'student_details_page.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/widgets/pulse/pulse_entrance.dart';

class StudentsPage extends ConsumerWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).value;
    if (user == null) return const Center(child: CircularProgressIndicator());

    final studentsAsync = ref.watch(studentsProvider(user.id));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alunos'),
        actions: [
          IconButton(
            onPressed: () => context.go('/students/add'),
            icon: const Icon(Icons.person_add),
            tooltip: 'Adicionar aluno',
          ),
        ],
      ),
      body: studentsAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum aluno encontrado',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comece adicionando seu primeiro aluno',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/students/add'),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Adicionar Aluno'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return _StudentListTile(
                student: student,
                onTap: () => _navigateToDetails(context, student),
              ).pulseIn(index.clamp(0, 12));
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, s) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(e is Failure ? e.message : 'Erro: $e'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(studentsProvider(user.id)),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/students/add'),
        icon: const Icon(Icons.person_add),
        label: const Text('Novo Aluno'),
      ),
    );
  }

  void _navigateToDetails(BuildContext context, StudentEntity student) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentDetailsPage(student: student),
      ),
    );
  }
}

class _StudentListTile extends StatelessWidget {
  const _StudentListTile({required this.student, required this.onTap});

  final StudentEntity student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: 'student-${student.id}',
          child: UserAvatar(name: student.name, photoUrl: student.photoUrl),
        ),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.email_outlined, size: 14, color: colorScheme.outline),
            const SizedBox(width: 4),
            Expanded(
              child: Text(student.email, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 14, color: Colors.green),
              SizedBox(width: 4),
              Text(
                'Ativo',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
