import 'package:logger/logger.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_dto.dart';
import 'auth_remote_data_source.dart';

final logger = Logger();

/// Mock implementation for testing without real Firebase/Google auth
class MockAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  MockAuthRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;
  final ApiClient _apiClient;

  static const _mockUserId = 'db6i035Vjtb77a7cBDnXQVPd3oL2';
  static const _mockToken = 'mock-token-for-testing';

  @override
  Future<UserDto> signInWithGoogle() async {
    logger.i(
      '[MockAuthRemoteDataSource] signInWithGoogle() called - using MOCK auth',
    );
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network

    _apiClient.setAuthToken(_mockToken);

    logger.i(
      '[MockAuthRemoteDataSource] Mock user signed in: mock@example.com',
    );
    return const UserDto(
      id: _mockUserId,
      email: 'mock@example.com',
      name: 'Mock User',
      photoUrl: 'https://i.pravatar.cc/150?u=$_mockUserId',
    );
  }

  @override
  Future<void> signOut() async {
    logger.i('[MockAuthRemoteDataSource] signOut() called');
    await Future.delayed(const Duration(milliseconds: 200));
    _apiClient.clearAuthToken();
  }

  @override
  Future<UserDto?> getCurrentUser() async {
    // For mock auth, always return the mock user
    logger.i(
      '[MockAuthRemoteDataSource] getCurrentUser() called - returning mock user',
    );
    return const UserDto(
      id: _mockUserId,
      email: 'mock@example.com',
      name: 'Mock User',
      photoUrl: 'https://i.pravatar.cc/150?u=$_mockUserId',
    );
  }

  @override
  Future<String> getAuthToken() async {
    logger.i(
      '[MockAuthRemoteDataSource] getAuthToken() called - returning mock token',
    );
    return _mockToken;
  }
}
