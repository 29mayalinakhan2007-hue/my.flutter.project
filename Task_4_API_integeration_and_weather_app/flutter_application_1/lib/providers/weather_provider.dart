import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

enum LoadStatus { idle, loading, success, error }

/// Single source of truth for the home screen. Keeps the current
/// weather, unit preference, recent-search history, and load state,
/// and exposes intention-revealing methods (searchCities, selectCity,
/// refresh, toggleUnit) rather than leaking API/storage details to
/// the UI layer.
class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService;
  final StorageService _storageService;

  WeatherProvider({
    WeatherService? weatherService,
    StorageService? storageService,
  })  : _weatherService = weatherService ?? WeatherService(),
        _storageService = storageService ?? StorageService();

  LoadStatus status = LoadStatus.idle;
  Weather? weather;
  String errorMessage = '';
  bool useCelsius = true;
  List<String> recentCities = [];

  // Set only while a disambiguation search is in flight / has results.
  List<GeoResult> searchResults = [];
  bool isSearching = false;
  String searchError = '';

  Future<void> init() async {
    useCelsius = await _storageService.getUseCelsius();
    recentCities = await _storageService.getRecentCities();

    final last = await _storageService.getLastCity();
    if (last != null) {
      final (label, lat, lon) = last;
      await _loadWeather(latitude: lat, longitude: lon, cityLabel: label);
    } else {
      // Sensible first-run default so the screen never opens empty.
      await selectCityByName('Islamabad');
    }
  }

  Future<void> selectCityByName(String name) async {
    status = LoadStatus.loading;
    errorMessage = '';
    notifyListeners();

    try {
      final matches = await _weatherService.searchCities(name.trim(), count: 1);
      final top = matches.first;
      await _loadWeather(
        latitude: top.latitude,
        longitude: top.longitude,
        cityLabel: top.label,
      );
    } on WeatherException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
      notifyListeners();
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      status = LoadStatus.error;
      notifyListeners();
    }
  }

  Future<void> selectCity(GeoResult city) async {
    searchResults = [];
    await _loadWeather(
      latitude: city.latitude,
      longitude: city.longitude,
      cityLabel: city.label,
    );
  }

  /// Runs a live search for the search sheet. On a single confident
  /// match this still requires the user to tap it — Atmos never
  /// silently swaps the city the user is looking at.
  Future<void> searchCities(String query) async {
    if (query.trim().isEmpty) {
      searchResults = [];
      searchError = '';
      notifyListeners();
      return;
    }

    isSearching = true;
    searchError = '';
    notifyListeners();

    try {
      searchResults = await _weatherService.searchCities(query, count: 6);
    } on WeatherException catch (e) {
      searchResults = [];
      searchError = e.message;
    } catch (_) {
      searchResults = [];
      searchError = 'Search failed. Please try again.';
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final current = weather;
    if (current == null) return;
    // Re-resolve coordinates isn't necessary — we already have a fixed
    // location; just re-fetch weather for it without a loading flash
    // (RefreshIndicator provides its own spinner).
    try {
      final refreshed = await _weatherService.fetchWeatherByCityName(current.cityLabel);
      weather = refreshed;
      status = LoadStatus.success;
      notifyListeners();
    } on WeatherException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
      notifyListeners();
    } catch (_) {
      // Keep showing the last good data if a background refresh fails.
    }
  }

  Future<void> toggleUnit() async {
    useCelsius = !useCelsius;
    await _storageService.setUseCelsius(useCelsius);
    notifyListeners();
  }

  double displayTemp(double celsius) =>
      useCelsius ? celsius : (celsius * 9 / 5) + 32;

  String get unitSuffix => useCelsius ? '°C' : '°F';

  Future<void> _loadWeather({
    required double latitude,
    required double longitude,
    required String cityLabel,
  }) async {
    status = LoadStatus.loading;
    errorMessage = '';
    notifyListeners();

    try {
      final result = await _weatherService.fetchWeather(
        latitude: latitude,
        longitude: longitude,
        cityLabel: cityLabel,
      );
      weather = result;
      status = LoadStatus.success;

      await _storageService.saveLastCity(cityLabel, latitude, longitude);
      await _storageService.addRecentCity(cityLabel);
      recentCities = await _storageService.getRecentCities();
    } on WeatherException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }
}
