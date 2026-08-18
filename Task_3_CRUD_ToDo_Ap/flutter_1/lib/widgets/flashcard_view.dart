import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class FlashcardView extends StatefulWidget {
  final Flashcard card;
  final int currentIndex;
  final int total;

  const FlashcardView({
    super.key,
    required this.card,
    required this.currentIndex,
    required this.total,
  });

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void _flipCard() {
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _showFront = !_showFront);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * pi;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: _flipCard,
            child: Container(
              width: double.infinity,
              height: 380,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))
                ],
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: angle >= pi / 2
                  ? Transform(
                      transform: Matrix4.identity()..rotateY(pi),
                      alignment: Alignment.center,
                      child: _buildBack(isDark),
                    )
                  : _buildFront(isDark),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFront(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Chip(
              label: Text(widget.card.category.toUpperCase()),
              backgroundColor: AppColors.primary.withAlpha((0.1 * 255).round()),
            ),
            Text('Card ${widget.currentIndex + 1} / ${widget.total}',
                style: AppTypography.caption(isDark)),
          ],
        ),
        Center(
          child: Text(
            widget.card.question,
            style: AppTypography.headingMedium(isDark),
            textAlign: TextAlign.center,
          ),
        ),
        Text('Tap to reveal answer', style: AppTypography.caption(isDark)),
      ],
    );
  }

  Widget _buildBack(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('ANSWER', style: AppTypography.caption(isDark)),
        Center(
          child: Text(
            widget.card.answer,
            style: AppTypography.title(isDark),
            textAlign: TextAlign.center,
          ),
        ),
        Text('Tap to flip back', style: AppTypography.caption(isDark)),
      ],
    );
  }
}