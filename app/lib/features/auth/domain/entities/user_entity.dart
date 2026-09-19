import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.role,
    this.onboarded = false,
  });
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? role;

  /// True once onboarding was finished on any device (server-side).
  final bool onboarded;

  @override
  List<Object?> get props => [id, email, name, photoUrl, role, onboarded];
}
