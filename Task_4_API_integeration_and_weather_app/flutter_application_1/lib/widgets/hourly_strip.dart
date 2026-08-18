import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/weather_theme.dart';
import '../models/weather_model.dart';

class HourlyStrip extends StatelessWidget {
  final List<HourlyForecast> hours;
  final bool useCelsius;
  final double Function(double celsius) convert;

  const HourlyStrip({
    super.key,
    required this.hours,
    required this.useCelsius,
    required this.convert,
  });

  @override
  Widget build(BuildContext context) {
    if (hours.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hours.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final hour = hours[index];
          final label = index == 0 ? 'Now' : DateFormat.j().format(hour.time);
          final temp = convert(hour.temperatureC).round();

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 10),
              Icon(
                WeatherTheme.iconFor(hour.weatherCode, isDay: hour.isDay),
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(height: 10),
              Text(
                '$temp°',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}
