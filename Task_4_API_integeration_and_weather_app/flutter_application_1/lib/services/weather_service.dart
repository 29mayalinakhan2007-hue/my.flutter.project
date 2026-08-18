import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

/// Thrown for any known, user-facing failure so the UI can show a
/// clear, specific message instead of a generic crash screen.
class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);

  @override
  String toString() => message;
}

/// Talks to Open-Meteo — free, no API key, no rate-limit sign-up.
/// Two endpoints are used: geocoding (name -> coordinates) and
/// forecast (coordinates -> current/hourly/daily weather).
class WeatherService {
  static const _geoBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const _weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const _timeout = Duration(seconds: 10);

  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Returns up to [count] geocoding matches for [query]. Used both for
  /// direct search and for disambiguating cities that share a name.
  Future<List<GeoResult>> searchCities(String query, {int count = 5}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      throw WeatherException('Please enter a city name.');
    }

    final uri = Uri.parse(_geoBaseUrl).replace(queryParameters: {
      'name': trimmed,
      'count': count.toString(),
      'language': 'en',
      'format': 'json',
    });

    final response = await _guardedGet(uri, serviceName: 'Location search');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>?;

    if (results == null || results.isEmpty) {
      throw WeatherException(
          'Could not find "$trimmed". Check the spelling and try again.');
    }

    return results
        .cast<Map<String, dynamic>>()
        .map(GeoResult.fromJson)
        .toList();
  }

  /// Fetches current + hourly + daily weather for a resolved location.
  Future<Weather> fetchWeather({
    required double latitude,
    required double longitude,
    required String cityLabel,
  }) async {
    final uri = Uri.parse(_weatherBaseUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,'
          'weather_code,wind_speed_10m,is_day',
      'hourly': 'temperature_2m,weather_code,is_day',
      'daily': 'temperature_2m_max,temperature_2m_min,weather_code,sunrise,sunset',
      'timezone': 'auto',
      'forecast_days': '7',
    });

    final response = await _guardedGet(uri, serviceName: 'Weather service');
    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json['current'] == null) {
      throw WeatherException('Unexpected response from the weather service.');
    }

    return Weather.fromJson(json, cityLabel);
  }

  /// Convenience: geocode by name, then fetch weather for the top match.
  /// Only used when the caller has already resolved ambiguity elsewhere
  /// (e.g. a saved "recent city" search).
  Future<Weather> fetchWeatherByCityName(String cityName) async {
    final matches = await searchCities(cityName, count: 1);
    final top = matches.first;
    return fetchWeather(
      latitude: top.latitude,
      longitude: top.longitude,
      cityLabel: top.label,
    );
  }

  Future<http.Response> _guardedGet(Uri uri, {required String serviceName}) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 429) {
        throw WeatherException(
            '$serviceName is busy right now. Please try again in a moment.');
      }
      if (response.statusCode >= 500) {
        throw WeatherException('$serviceName is temporarily unavailable.');
      }
      if (response.statusCode != 200) {
        throw WeatherException(
            '$serviceName returned an unexpected error (${response.statusCode}).');
      }
      return response;
    } on SocketException {
      throw WeatherException(
          'No internet connection. Check your network and try again.');
    } on HttpException {
      throw WeatherException('Could not reach the $serviceName.');
    } on FormatException {
      throw WeatherException('Received an invalid response. Please try again.');
    } on WeatherException {
      rethrow;
    } catch (e) {
      // Covers TimeoutException and anything unforeseen.
      final msg = e.toString().toLowerCase();
      if (msg.contains('timeout')) {
        throw WeatherException('The request timed out. Please try again.');
      }
      throw WeatherException('Something went wrong. Please try again.');
    }
  }

  void dispose() => _client.close();
}
