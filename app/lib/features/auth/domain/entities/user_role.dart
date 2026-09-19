/// Mirrors the API `Role` enum; ADMIN is the gym owner persona.
enum UserRole {
  student('STUDENT', 'Aluno', 'Quero montar e registrar meus treinos'),
  personal('PERSONAL', 'Personal trainer', 'Acompanho alunos e suas fichas'),
  owner(
    'ADMIN',
    'Dono de academia',
    'Gerencio planos, matrículas e pagamentos',
  );

  const UserRole(this.apiValue, this.label, this.description);

  final String apiValue;
  final String label;
  final String description;

  static UserRole fromApi(String? value) => UserRole.values.firstWhere(
    (r) => r.apiValue == value,
    orElse: () => UserRole.student,
  );
}
