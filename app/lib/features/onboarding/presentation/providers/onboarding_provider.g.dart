// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Onboarding completion is tracked per user so switching accounts on the
/// same device does not skip (or repeat) another user's setup.

@ProviderFor(OnboardingNotifier)
final onboardingProvider = OnboardingNotifierProvider._();

/// Onboarding completion is tracked per user so switching accounts on the
/// same device does not skip (or repeat) another user's setup.
final class OnboardingNotifierProvider
    extends $AsyncNotifierProvider<OnboardingNotifier, bool> {
  /// Onboarding completion is tracked per user so switching accounts on the
  /// same device does not skip (or repeat) another user's setup.
  OnboardingNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingNotifierHash();

  @$internal
  @override
  OnboardingNotifier create() => OnboardingNotifier();
}

String _$onboardingNotifierHash() =>
    r'd434fc8e2679b99950c4ceab6a86a1cd33ecd777';

/// Onboarding completion is tracked per user so switching accounts on the
/// same device does not skip (or repeat) another user's setup.

abstract class _$OnboardingNotifier extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
