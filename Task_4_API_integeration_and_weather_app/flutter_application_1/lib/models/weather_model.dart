/// A single geocoding match — used when a searched city name is
/// ambiguous (e.g. "Cambridge" exists in the UK and the US) so the
/// user can pick the right one instead of silently guessing.
class GeoResult {
  final String name;
  final String? admin1;
  final String country;
  final double latitude;
  final double longitude;

  GeoResult({
    required this.name,
    required this.admin1,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  String get label =>
      [name, admin1, country].where((e) => e != null && e.isNotEmpty).join(', ');

  factory GeoResult.fromJson(Map<String, dynamic> json) {
    return GeoResult(
      name: json['name'] as String,
      admin1: json['admin1'] as String?,
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperatureC;
  final int weatherCode;
  final bool isDay;

  HourlyForecast({
    required this.time,
    required this.temperatureC,
    required this.weatherCode,
    required this.isDay,
  });
}

class DailyForecast {
  final DateTime date;
  final double maxTempC;
  final double minTempC;
  final int weatherCode;

  DailyForecast({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.weatherCode,
  });
}

/// The full snapshot shown on screen: current conditions plus the
/// next 24 hours and next 7 days, all in Celsius internally — the UI
/// layer converts to Fahrenheit on demand so switching units never
/// needs a network round-trip.
class Weather {
  final String cityLabel;
  final double temperatureC;
  final double feelsLikeC;
  final int humidity;
  final double windKph;
  final int weatherCode;
  final bool isDay;
  final DateTime? sunrise;
  final DateTime? sunset;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  Weather({
    required this.cityLabel,
    required this.temperatureC,
    required this.feelsLikeC,
    required this.humidity,
    required this.windKph,
    required this.weatherCode,
    required this.isDay,
    required this.sunrise,
    required this.sunset,
    required this.hourly,
    required this.daily,
  });

  factory Weather.fromJson(Map<String, dynamic> json, String cityLabel) {
    final current = json['current'] as Map<String, dynamic>;
    final hourlyJson = json['hourly'] as Map<String, dynamic>?;
    final dailyJson = json['daily'] as Map<String, dynamic>?;

    final currentTime = DateTime.parse(current['time'] as String);

    List<HourlyForecast> hourlyList = [];
    if (hourlyJson != null) {
      final times = (hourlyJson['time'] as List).cast<String>();
      final temps = (hourlyJson['temperature_2m'] as List);
      final codes = (hourlyJson['weather_code'] as List);
      final isDayList = (hourlyJson['is_day'] as List?) ?? [];

      // Only keep the next 24 hours starting from the current hour.
      int startIndex = times.indexWhere(
        (t) => DateTime.parse(t).isAfter(currentTime.subtract(const Duration(minutes: 1))),
      );
      if (startIndex == -1) startIndex = 0;
      final endIndex = (startIndex + 24).clamp(0, times.length);

      for (int i = startIndex; i < endIndex; i++) {
        hourlyList.add(HourlyForecast(
          time: DateTime.parse(times[i]),
          temperatureC: (temps[i] as num).toDouble(),
          weatherCode: (codes[i] as num).toInt(),
          isDay: isDayList.isNotEmpty ? (isDayList[i] as num).toInt() == 1 : true,
        ));
      }
    }

    List<DailyForecast> dailyList = [];
    if (dailyJson != null) {
      final dates = (dailyJson['time'] as List).cast<String>();
      final maxTemps = (dailyJson['temperature_2m_max'] as List);
      final minTemps = (dailyJson['temperature_2m_min'] as List);
      final codes = (dailyJson['weather_code'] as List);

      for (int i = 0; i < dates.length; i++) {
        dailyList.add(DailyForecast(
          date: DateTime.parse(dates[i]),
          maxTempC: (maxTemps[i] as num).toDouble(),
          minTempC: (minTemps[i] as num).toDouble(),
          weatherCode: (codes[i] as num).toInt(),
        ));
      }
    }

    DateTime? sunrise;
    DateTime? sunset;
    if (dailyJson != null) {
      final sunriseList = dailyJson['sunrise'] as List?;
      final sunsetList = dailyJson['sunset'] as List?;
      if (sunriseList != null && sunriseList.isNotEmpty) {
        sunrise = DateTime.parse(sunriseList.first as String);
      }
      if (sunsetList != null && sunsetList.isNotEmpty) {
        sunset = DateTime.parse(sunsetList.first as String);
      }
    }

    return Weather(
      cityLabel: cityLabel,
      temperatureC: (current['temperature_2m'] as num).toDouble(),
      feelsLikeC: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windKph: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      isDay: (current['is_day'] as num).toInt() == 1,
      sunrise: sunrise,
      sunset: sunset,
      hourly: hourlyList,
      daily: dailyList,
    );
  }
}
