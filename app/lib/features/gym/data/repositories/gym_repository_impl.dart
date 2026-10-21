import 'package:dartz/dartz.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/gym_entities.dart';
import '../../domain/repositories/gym_repository.dart';
import '../models/gym_json.dart';

class GymRepositoryImpl implements GymRepository {
  GymRepositoryImpl(this._api);
  final ApiClient _api;

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  List<T> _list<T>(Object? data, T Function(Json) parse) => [
    for (final item in data as List) parse(item as Json),
  ];

  @override
  Future<Either<Failure, List<GymEntity>>> getMyGyms() =>
      _guard(() async => _list(await _api.get('gyms/mine'), gymFromJson));

  @override
  Future<Either<Failure, GymEntity>> createGym(String name, String? address) =>
      _guard(() async {
        // ignore: use_null_aware_elements
        final body = {'name': name, if (address != null) 'address': address};
        return gymFromJson(await _api.post('gyms', data: body) as Json);
      });

  @override
  Future<Either<Failure, GymDashboardEntity>> getDashboard(int gymId) => _guard(
    () async =>
        dashboardFromJson(await _api.get('gyms/$gymId/dashboard') as Json),
  );

  @override
  Future<Either<Failure, PlanEntity>> createPlan(
    int gymId,
    String name,
    double price,
    int durationMonths,
  ) => _guard(() async {
        // ignore: use_null_aware_elements
    final body = {
      'name': name,
      'price': price,
      'durationMonths': durationMonths,
    };
    return planFromJson(
      await _api.post('gyms/$gymId/plans', data: body) as Json,
    );
  });

  @override
  Future<Either<Failure, List<MemberEntity>>> getMembers(int gymId) => _guard(
    () async => _list(
      await _api.get(
        'gyms/$gymId/subscriptions',
        queryParameters: {'take': 100},
      ),
      memberFromJson,
    ),
  );

  @override
  Future<Either<Failure, Unit>> enroll(int gymId, String email, int planId) =>
      _guard(() async {
        await _api.post(
          'gyms/$gymId/subscriptions',
          data: {'email': email, 'planId': planId},
        );
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> setMemberStatus(int gymId, int id, String s) =>
      _guard(() async {
        await _api.patch('gyms/$gymId/subscriptions/$id', data: {'status': s});
        return unit;
      });

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPayments(int gymId) => _guard(
    () async => _list(
      await _api.get('gyms/$gymId/payments', queryParameters: {'take': 100}),
      paymentFromJson,
    ),
  );

  @override
  Future<Either<Failure, Unit>> setPaymentStatus(int gymId, int id, String s) =>
      _guard(() async {
        await _api.patch('gyms/$gymId/payments/$id', data: {'status': s});
        return unit;
      });

  @override
  Future<Either<Failure, List<MembershipEntity>>> getMyMemberships() => _guard(
    () async =>
        _list(await _api.get('gyms/subscriptions/me'), membershipFromJson),
  );
}
