import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/repositories/gym_repository_impl.dart';
import '../../domain/entities/gym_entities.dart';
import '../../domain/repositories/gym_repository.dart';

part 'gym_providers.g.dart';

@riverpod
GymRepository gymRepository(Ref ref) =>
    GymRepositoryImpl(ref.watch(apiClientProvider));

/// Failures surface as AsyncError so pages can show error + retry.
Future<T> _unwrap<T>(Future<Either<Failure, T>> result) async =>
    (await result).fold((f) => throw f, (r) => r);

@riverpod
Future<List<GymEntity>> myGyms(Ref ref) =>
    _unwrap(ref.watch(gymRepositoryProvider).getMyGyms());

@riverpod
Future<GymDashboardEntity> gymDashboard(Ref ref, int gymId) =>
    _unwrap(ref.watch(gymRepositoryProvider).getDashboard(gymId));

@riverpod
Future<List<MemberEntity>> gymMembers(Ref ref, int gymId) =>
    _unwrap(ref.watch(gymRepositoryProvider).getMembers(gymId));

@riverpod
Future<List<PaymentEntity>> gymPayments(Ref ref, int gymId) =>
    _unwrap(ref.watch(gymRepositoryProvider).getPayments(gymId));

@riverpod
Future<List<MembershipEntity>> myMemberships(Ref ref) =>
    _unwrap(ref.watch(gymRepositoryProvider).getMyMemberships());
