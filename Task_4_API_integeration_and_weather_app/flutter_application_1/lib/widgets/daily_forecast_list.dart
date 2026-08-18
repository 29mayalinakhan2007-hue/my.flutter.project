import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/weather_theme.dart';
import '../models/weather_model.dart';

class DailyForecastList extends StatelessWidget {
  final List<DailyForecast> days;
  final double Function(double celsius) convert;

  const DailyForecastList({
    super.key,
    required this.days,
    required this.convert,
  });

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    // Find the week's overall min/max so each day's bar is scaled
    // relative to the whole range — makes the spread meaningful at a
    // glance instead of every bar looking the same length.
    final allMax = days.map((d) => d.maxTempC).reduce((a, b) => a > b ? a : b);
    final allMin = days.map((d) => d.minTempC).reduce((a, b) => a < b ? a : b);
    final range = (allMax - allMin).clamp(1, double.infinity);

    return Column(
      children: List.generate(days.length, (index) {
        final day = days[index];
        final label = index == 0 ? 'Today' : DateFormat.E().format(day.date);

        final startFrac = (day.minTempC - allMin) / range;
        final endFrac = (day.maxTempC - allMin) / range;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Icon(
                WeatherTheme.iconFor(day.weatherCode),
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 34,
                child: Text(
                  '${convert(day.minTempC).round()}°',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: (endFrac - startFrac).clamp(0.06, 1.0),
                      alignment: Alignment(
                        (startFrac * 2 - 1).clamp(-1.0, 1.0),
                        0,
                      ),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withOpacity(0.5),
                              Theme.of(context).colorScheme.primary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 34,
                child: Text(
                  '${convert(day.maxTempC).round()}°',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
