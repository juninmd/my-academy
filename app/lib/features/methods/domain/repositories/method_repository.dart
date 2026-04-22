import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/failure.dart';
import '../entities/method_entity.dart';

abstract class MethodRepository {
  Future<Either<Failure, List<MethodEntity>>> getMethods();
  Future<Either<Failure, MethodEntity>> getMethod(int id);
  Future<Either<Failure, MethodEntity>> createMethod(MethodEntity method);
  Future<Either<Failure, MethodEntity>> updateMethod(MethodEntity method);
  Future<Either<Failure, Unit>> deleteMethod(int id);
}
