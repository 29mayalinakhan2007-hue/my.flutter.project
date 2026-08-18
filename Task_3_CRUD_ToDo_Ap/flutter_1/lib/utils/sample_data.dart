import '../models/flashcard.dart';

class SampleData {
  static final List<Flashcard> initialCards = [
    Flashcard(
      question: 'What is Object-Oriented Programming?',
      answer: 'A programming paradigm based on objects containing data and code.',
      category: 'Computer Science',
    ),
    Flashcard(
      question: 'What is the Derivative of x^2?',
      answer: '2x',
      category: 'Mathematics',
    ),
    Flashcard(
      question: 'What is Photosynthesis?',
      answer: 'The process used by plants to convert light energy into chemical energy.',
      category: 'Science',
    ),
  ];
}