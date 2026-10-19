// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Onboarding completion is stored on the backend (so a new device skips it)
/// and cached per user locally (so it also works offline).

@ProviderFor(OnboardingNotifier)
final onboardingProvider = OnboardingNotifierProvider._();

/// Onboarding completion is stored on the backend (so a new device skips it)
/// and cached per user locally (so it also works offline).
final class OnboardingNotifierProvider
    extends $AsyncNotifierProvider<OnboardingNotifier, bool> {
  /// Onboarding completion is stored on the backend (so a new device skips it)
  /// and cached per user locally (so it also works offline).
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
    r'27055fda501694cef2ceb2a3b319b202ced54e45';

/// Onboarding completion is stored on the backend (so a new device skips it)
/// and cached per user locally (so it also works offline).

abstract class _$OnboardingNotifier extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
