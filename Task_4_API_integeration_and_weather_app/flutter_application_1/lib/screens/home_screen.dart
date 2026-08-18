import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/weather_theme.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/error_view.dart';
import '../widgets/hourly_strip.dart';
import '../widgets/living_sky.dart';
import '../widgets/search_sheet.dart';
import '../widgets/stat_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().init();
    });
  }

  void _openSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SearchSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        final weather = provider.weather;
        final mood = weather != null
            ? WeatherTheme.moodFromCode(weather.weatherCode, isDay: weather.isDay)
            : SkyMood.clearDay;

        return Scaffold(
          body: LivingSky(
            mood: mood,
            child: SafeArea(
              child: Column(
                children: [
                  _TopBar(onSearchTap: _openSearch),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: provider.refresh,
                      color: Colors.white,
                      backgroundColor: Colors.black.withOpacity(0.3),
                      child: _Body(provider: provider),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onSearchTap;
  const _TopBar({required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _IconPill(icon: Icons.search_rounded, onTap: onSearchTap),
          GestureDetector(
            onTap: provider.toggleUnit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                provider.useCelsius ? '°C' : '°F',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconPill extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconPill({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.16),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final WeatherProvider provider;
  const _Body({required this.provider});

  @override
  Widget build(BuildContext context) {
    switch (provider.status) {
      case LoadStatus.loading:
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            Padding(
              padding: EdgeInsets.only(top: 140),
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
          ],
        );

      case LoadStatus.error:
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ErrorView(
              message: provider.errorMessage,
              onRetry: () {
                final label = provider.weather?.cityLabel ?? 'Islamabad';
                provider.selectCityByName(label);
              },
            ),
          ],
        );

      case LoadStatus.success:
        final weather = provider.weather!;
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _Hero(weather: weather, provider: provider),
            const SizedBox(height: 8),
            _ForecastSheet(weather: weather, provider: provider),
          ],
        );

      case LoadStatus.idle:
        return const SizedBox.shrink();
    }
  }
}

class _Hero extends StatelessWidget {
  final Weather weather;
  final WeatherProvider provider;
  const _Hero({required this.weather, required this.provider});

  @override
  Widget build(BuildContext context) {
    final temp = provider.displayTemp(weather.temperatureC).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        children: [
          Text(
            weather.cityLabel,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            WeatherTheme.descriptionFor(weather.weatherCode),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          Text(
            '$temp°',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'H:${provider.displayTemp(weather.daily.isNotEmpty ? weather.daily.first.maxTempC : weather.temperatureC).round()}°  '
            'L:${provider.displayTemp(weather.daily.isNotEmpty ? weather.daily.first.minTempC : weather.temperatureC).round()}°',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}

class _ForecastSheet extends StatelessWidget {
  final Weather weather;
  final WeatherProvider provider;
  const _ForecastSheet({required this.weather, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 420),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hourly forecast',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF17222B),
                  )),
          const SizedBox(height: 12),
          _DarkStrip(child: HourlyStrip(
            hours: weather.hourly,
            useCelsius: provider.useCelsius,
            convert: provider.displayTemp,
          )),
          const SizedBox(height: 28),
          Text('7-day forecast',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF17222B),
                  )),
          const SizedBox(height: 8),
          DailyForecastList(days: weather.daily, convert: provider.displayTemp),
          const SizedBox(height: 28),
          Text('Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF17222B),
                  )),
          const SizedBox(height: 12),
          StatGrid(
            weather: weather,
            unitSuffix: provider.unitSuffix,
            convert: provider.displayTemp,
          ),
        ],
      ),
    );
  }
}

/// Wraps the hourly strip in a dark rounded card so it visually reads
/// as "still part of the sky" even though it sits inside the light
/// forecast sheet — a small continuity detail between the two zones.
class _DarkStrip extends StatelessWidget {
  final Widget child;
  const _DarkStrip({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF17222B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
