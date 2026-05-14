import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _lastSyncKey = 'last_sync';
  static const String _offlineModeKey = 'offline_mode';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme Settings
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_themeKey, mode);
  }

  String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'light';
  }

  // Language Settings
  Future<void> setLanguage(String language) async {
    await _prefs.setString(_languageKey, language);
  }

  String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'en';
  }

  // Sync Timestamp
  Future<void> setLastSync(DateTime dateTime) async {
    await _prefs.setString(_lastSyncKey, dateTime.toIso8601String());
  }

  DateTime? getLastSync() {
    final lastSync = _prefs.getString(_lastSyncKey);
    if (lastSync != null) {
      return DateTime.tryParse(lastSync);
    }
    return null;
  }

  // Offline Mode
  Future<void> setOfflineModeEnabled(bool enabled) async {
    await _prefs.setBool(_offlineModeKey, enabled);
  }

  bool isOfflineModeEnabled() {
    return _prefs.getBool(_offlineModeKey) ?? false;
  }

  // Clear all preferences
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Generic getter/setter for custom values
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
