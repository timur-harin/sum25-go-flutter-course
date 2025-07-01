# Lab 02 - Flutter Frontend: Real-time Chat

This frontend implements the UI and logic for a real-time chat application using Flutter async and stream patterns.

## Tasks

### 4. Chat Service (Streams & Futures)
- Dart service for connecting to backend (simulate with mock).
- Use Streams for real-time messages, Futures for sending.
- **Test:** Stream emits, send/receive, error handling.

### 5. Chat Screen (StreamBuilder)
- UI for chat using `StreamBuilder`.
- Display messages, input for sending, show loading/error states.
- **Test:** Widget renders, reacts to stream, user input.

### 6. User Profile & Async State
- User profile widget, async load/update user info.
- Use `FutureBuilder`, handle errors, update state.
- **Test:** Widget renders, async update, error handling.

## Getting Started

```bash
cd frontend
flutter pub get
flutter run
```

## Concepts Used
- Streams, Futures, async/await
- StreamBuilder, FutureBuilder
- Error handling, state management

## Project Structure
```
frontend/
├── lib/
│   ├── chat_screen.dart      # Chat UI
│   ├── chat_service.dart     # Chat logic (streams/futures)
│   ├── user_profile.dart     # User profile widget
│   └── main.dart             # App entry point
├── test/
│   ├── chat_screen_test.dart
│   ├── chat_service_test.dart
│   └── user_profile_test.dart
├── pubspec.yaml
└── README.md
```

## Note

After creating the project, run:

```bash
flutter pub get
```

All test and lib files are scaffolded with TODOs for you to implement as part of the lab tasks. 