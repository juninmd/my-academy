// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'method_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(methodRepository)
final methodRepositoryProvider = MethodRepositoryProvider._();

final class MethodRepositoryProvider
    extends
        $FunctionalProvider<
          MethodRepository,
          MethodRepository,
          MethodRepository
        >
    with $Provider<MethodRepository> {
  MethodRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'methodRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$methodRepositoryHash();

  @$internal
  @override
  $ProviderElement<MethodRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MethodRepository create(Ref ref) {
    return methodRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MethodRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MethodRepository>(value),
    );
  }
}

String _$methodRepositoryHash() => r'74fb0741036f432dbb70df040de39b50edee448b';

@ProviderFor(methods)
final methodsProvider = MethodsProvider._();

final class MethodsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MethodEntity>>,
          List<MethodEntity>,
          FutureOr<List<MethodEntity>>
        >
    with
        $FutureModifier<List<MethodEntity>>,
        $FutureProvider<List<MethodEntity>> {
  MethodsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'methodsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$methodsHash();

  @$internal
  @override
  $FutureProviderElement<List<MethodEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MethodEntity>> create(Ref ref) {
    return methods(ref);
  }
}

String _$methodsHash() => r'6fe226d015d6e6c47df8caa1292c97c1dfdcc867';

@ProviderFor(method)
final methodProvider = MethodFamily._();

final class MethodProvider
    extends
        $FunctionalProvider<
          AsyncValue<MethodEntity?>,
          MethodEntity?,
          FutureOr<MethodEntity?>
        >
    with $FutureModifier<MethodEntity?>, $FutureProvider<MethodEntity?> {
  MethodProvider._({
    required MethodFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'methodProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$methodHash();

  @override
  String toString() {
    return r'methodProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MethodEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MethodEntity?> create(Ref ref) {
    final argument = this.argument as int;
    return method(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MethodProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$methodHash() => r'6f96ee3183e6945411c0a26221167b91d36cdef3';

final class MethodFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MethodEntity?>, int> {
  MethodFamily._()
    : super(
        retry: null,
        name: r'methodProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MethodProvider call(int id) => MethodProvider._(argument: id, from: this);

  @override
  String toString() => r'methodProvider';
}
