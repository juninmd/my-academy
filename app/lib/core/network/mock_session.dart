import '../../utils/constants.dart';

/// Identity used by homologation builds (USE_MOCK_AUTH); the API resolves
/// `mock-token:<uid>` to the matching persona from AUTH_MOC_JSON.
class MockSession {
  static String? uid;

  static String get token =>
      uid == null ? mockAuthToken : '$mockAuthToken:$uid';
}
