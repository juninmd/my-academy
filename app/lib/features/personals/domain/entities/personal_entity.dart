import 'package:equatable/equatable.dart';

class PersonalEntity extends Equatable {
  const PersonalEntity({
    required this.id,
    required this.personalUserId,
    required this.studentUserId,
  });

  final int id;
  final String personalUserId;
  final String studentUserId;

  @override
  List<Object?> get props => [id, personalUserId, studentUserId];
}
