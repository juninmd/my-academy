import 'package:dartz/dartz.dart';

import '../../../../core/exceptions/failure.dart';
import '../entities/gym_entities.dart';

abstract class GymRepository {
  Future<Either<Failure, List<GymEntity>>> getMyGyms();
  Future<Either<Failure, GymEntity>> createGym(String name, String? address);
  Future<Either<Failure, GymDashboardEntity>> getDashboard(int gymId);
  Future<Either<Failure, PlanEntity>> createPlan(
    int gymId,
    String name,
    double price,
    int durationMonths,
  );
  Future<Either<Failure, List<MemberEntity>>> getMembers(int gymId);
  Future<Either<Failure, Unit>> enroll(int gymId, String email, int planId);
  Future<Either<Failure, Unit>> setMemberStatus(int gymId, int id, String s);
  Future<Either<Failure, List<PaymentEntity>>> getPayments(int gymId);
  Future<Either<Failure, Unit>> setPaymentStatus(int gymId, int id, String s);
  Future<Either<Failure, List<MembershipEntity>>> getMyMemberships();
}
