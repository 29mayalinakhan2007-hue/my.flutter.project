import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../repositories/flashcard_repository.dart';

class FlashcardProvider extends ChangeNotifier {
  final FlashcardRepository _repository = FlashcardRepository();

  List<Flashcard> _cards = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;

  List<Flashcard> get cards => _cards;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<Flashcard> get filteredCards {
    return _cards.where((card) {
      final matchesQuery = card.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          card.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || card.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  List<String> get categories {
    final cats = _cards.map((c) => c.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  Future<void> loadFlashcards() async {
    _isLoading = true;
    notifyListeners();
    _cards = await _repository.fetchAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCard(Flashcard card) async {
    final newCard = await _repository.add(card);
    _cards.insert(0, newCard);
    notifyListeners();
  }

  Future<void> updateCard(Flashcard card) async {
    await _repository.update(card);
    final index = _cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      _cards[index] = card;
      notifyListeners();
    }
  }

  Future<void> deleteCard(int id) async {
    await _repository.delete(id);
    _cards.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}