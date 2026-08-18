import 'package:flutter_test/flutter_test.dart';
import 'package:atmos_weather/core/weather_theme.dart';
import 'package:atmos_weather/models/weather_model.dart';

void main() {
  group('WeatherTheme.moodFromCode', () {
    test('clear sky maps to clearDay when isDay is true', () {
      expect(WeatherTheme.moodFromCode(0, isDay: true), SkyMood.clearDay);
    });

    test('clear sky maps to clearNight when isDay is false', () {
      expect(WeatherTheme.moodFromCode(0, isDay: false), SkyMood.clearNight);
    });

    test('thunderstorm codes map to storm regardless of time of day', () {
      expect(WeatherTheme.moodFromCode(95, isDay: true), SkyMood.storm);
      expect(WeatherTheme.moodFromCode(99, isDay: false), SkyMood.storm);
    });

    test('snow codes map to snow', () {
      expect(WeatherTheme.moodFromCode(71, isDay: true), SkyMood.snow);
      expect(WeatherTheme.moodFromCode(86, isDay: true), SkyMood.snow);
    });

    test('rain codes map to rain', () {
      expect(WeatherTheme.moodFromCode(61, isDay: true), SkyMood.rain);
      expect(WeatherTheme.moodFromCode(80, isDay: true), SkyMood.rain);
    });
  });

  group('Weather.fromJson', () {
    test('parses current, hourly, and daily blocks correctly', () {
      final json = {
        'current': {
          'time': '2026-08-17T10:00',
          'temperature_2m': 28.4,
          'apparent_temperature': 30.1,
          'relative_humidity_2m': 55,
          'wind_speed_10m': 12.3,
          'weather_code': 1,
          'is_day': 1,
        },
        'hourly': {
          'time': [
            '2026-08-17T10:00',
            '2026-08-17T11:00',
            '2026-08-17T12:00',
          ],
          'temperature_2m': [28.4, 29.0, 29.6],
          'weather_code': [1, 1, 2],
          'is_day': [1, 1, 1],
        },
        'daily': {
          'time': ['2026-08-17'],
          'temperature_2m_max': [31.0],
          'temperature_2m_min': [22.0],
          'weather_code': [1],
          'sunrise': ['2026-08-17T05:45'],
          'sunset': ['2026-08-17T19:10'],
        },
      };

      final weather = Weather.fromJson(json, 'Islamabad, Pakistan');

      expect(weather.cityLabel, 'Islamabad, Pakistan');
      expect(weather.temperatureC, 28.4);
      expect(weather.humidity, 55);
      expect(weather.hourly.length, 3);
      expect(weather.daily.length, 1);
      expect(weather.daily.first.maxTempC, 31.0);
      expect(weather.sunrise, isNotNull);
    });
  });

  group('GeoResult', () {
    test('label joins name, admin1, and country', () {
      final geo = GeoResult(
        name: 'Cambridge',
        admin1: 'Massachusetts',
        country: 'United States',
        latitude: 42.37,
        longitude: -71.10,
      );
      expect(geo.label, 'Cambridge, Massachusetts, United States');
    });

    test('label skips a null admin1 gracefully', () {
      final geo = GeoResult(
        name: 'Singapore',
        admin1: null,
        country: 'Singapore',
        latitude: 1.35,
        longitude: 103.82,
      );
      expect(geo.label, 'Singapore, Singapore');
    });
  });
}
