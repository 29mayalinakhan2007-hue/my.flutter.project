import 'package:flutter/material.dart';

/// The kind of live sky animation to paint behind the current weather.
/// This is the app's signature element — every screen with a forecast
/// shows a small, calm animation that matches the real condition.
enum SkyMood {
  clearDay,
  clearNight,
  partlyCloudyDay,
  partlyCloudyNight,
  overcast,
  fog,
  rain,
  snow,
  storm,
}

/// A named visual identity for one weather mood: a bespoke gradient,
/// a text color that stays readable on it, and a short label used
/// in the UI (e.g. above the hourly strip).
class SkyPalette {
  final String name;
  final List<Color> gradient;
  final Color foreground;
  final Color foregroundMuted;

  const SkyPalette({
    required this.name,
    required this.gradient,
    required this.foreground,
    required this.foregroundMuted,
  });
}

/// Maps an Open-Meteo WMO weather code + day/night flag to a [SkyMood],
/// then to a bespoke [SkyPalette]. Reference for codes:
/// https://open-meteo.com/en/docs
class WeatherTheme {
  static SkyMood moodFromCode(int code, {required bool isDay}) {
    if (code == 0 || code == 1) {
      return isDay ? SkyMood.clearDay : SkyMood.clearNight;
    }
    if (code == 2) {
      return isDay ? SkyMood.partlyCloudyDay : SkyMood.partlyCloudyNight;
    }
    if (code == 3) return SkyMood.overcast;
    if (code == 45 || code == 48) return SkyMood.fog;
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
      return SkyMood.rain;
    }
    if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
      return SkyMood.snow;
    }
    if (code >= 95) return SkyMood.storm;
    return isDay ? SkyMood.clearDay : SkyMood.clearNight;
  }

  static const Map<SkyMood, SkyPalette> _palettes = {
    SkyMood.clearDay: SkyPalette(
      name: 'Solstice',
      gradient: [Color(0xFFFFD97D), Color(0xFFF97F51), Color(0xFF2E86DE)],
      foreground: Color(0xFFFFFFFF),
      foregroundMuted: Color(0xE6FFFFFF),
    ),
    SkyMood.clearNight: SkyPalette(
      name: 'Midnight Bloom',
      gradient: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
      foreground: Color(0xFFF5F7FA),
      foregroundMuted: Color(0xB3F5F7FA),
    ),
    SkyMood.partlyCloudyDay: SkyPalette(
      name: 'Cotton Drift',
      gradient: [Color(0xFF6DB3E8), Color(0xFF9AC8F0), Color(0xFFE9F3FB)],
      foreground: Color(0xFFFFFFFF),
      foregroundMuted: Color(0xE6FFFFFF),
    ),
    SkyMood.partlyCloudyNight: SkyPalette(
      name: 'Slate Drift',
      gradient: [Color(0xFF232B3E), Color(0xFF39445E), Color(0xFF556080)],
      foreground: Color(0xFFF5F7FA),
      foregroundMuted: Color(0xB3F5F7FA),
    ),
    SkyMood.overcast: SkyPalette(
      name: 'Slate Veil',
      gradient: [Color(0xFF5C6B80), Color(0xFF8996A8), Color(0xFFC3CCD8)],
      foreground: Color(0xFFFFFFFF),
      foregroundMuted: Color(0xE6FFFFFF),
    ),
    SkyMood.fog: SkyPalette(
      name: 'Hollow',
      gradient: [Color(0xFF4B5560), Color(0xFF7C8894), Color(0xFFBFC7CE)],
      foreground: Color(0xFFFFFFFF),
      foregroundMuted: Color(0xE6FFFFFF),
    ),
    SkyMood.rain: SkyPalette(
      name: 'Monsoon',
      gradient: [Color(0xFF16222A), Color(0xFF2B4256), Color(0xFF3A6073)],
      foreground: Color(0xFFF5F7FA),
      foregroundMuted: Color(0xB3F5F7FA),
    ),
    SkyMood.snow: SkyPalette(
      name: 'Frostlight',
      gradient: [Color(0xFF3B4A54), Color(0xFF6E8898), Color(0xFFE6DADA)],
      foreground: Color(0xFFFFFFFF),
      foregroundMuted: Color(0xE6FFFFFF),
    ),
    SkyMood.storm: SkyPalette(
      name: 'Voltage',
      gradient: [Color(0xFF16181A), Color(0xFF2E3134), Color(0xFF474B4F)],
      foreground: Color(0xFFF5F7FA),
      foregroundMuted: Color(0xB3F5F7FA),
    ),
  };

  static SkyPalette paletteFor(SkyMood mood) => _palettes[mood]!;

  /// Short human description used as the "condition" label under the
  /// temperature (kept separate from icon/animation choice).
  static String descriptionFor(int code) {
    const map = {
      0: 'Clear sky',
      1: 'Mainly clear',
      2: 'Partly cloudy',
      3: 'Overcast',
      45: 'Fog',
      48: 'Depositing rime fog',
      51: 'Light drizzle',
      53: 'Moderate drizzle',
      55: 'Dense drizzle',
      56: 'Light freezing drizzle',
      57: 'Dense freezing drizzle',
      61: 'Slight rain',
      63: 'Moderate rain',
      65: 'Heavy rain',
      66: 'Light freezing rain',
      67: 'Heavy freezing rain',
      71: 'Slight snow fall',
      73: 'Moderate snow fall',
      75: 'Heavy snow fall',
      77: 'Snow grains',
      80: 'Slight rain showers',
      81: 'Moderate rain showers',
      82: 'Violent rain showers',
      85: 'Slight snow showers',
      86: 'Heavy snow showers',
      95: 'Thunderstorm',
      96: 'Thunderstorm with hail',
      99: 'Severe thunderstorm',
    };
    return map[code] ?? 'Unknown';
  }

  /// A compact glyph shown in small spaces (hourly strip, daily list) —
  /// kept as a simple Material icon so it never looks like clip-art next
  /// to the painted hero animation.
  static IconData iconFor(int code, {bool isDay = true}) {
    if (code == 0 || code == 1) {
      return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
    }
    if (code == 2) {
      return isDay ? Icons.wb_cloudy_rounded : Icons.cloud_rounded;
    }
    if (code == 3) return Icons.cloud_rounded;
    if (code == 45 || code == 48) return Icons.foggy;
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
      return Icons.water_drop_rounded;
    }
    if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
      return Icons.ac_unit_rounded;
    }
    if (code >= 95) return Icons.bolt_rounded;
    return Icons.wb_sunny_rounded;
  }
}
