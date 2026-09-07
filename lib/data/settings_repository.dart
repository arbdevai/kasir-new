import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Persists user-editable store and printer settings locally.
///
/// The repository accepts an injected [SharedPreferences] instance so callers
/// can initialize it once at startup and tests can use an in-memory instance.
class SettingsRepository {
  static const String _storeProfileKey = 'settings.store_profile';
  static const String _printerSettingsKey = 'settings.printer';

  final SharedPreferences _preferences;

  const SettingsRepository(this._preferences);

  StoreProfile loadStoreProfile() {
    final map = _readMap(_storeProfileKey);
    return map == null ? const StoreProfile() : StoreProfile.fromMap(map);
  }

  PrinterSettings loadPrinterSettings() {
    final map = _readMap(_printerSettingsKey);
    return map == null ? const PrinterSettings() : PrinterSettings.fromMap(map);
  }

  Future<bool> saveStoreProfile(StoreProfile profile) {
    return _writeMap(_storeProfileKey, profile.toMap());
  }

  Future<bool> savePrinterSettings(PrinterSettings settings) {
    return _writeMap(_printerSettingsKey, settings.toMap());
  }

  /// Removes all user-editable settings so the application falls back to its
  /// model defaults on the next read.
  Future<bool> clear() async {
    final storeCleared = await _preferences.remove(_storeProfileKey);
    final printerCleared = await _preferences.remove(_printerSettingsKey);
    return storeCleared && printerCleared;
  }

  Map<String, dynamic>? _readMap(String key) {
    final raw = _preferences.getString(key);
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } on FormatException {
      // Treat malformed persisted settings as missing and use defaults.
    }
    return null;
  }

  Future<bool> _writeMap(String key, Map<String, dynamic> value) {
    return _preferences.setString(key, jsonEncode(value));
  }
}
