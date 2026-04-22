// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(personalRepository)
final personalRepositoryProvider = PersonalRepositoryProvider._();

final class PersonalRepositoryProvider
    extends
        $FunctionalProvider<
          PersonalRepository,
          PersonalRepository,
          PersonalRepository
        >
    with $Provider<PersonalRepository> {
  PersonalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personalRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personalRepositoryHash();

  @$internal
  @override
  $ProviderElement<PersonalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PersonalRepository create(Ref ref) {
    return personalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PersonalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PersonalRepository>(value),
    );
  }
}

String _$personalRepositoryHash() =>
    r'e6f6f14cb40ee90cff86254b2c630bebde7251d1';

@ProviderFor(personals)
final personalsProvider = PersonalsFamily._();

final class PersonalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PersonalEntity>>,
          List<PersonalEntity>,
          FutureOr<List<PersonalEntity>>
        >
    with
        $FutureModifier<List<PersonalEntity>>,
        $FutureProvider<List<PersonalEntity>> {
  PersonalsProvider._({
    required PersonalsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'personalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$personalsHash();

  @override
  String toString() {
    return r'personalsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PersonalEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PersonalEntity>> create(Ref ref) {
    final argument = this.argument as String?;
    return personals(ref, personalUserId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PersonalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$personalsHash() => r'1eb490fe6a4eda4769a06e3fafd773df8984efb1';

final class PersonalsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PersonalEntity>>, String?> {
  PersonalsFamily._()
    : super(
        retry: null,
        name: r'personalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PersonalsProvider call({String? personalUserId}) =>
      PersonalsProvider._(argument: personalUserId, from: this);

  @override
  String toString() => r'personalsProvider';
}
