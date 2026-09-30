import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/mock_session.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_dto.dart';
import 'auth_remote_data_source.dart';

/// Homologation personas; must match AUTH_MOC_JSON on the API (.env.docker).
const mockPersonas = <String, String>{
  'aluno@myacademy.dev': 'hml-student',
  'personal@myacademy.dev': 'hml-personal',
  'dono@myacademy.dev': 'hml-owner',
  'novo@myacademy.dev': 'hml-newbie',
};

/// Auth without Firebase for local homologation (USE_MOCK_AUTH builds only).
class MockAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  MockAuthRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;
  final ApiClient _apiClient;

  static const _uidKey = 'mock_auth_uid';
  static const _emailKey = 'mock_auth_email';

  @override
  Future<UserDto> signInWithGoogle() =>
      signInWithEmail(mockPersonas.keys.first, '');

  @override
  Future<UserDto> signInWithEmail(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    final uid = mockPersonas[normalized];
    if (uid == null) {
      throw AuthFailure(
        'Usuário de homologação desconhecido. Use: '
        '${mockPersonas.keys.join(', ')}',
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uidKey, uid);
    await prefs.setString(_emailKey, normalized);
    return await _activate(uid, normalized);
  }

  @override
  Future<UserDto> signUpWithEmail(
    String email,
    String password,
    String? role,
  ) async {
    final user = await signInWithEmail(email, password);
    return UserDto(id: user.id, email: user.email, name: user.name, role: role);
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_uidKey);
    await prefs.remove(_emailKey);
    MockSession.uid = null;
    _apiClient.clearAuthToken();
  }

  @override
  Future<UserDto?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_uidKey);
    final email = prefs.getString(_emailKey);
    if (uid == null || email == null) return null;
    return await _activate(uid, email);
  }

  @override
  Future<String> getAuthToken() async => MockSession.token;

  @override
  Future<void> updateDisplayName(String name) async {
    logger.i('[MockAuth] updateDisplayName($name) is a no-op');
  }

  Future<UserDto> _activate(String uid, String email) async {
    MockSession.uid = uid;
    _apiClient.setAuthToken(MockSession.token);
    final userDto = UserDto(id: uid, email: email, name: email.split('@').first);
    try {
      await _apiClient.post('users', data: userDto.toJson());
    } catch (e) {
      if (e is ServerFailure) {
        // ignore
      } else {
        logger.w('Failed to sync user with backend: $e');
      }
    }
    return userDto;
  }
}
