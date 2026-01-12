import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

/// Service for managing local cache to track app usage and training status.
/// Used to determine if the user should receive training reminder notifications.
class CacheService {
  static const String _keyLastOpenDate = 'last_open_date';
  static const String _keyLastTrainingDate = 'last_training_date';

  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;

  /// Initializes the cache service. Must be called before using other methods.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String _getTodayString() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// Checks if the user has opened the app today.
  bool hasOpenedToday() {
    final lastOpenDate = _prefs?.getString(_keyLastOpenDate);
    return lastOpenDate == _getTodayString();
  }

  /// Marks that the user has opened the app today.
  Future<void> markAppOpened() async {
    await _prefs?.setString(_keyLastOpenDate, _getTodayString());
  }

  /// Checks if the user has completed training today.
  bool hasTrainedToday() {
    final lastTrainingDate = _prefs?.getString(_keyLastTrainingDate);
    return lastTrainingDate == _getTodayString();
  }

  /// Marks that the user has completed training today.
  Future<void> markTrainingCompleted() async {
    await _prefs?.setString(_keyLastTrainingDate, _getTodayString());
  }

  /// Clears all cached data (useful for logout).
  Future<void> clearAll() async {
    await _prefs?.remove(_keyLastOpenDate);
    await _prefs?.remove(_keyLastTrainingDate);
  }
}
