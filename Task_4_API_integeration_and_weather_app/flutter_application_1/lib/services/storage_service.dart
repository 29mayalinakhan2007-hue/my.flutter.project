import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences so the rest of the app never
/// talks to the plugin directly — makes it trivial to swap storage or
/// mock it in tests.
class StorageService {
  static const _recentCitiesKey = 'recent_cities';
  static const _lastCityKey = 'last_city_label';
  static const _lastLatKey = 'last_city_lat';
  static const _lastLonKey = 'last_city_lon';
  static const _unitKey = 'use_celsius';
  static const _maxRecent = 5;

  Future<List<String>> getRecentCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentCitiesKey) ?? [];
  }

  Future<void> addRecentCity(String label) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_recentCitiesKey) ?? [];
    current.remove(label);
    current.insert(0, label);
    if (current.length > _maxRecent) {
      current.removeRange(_maxRecent, current.length);
    }
    await prefs.setStringList(_recentCitiesKey, current);
  }

  Future<void> saveLastCity(String label, double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCityKey, label);
    await prefs.setDouble(_lastLatKey, lat);
    await prefs.setDouble(_lastLonKey, lon);
  }

  Future<(String, double, double)?> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final label = prefs.getString(_lastCityKey);
    final lat = prefs.getDouble(_lastLatKey);
    final lon = prefs.getDouble(_lastLonKey);
    if (label == null || lat == null || lon == null) return null;
    return (label, lat, lon);
  }

  Future<void> setUseCelsius(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_unitKey, value);
  }

  Future<bool> getUseCelsius() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_unitKey) ?? true;
  }
}
