import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/student_repository.dart';
import '../../domain/entities/student_entity.dart';

class StudentAddPage extends HookConsumerWidget {
  const StudentAddPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final phoneController = useTextEditingController();
    final notesController = useTextEditingController();
    final isLoading = useState(false);
    final photoUrl = useState<String?>(null);

    final colorScheme = Theme.of(context).colorScheme;
    final studentRepository = ref.watch(studentRepositoryProvider);

    Future<void> checkEmail() async {
      final email = emailController.text.trim();
      if (email.isEmpty || !email.contains('@')) return;

      isLoading.value = true;
      final result = await studentRepository.checkStudentExists(email);
      isLoading.value = false;

      result.fold(
        (failure) {
          // Silent fail or log?
        },
        (student) {
          if (student != null) {
            nameController.text = student.name;
            photoUrl.value = student.photoUrl;
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Aluno encontrado! Dados preenchidos.'),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          }
        },
      );
    }

    Future<void> handleSubmit() async {
      if (!formKey.currentState!.validate()) return;

      final user = ref.read(authNotifierProvider).value;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro: Usuário não autenticado'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      isLoading.value = true;

      final student = StudentEntity(
        id: '', // Server generated
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        photoUrl: photoUrl.value,
      );

      final result = await studentRepository.addStudent(student, user.id);

      isLoading.value = false;

      if (context.mounted) {
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao adicionar: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          },
          (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Aluno ${success.name} adicionado!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          },
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Aluno'),
        actions: [
          if (isLoading.value)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: handleSubmit, child: const Text('Salvar')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar picker
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.primaryContainer,
                      backgroundImage:
                          photoUrl.value != null
                              ? NetworkImage(photoUrl.value!)
                              : null,
                      child:
                          photoUrl.value == null
                              ? Icon(
                                Icons.person,
                                size: 50,
                                color: colorScheme.onPrimaryContainer,
                              )
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Adicionar foto em breve')),
                    );
                  },
                  child: const Text('Adicionar foto'),
                ),
              ),
              const SizedBox(height: 24),

              // Informações Pessoais Section
              const _SectionHeader(
                icon: Icons.person_outline,
                title: 'Informações Pessoais',
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Verificar existência',
                    onPressed: checkEmail,
                  ),
                  helperText: 'Clique na lupa para buscar se o aluno já existe',
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => checkEmail(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  if (!value.contains('@')) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone (opcional)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // Agenda Section
              const _SectionHeader(
                icon: Icons.calendar_today_outlined,
                title: 'Horários de Treino',
              ),
              const SizedBox(height: 12),

              const _ScheduleSelector(),
              const SizedBox(height: 24),

              // Notes Section
              const _SectionHeader(
                icon: Icons.notes_outlined,
                title: 'Observações',
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isLoading.value ? null : handleSubmit,
                  icon:
                      isLoading.value
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.person_add),
                  label: Text(
                    isLoading.value ? 'Salvando...' : 'Adicionar Aluno',
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ScheduleSelector extends HookWidget {
  const _ScheduleSelector();

  static const List<String> _days = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedDays = useState<Set<int>>({});
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dias da semana:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_days.length, (index) {
            final isSelected = selectedDays.value.contains(index);
            return FilterChip(
              label: Text(_days[index]),
              selected: isSelected,
              onSelected: (selected) {
                final newSet = Set<int>.from(selectedDays.value);
                if (selected) {
                  newSet.add(index);
                } else {
                  newSet.remove(index);
                }
                selectedDays.value = newSet;
              },
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.primary,
            );
          }),
        ),
        const SizedBox(height: 16),
        if (selectedDays.value.isNotEmpty) ...[
          const Text('Horário:'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 8, minute: 0),
                    );
                    if (time != null) {
                      // Handle time selection
                    }
                  },
                  icon: const Icon(Icons.access_time),
                  label: const Text('08:00'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('até'),
              ),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (time != null) {
                      // Handle time selection
                    }
                  },
                  icon: const Icon(Icons.access_time),
                  label: const Text('09:00'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
