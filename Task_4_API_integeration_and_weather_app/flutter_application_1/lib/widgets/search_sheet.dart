import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

/// Modal search sheet: live city search with disambiguation (multiple
/// matches shown as a pickable list) plus recent searches for
/// one-tap return visits.
class SearchSheet extends StatefulWidget {
  const SearchSheet({super.key});

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<WeatherProvider>().searchCities(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: _onChanged,
                  decoration: InputDecoration(
                    hintText: 'Search for a city',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Consumer<WeatherProvider>(
                  builder: (context, provider, _) {
                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        if (provider.isSearching)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (provider.searchError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                            child: Text(
                              provider.searchError,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          )
                        else if (provider.searchResults.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
                            child: Text('Results',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          ...provider.searchResults.map((r) => ListTile(
                                leading: const Icon(Icons.location_on_outlined),
                                title: Text(r.name),
                                subtitle: Text(r.label),
                                onTap: () async {
                                  await provider.selectCity(r);
                                  if (context.mounted) Navigator.of(context).pop();
                                },
                              )),
                        ] else if (provider.recentCities.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
                            child: Text('Recent',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          ...provider.recentCities.map((label) => ListTile(
                                leading: const Icon(Icons.history_rounded),
                                title: Text(label),
                                onTap: () async {
                                  await provider.selectCityByName(label);
                                  if (context.mounted) Navigator.of(context).pop();
                                },
                              )),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
