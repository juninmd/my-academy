// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gymRepository)
final gymRepositoryProvider = GymRepositoryProvider._();

final class GymRepositoryProvider
    extends $FunctionalProvider<GymRepository, GymRepository, GymRepository>
    with $Provider<GymRepository> {
  GymRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gymRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gymRepositoryHash();

  @$internal
  @override
  $ProviderElement<GymRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GymRepository create(Ref ref) {
    return gymRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GymRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GymRepository>(value),
    );
  }
}

String _$gymRepositoryHash() => r'97450e1e43546427ee123168e642905118bda3c3';

@ProviderFor(myGyms)
final myGymsProvider = MyGymsProvider._();

final class MyGymsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GymEntity>>,
          List<GymEntity>,
          FutureOr<List<GymEntity>>
        >
    with $FutureModifier<List<GymEntity>>, $FutureProvider<List<GymEntity>> {
  MyGymsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myGymsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myGymsHash();

  @$internal
  @override
  $FutureProviderElement<List<GymEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GymEntity>> create(Ref ref) {
    return myGyms(ref);
  }
}

String _$myGymsHash() => r'2a37e5eec5b4f1486e0609209d84777aef11068f';

@ProviderFor(gymDashboard)
final gymDashboardProvider = GymDashboardFamily._();

final class GymDashboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<GymDashboardEntity>,
          GymDashboardEntity,
          FutureOr<GymDashboardEntity>
        >
    with
        $FutureModifier<GymDashboardEntity>,
        $FutureProvider<GymDashboardEntity> {
  GymDashboardProvider._({
    required GymDashboardFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'gymDashboardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gymDashboardHash();

  @override
  String toString() {
    return r'gymDashboardProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<GymDashboardEntity> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GymDashboardEntity> create(Ref ref) {
    final argument = this.argument as int;
    return gymDashboard(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GymDashboardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gymDashboardHash() => r'78de77ada782b4957cf6b963e4bbc095a5bda687';

final class GymDashboardFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<GymDashboardEntity>, int> {
  GymDashboardFamily._()
    : super(
        retry: null,
        name: r'gymDashboardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GymDashboardProvider call(int gymId) =>
      GymDashboardProvider._(argument: gymId, from: this);

  @override
  String toString() => r'gymDashboardProvider';
}

@ProviderFor(gymMembers)
final gymMembersProvider = GymMembersFamily._();

final class GymMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MemberEntity>>,
          List<MemberEntity>,
          FutureOr<List<MemberEntity>>
        >
    with
        $FutureModifier<List<MemberEntity>>,
        $FutureProvider<List<MemberEntity>> {
  GymMembersProvider._({
    required GymMembersFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'gymMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gymMembersHash();

  @override
  String toString() {
    return r'gymMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<MemberEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MemberEntity>> create(Ref ref) {
    final argument = this.argument as int;
    return gymMembers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GymMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gymMembersHash() => r'902cd30fb1100239aed138b1e6b5c282b404459f';

final class GymMembersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<MemberEntity>>, int> {
  GymMembersFamily._()
    : super(
        retry: null,
        name: r'gymMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GymMembersProvider call(int gymId) =>
      GymMembersProvider._(argument: gymId, from: this);

  @override
  String toString() => r'gymMembersProvider';
}

@ProviderFor(gymPayments)
final gymPaymentsProvider = GymPaymentsFamily._();

final class GymPaymentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentEntity>>,
          List<PaymentEntity>,
          FutureOr<List<PaymentEntity>>
        >
    with
        $FutureModifier<List<PaymentEntity>>,
        $FutureProvider<List<PaymentEntity>> {
  GymPaymentsProvider._({
    required GymPaymentsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'gymPaymentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gymPaymentsHash();

  @override
  String toString() {
    return r'gymPaymentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PaymentEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentEntity>> create(Ref ref) {
    final argument = this.argument as int;
    return gymPayments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GymPaymentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gymPaymentsHash() => r'633053305512987e29c07995cd1e9319296c7eb7';

final class GymPaymentsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PaymentEntity>>, int> {
  GymPaymentsFamily._()
    : super(
        retry: null,
        name: r'gymPaymentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GymPaymentsProvider call(int gymId) =>
      GymPaymentsProvider._(argument: gymId, from: this);

  @override
  String toString() => r'gymPaymentsProvider';
}

@ProviderFor(myMemberships)
final myMembershipsProvider = MyMembershipsProvider._();

final class MyMembershipsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MembershipEntity>>,
          List<MembershipEntity>,
          FutureOr<List<MembershipEntity>>
        >
    with
        $FutureModifier<List<MembershipEntity>>,
        $FutureProvider<List<MembershipEntity>> {
  MyMembershipsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myMembershipsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myMembershipsHash();

  @$internal
  @override
  $FutureProviderElement<List<MembershipEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MembershipEntity>> create(Ref ref) {
    return myMemberships(ref);
  }
}

String _$myMembershipsHash() => r'91fcecc88138f997d25b8d5c614fa17044996b46';
