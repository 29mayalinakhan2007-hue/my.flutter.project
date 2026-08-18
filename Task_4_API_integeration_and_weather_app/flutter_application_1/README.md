# Atmos — Weather, Alive

A Flutter weather app built as a portfolio piece, not a tutorial exercise.
The signature idea: the background isn't a static gradient — it's a small,
looping animation, hand-painted with `CustomPainter`, that actually matches
the forecast. Clear skies drift with slow-rotating sun rays. Rain falls.
Snow settles and sways. Clear nights twinkle with stars and a soft moon.
No image assets, no Lottie files — every pixel of the sky is drawn in code.

## Why this project

Most "weather app" portfolio pieces are a card with a temperature and an
icon. This one is meant to show a broader slice of what a mobile app dev
actually does:

- A real design system (bespoke color palettes per weather mood, a
  deliberate type pairing) instead of default Material colors
- A signature UI element built from scratch (the `LivingSky` painter) —
  proof of custom animation and `CustomPainter` skills, not just API wiring
- Clean state management with `Provider`/`ChangeNotifier`, separated from
  both the UI and the networking layer
- Defensive networking: timeouts, HTTP status handling, disambiguating
  cities with the same name, and specific error messages for each failure
  mode
- Local persistence (recent searches, last-viewed city, unit preference)
- Unit tests for the parsing and theming logic

## Features

- **Live weather** for any city, worldwide, via a free, keyless API
- **Animated sky** that reflects the real condition and time of day
- **Hourly strip** (next 24 hours) and **7-day forecast** with a min/max
  range bar
- **°C / °F toggle** — instant, no re-fetch, since raw data is always kept
  in Celsius
- **Search with disambiguation** — typing "Cambridge" shows both the UK
  and US matches instead of guessing
- **Recent searches**, persisted locally, for one-tap return visits
- **Pull-to-refresh** and a **loading state** that never leaves a blank
  screen
- **Graceful errors** for no internet, city-not-found, server errors,
  rate limits, and timeouts — each with its own message and a retry button

## Screens & flow

```
Home
 ├─ Top bar: search icon (opens bottom sheet) · °C/°F toggle
 ├─ Hero: animated sky + city name + big temperature + high/low
 └─ Forecast sheet (rounded, scrolls over the sky):
     ├─ Hourly strip (24h)
     ├─ 7-day forecast (min/max bar chart)
     └─ Details grid: feels like, humidity, wind, sunrise, sunset

Search sheet
 ├─ Live search (debounced) → picks resolve ambiguity if needed
 └─ Recent cities
```

## Architecture

```
lib/
  main.dart                    # Entry point
  app.dart                     # MaterialApp + Provider wiring

  core/
    app_theme.dart             # Typography pairing (Space Grotesk + Manrope)
    weather_theme.dart         # Weather-code → mood → palette/icon mapping

  models/
    weather_model.dart         # Weather, HourlyForecast, DailyForecast, GeoResult

  services/
    weather_service.dart       # Open-Meteo API calls + WeatherException
    storage_service.dart       # SharedPreferences wrapper (recent cities, unit, last city)

  providers/
    weather_provider.dart      # ChangeNotifier: the single source of UI state

  widgets/
    living_sky.dart            # Signature CustomPainter sky animation
    hourly_strip.dart
    daily_forecast_list.dart
    stat_grid.dart
    error_view.dart
    search_sheet.dart

  screens/
    home_screen.dart

test/
  weather_model_test.dart      # Parsing + theming logic, no network required
```

This separation means: the UI never talks to `http` directly, the provider
never knows about JSON shapes, and the theme/animation logic is testable in
isolation from both.

## Getting started

```bash
flutter pub get
flutter run
```

No `.env` file, no API key, nothing to configure — it works the moment you
run it.

### Android internet permission

Most Flutter templates already include this, but if you scaffold a fresh
`android/` folder, confirm this line is inside the `<manifest>` tag of
`android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Running tests

```bash
flutter test
```

Covers weather-code → mood mapping, JSON parsing for current/hourly/daily
blocks, and `GeoResult` label formatting — all offline.

## API

[Open-Meteo](https://open-meteo.com/) — free, no key, no sign-up.

- **Geocoding**: `GET /v1/search?name={city}` → candidate matches
- **Forecast**: `GET /v1/forecast?latitude=..&longitude=..&current=..&hourly=..&daily=..`

## Ideas for a v2 (good next commits)

- `geolocator` integration for "use my current location"
- Push notifications for severe weather (thunderstorm/snow alerts)
- Home-screen widget (Android App Widgets / iOS WidgetKit via `home_widget`)
- Riverpod migration for compile-time-safe DI
- Golden tests / screenshot tests for `LivingSky` across all moods
- CI (GitHub Actions) running `flutter analyze` + `flutter test` on push

## Tech stack

Flutter · Provider · http · shared_preferences · google_fonts · intl
