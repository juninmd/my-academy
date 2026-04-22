import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/failure.dart';
import '../entities/personal_entity.dart';

abstract class PersonalRepository {
  Future<Either<Failure, List<PersonalEntity>>> getPersonals({String? personalUserId});
  Future<Either<Failure, PersonalEntity>> createPersonal(PersonalEntity personal);
  Future<Either<Failure, PersonalEntity>> updatePersonal(PersonalEntity personal);
  Future<Either<Failure, Unit>> deletePersonal(int id);
}
