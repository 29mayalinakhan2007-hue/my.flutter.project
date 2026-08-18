import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class StatGrid extends StatelessWidget {
  final Weather weather;
  final String unitSuffix;
  final double Function(double celsius) convert;

  const StatGrid({
    super.key,
    required this.weather,
    required this.unitSuffix,
    required this.convert,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_StatItem>[
      _StatItem(
        icon: Icons.thermostat_rounded,
        label: 'Feels like',
        value: '${convert(weather.feelsLikeC).round()}$unitSuffix',
      ),
      _StatItem(
        icon: Icons.water_drop_outlined,
        label: 'Humidity',
        value: '${weather.humidity}%',
      ),
      _StatItem(
        icon: Icons.air_rounded,
        label: 'Wind',
        value: '${weather.windKph.round()} km/h',
      ),
      if (weather.sunrise != null)
        _StatItem(
          icon: Icons.wb_twilight_rounded,
          label: 'Sunrise',
          value: DateFormat.jm().format(weather.sunrise!),
        ),
      if (weather.sunset != null)
        _StatItem(
          icon: Icons.nights_stay_outlined,
          label: 'Sunset',
          value: DateFormat.jm().format(weather.sunset!),
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.1,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(item.icon, color: Theme.of(context).colorScheme.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;

  _StatItem({required this.icon, required this.label, required this.value});
}
