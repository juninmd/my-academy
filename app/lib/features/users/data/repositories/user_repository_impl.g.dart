// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userRepository)
final userRepositoryProvider = UserRepositoryProvider._();

final class UserRepositoryProvider
    extends $FunctionalProvider<UserRepository, UserRepository, UserRepository>
    with $Provider<UserRepository> {
  UserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserRepository create(Ref ref) {
    return userRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRepository>(value),
    );
  }
}

String _$userRepositoryHash() => r'7e2cb0a75fa87cafdfe9a8314a47948b4553360f';

@ProviderFor(users)
final usersProvider = UsersFamily._();

final class UsersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserEntity>>,
          List<UserEntity>,
          FutureOr<List<UserEntity>>
        >
    with $FutureModifier<List<UserEntity>>, $FutureProvider<List<UserEntity>> {
  UsersProvider._({
    required UsersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'usersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$usersHash();

  @override
  String toString() {
    return r'usersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<UserEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return users(ref, email: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UsersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$usersHash() => r'990df60807821a16659b3b4f25667302ecdd7148';

final class UsersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<UserEntity>>, String> {
  UsersFamily._()
    : super(
        retry: null,
        name: r'usersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UsersProvider call({required String email}) =>
      UsersProvider._(argument: email, from: this);

  @override
  String toString() => r'usersProvider';
}

@ProviderFor(user)
final userProvider = UserFamily._();

final class UserProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserEntity?>,
          UserEntity?,
          FutureOr<UserEntity?>
        >
    with $FutureModifier<UserEntity?>, $FutureProvider<UserEntity?> {
  UserProvider._({
    required UserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userHash();

  @override
  String toString() {
    return r'userProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<UserEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserEntity?> create(Ref ref) {
    final argument = this.argument as String;
    return user(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userHash() => r'0f99812051c717c0de5c38cb655a9eed08d299ab';

final class UserFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<UserEntity?>, String> {
  UserFamily._()
    : super(
        retry: null,
        name: r'userProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserProvider call(String id) => UserProvider._(argument: id, from: this);

  @override
  String toString() => r'userProvider';
}
