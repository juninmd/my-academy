import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

part 'onboarding_provider.g.dart';

/// Onboarding completion is stored on the backend (so a new device skips it)
/// and cached per user locally (so it also works offline).
@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  static const String _onboardingKey = 'onboarding_completed';

  String get _key {
    final userId = ref.read(authNotifierProvider).value?.id;
    return userId == null ? _onboardingKey : '${_onboardingKey}_$userId';
  }

  @override
  FutureOr<bool> build() async {
    final user = ref.watch(authNotifierProvider).value;
    if (user?.onboarded ?? false) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = const AsyncValue.data(true);
    final userId = ref.read(authNotifierProvider).value?.id;
    if (userId == null) return;
    try {
      await ref.read(userProfileSyncProvider).markOnboarded(userId);
    } on Failure catch (e) {
      // Local flag still applies; the next device will ask again.
      logger.w('Onboarding not saved on the server: ${e.message}');
    }
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = const AsyncValue.data(false);
  }
}
