import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../theme/app_colors.dart';
import '../widgets/flashcard_view.dart';
import 'study_completion_screen.dart';

class StudyScreen extends StatefulWidget {
  final List<Flashcard> cards;

  const StudyScreen({super.key, required this.cards});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  int _currentIndex = 0;

  void _nextCard() {
    if (_currentIndex < widget.cards.length - 1) {
      setState(() => _currentIndex++);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudyCompletionScreen(
            totalStudied: widget.cards.length,
            correct: widget.cards.length,
          ),
        ),
      );
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / widget.cards.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Session'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress, color: AppColors.primary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: FlashcardView(
                card: widget.cards[_currentIndex],
                currentIndex: _currentIndex,
                total: widget.cards.length,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filledTonal(
                  onPressed: _currentIndex > 0 ? _prevCard : null,
                  icon: const Icon(Icons.arrow_back),
                ),
                IconButton.filled(
                  onPressed: _nextCard,
                  icon: const Icon(Icons.arrow_forward),
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}