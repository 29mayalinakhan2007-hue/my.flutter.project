import 'dart:convert';

/// Priority levels for a task — used to color-code list items.
enum Priority { low, medium, high }

Priority priorityFromString(String value) {
  return Priority.values.firstWhere(
    (p) => p.name == value,
    orElse: () => Priority.medium,
  );
}

class Task {
  String id;
  String title;
  bool isCompleted;
  Priority priority;
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.priority = Priority.medium,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    bool? isCompleted,
    Priority? priority,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'priority': priority.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool,
        priority: priorityFromString(json['priority'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  static String encodeList(List<Task> tasks) =>
      jsonEncode(tasks.map((t) => t.toJson()).toList());

  static List<Task> decodeList(String jsonStr) {
    final List<dynamic> data = jsonDecode(jsonStr) as List<dynamic>;
    return data
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
