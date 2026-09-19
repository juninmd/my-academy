// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studentRepository)
final studentRepositoryProvider = StudentRepositoryProvider._();

final class StudentRepositoryProvider
    extends
        $FunctionalProvider<
          StudentRepository,
          StudentRepository,
          StudentRepository
        >
    with $Provider<StudentRepository> {
  StudentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studentRepositoryHash();

  @$internal
  @override
  $ProviderElement<StudentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StudentRepository create(Ref ref) {
    return studentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudentRepository>(value),
    );
  }
}

String _$studentRepositoryHash() => r'01c5017ed386d4c661ac330b89dc8593b2921a6e';

@ProviderFor(students)
final studentsProvider = StudentsFamily._();

final class StudentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StudentEntity>>,
          List<StudentEntity>,
          FutureOr<List<StudentEntity>>
        >
    with
        $FutureModifier<List<StudentEntity>>,
        $FutureProvider<List<StudentEntity>> {
  StudentsProvider._({
    required StudentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'studentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studentsHash();

  @override
  String toString() {
    return r'studentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<StudentEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StudentEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return students(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studentsHash() => r'27205af2e7035f0b457c251f40cfdb55be0ecc65';

final class StudentsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<StudentEntity>>, String> {
  StudentsFamily._()
    : super(
        retry: null,
        name: r'studentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudentsProvider call(String userId) =>
      StudentsProvider._(argument: userId, from: this);

  @override
  String toString() => r'studentsProvider';
}

@ProviderFor(isPersonal)
final isPersonalProvider = IsPersonalFamily._();

final class IsPersonalProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  IsPersonalProvider._({
    required IsPersonalFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isPersonalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isPersonalHash();

  @override
  String toString() {
    return r'isPersonalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isPersonal(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsPersonalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isPersonalHash() => r'0055e1b934181f1380d7284ba9836ece464ec943';

final class IsPersonalFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  IsPersonalFamily._()
    : super(
        retry: null,
        name: r'isPersonalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsPersonalProvider call(String userId) =>
      IsPersonalProvider._(argument: userId, from: this);

  @override
  String toString() => r'isPersonalProvider';
}
