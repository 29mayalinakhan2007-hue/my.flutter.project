# TaskFlow — Professional To-Do App (Flutter)

A polished, production-quality To-Do app: gradient header, live progress bar,
priority tags, swipe-to-delete, light/dark mode, and local persistence — all
built with clean, well-commented Flutter code.

## ✨ Features

- **Gradient header** with live "X of Y completed" progress bar
- **Priority tags** (Low / Medium / High) with color-coded indicators
- **Swipe left to delete**, tap to edit, tap the circle to complete
- **Light & dark mode** toggle, persisted across launches
- **Local persistence** via `shared_preferences` — tasks survive app restarts
- **Empty state** illustration when the list is clear
- **Smooth animations** on checkboxes, text strikethrough, and progress bar

## 🗂 Project structure

```
lib/
├── main.dart                  # App entry point, theme wiring
├── models/
│   └── task.dart               # Task model + JSON (de)serialization
├── providers/
│   └── task_provider.dart      # CRUD logic, persistence, theme state
├── screens/
│   └── home_screen.dart        # Main UI: header, progress, task list
├── widgets/
│   ├── task_tile.dart           # Individual task card (swipe/animate)
│   ├── task_editor_sheet.dart   # Add/Edit bottom sheet with priority picker
│   └── empty_state.dart         # "All clear!" placeholder
└── theme/
    └── app_theme.dart           # Colors, light/dark ThemeData
```

## 🚀 Run it

```bash
flutter pub get
flutter run
```

## 🎨 Design notes

- Single accent color (`#6C5CE7`) used consistently across both themes for a
  cohesive, branded feel rather than default Material colors.
- Rounded 18–28px corners throughout for a soft, modern look.
- Priority is communicated with both color AND an icon/label — not color alone.
- All CRUD actions (`add`, `edit`, `delete`, `toggle complete`) persist
  immediately to local storage, so nothing is lost on close.

## 🧩 Built with

- Flutter (Material 3)
- `provider` — state management
- `shared_preferences` — local data persistence
