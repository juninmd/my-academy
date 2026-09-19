/// Mirrors the self-assignable API roles.
enum UserRole {
  student('STUDENT', 'Aluno', 'Quero montar e registrar meus treinos'),
  personal('PERSONAL', 'Personal trainer', 'Acompanho alunos e suas fichas'),
  owner(
    'OWNER',
    'Dono de academia',
    'Gerencio planos, matrículas e pagamentos',
  );

  const UserRole(this.apiValue, this.label, this.description);

  final String apiValue;
  final String label;
  final String description;

  // ADMIN (catalog curator, granted in the DB) can also own gyms.
  static UserRole fromApi(String? value) =>
      value == 'ADMIN'
          ? UserRole.owner
          : UserRole.values.firstWhere(
            (r) => r.apiValue == value,
            orElse: () => UserRole.student,
          );
}
