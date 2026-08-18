class Flashcard {
  final int? id;
  final String question;
  final String answer;
  final String category;
  final String? hint;
  final DateTime createdAt;
  final DateTime updatedAt;

  Flashcard({
    this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.hint,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'hint': hint,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] as int?,
      question: map['question'] as String,
      answer: map['answer'] as String,
      category: map['category'] as String,
      hint: map['hint'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Flashcard copyWith({
    int? id,
    String? question,
    String? answer,
    String? category,
    String? hint,
  }) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      hint: hint ?? this.hint,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}