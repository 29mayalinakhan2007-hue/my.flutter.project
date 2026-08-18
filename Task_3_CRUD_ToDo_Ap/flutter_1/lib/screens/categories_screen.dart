import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../theme/app_typography.dart';
import '../theme/app_colors.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<FlashcardProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Categories', style: AppTypography.headingMedium(isDark))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: provider.categories.where((c) => c != 'All').length,
          itemBuilder: (context, index) {
            final cat = provider.categories.where((c) => c != 'All').toList()[index];
            final cardCount = provider.cards.where((c) => c.category == cat).length;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📚', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 12),
                  Text(cat, style: AppTypography.title(isDark)),
                  const SizedBox(height: 4),
                  Text('$cardCount Cards', style: AppTypography.caption(isDark)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}