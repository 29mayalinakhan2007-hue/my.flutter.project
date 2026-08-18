import '../database/db_helper.dart';
import '../models/flashcard.dart';

class FlashcardRepository {
  final DBHelper dbHelper = DBHelper.instance;

  Future<List<Flashcard>> fetchAll() async {
    final result = await dbHelper.queryAllFlashcards();
    return result.map((e) => Flashcard.fromMap(e)).toList();
  }

  Future<Flashcard> add(Flashcard card) async {
    final id = await dbHelper.insertFlashcard(card.toMap());
    return card.copyWith(id: id);
  }

  Future<void> update(Flashcard card) async {
    await dbHelper.updateFlashcard(card.toMap());
  }

  Future<void> delete(int id) async {
    await dbHelper.deleteFlashcard(id);
  }

  Future<void> clearAll() async {
    await dbHelper.clearAllFlashcards();
  }
}