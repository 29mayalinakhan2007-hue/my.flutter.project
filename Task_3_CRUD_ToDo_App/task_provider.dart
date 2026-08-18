import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

/// Single source of truth for the task list + theme mode.
/// Persists to local device storage (SharedPreferences) so
/// tasks survive an app restart — "local data" done properly.
class TaskProvider extends ChangeNotifier {
  static const _storageKey = 'tasks_v1';
  static const _themeKey = 'theme_mode_v1';

  List<Task> _tasks = [];
  bool _isLoading = true;
  ThemeMode _themeMode = ThemeMode.light;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  ThemeMode get themeMode => _themeMode;

  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get totalCount => _tasks.length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  TaskProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      _tasks = Task.decodeList(jsonStr);
    } else {
      // Friendly starter tasks so the app doesn't look empty on first run.
      _tasks = [
        Task(id: '1', title: 'Welcome! Swipe left to delete a task', priority: Priority.low),
        Task(id: '2', title: 'Tap a task to mark it complete', priority: Priority.medium),
        Task(id: '3', title: 'Tap + to add your first real task', priority: Priority.high),
      ];
    }
    final themeStr = prefs.getString(_themeKey);
    _themeMode = themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, Task.encodeList(_tasks));
  }

  void toggleThemeMode() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeMode == ThemeMode.dark ? 'dark' : 'light');
  }

  // CREATE
  void addTask(String title, Priority priority) {
    if (title.trim().isEmpty) return;
    _tasks.insert(
      0,
      Task(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title.trim(),
        priority: priority,
      ),
    );
    notifyListeners();
    _persist();
  }

  // UPDATE (edit title / priority)
  void editTask(String id, String newTitle, Priority priority) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1 || newTitle.trim().isEmpty) return;
    _tasks[index] = _tasks[index].copyWith(title: newTitle.trim(), priority: priority);
    notifyListeners();
    _persist();
  }

  // DELETE
  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    _persist();
  }

  // UPDATE (toggle completed)
  void toggleComplete(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
    notifyListeners();
    _persist();
  }

  void clearCompleted() {
    _tasks.removeWhere((t) => t.isCompleted);
    notifyListeners();
    _persist();
  }
}
