import 'package:equatable/equatable.dart';

class StudentEntity extends Equatable {
  const StudentEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  @override
  List<Object?> get props => [id, name, email, photoUrl];
}
