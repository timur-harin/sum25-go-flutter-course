# Lab 01 - Flutter Frontend

This directory contains the Flutter implementation of three basic UI components:

1. **Profile Card**: A widget to display user information
2. **Counter App**: A simple counter application with increment/decrement functionality
3. **Registration Form**: A form with validation for user registration

## Getting Started

### Prerequisites
- Flutter SDK (>=3.3.0)
- Dart SDK (>=3.0.0)

### Setup
1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

### Running Tests
To run all widget tests:
```bash
flutter test
```

## Components

### Profile Card
- Displays user information (name, email, age)
- Optional avatar support
- Clean, modern design

### Counter App
- Increment/decrement functionality
- Reset button
- State management example

### Registration Form
- Input validation
- Error handling
- Form submission

## Project Structure
```
lib/
├── main.dart              # App entry point
├── profile_card.dart      # Profile card widget
├── counter_app.dart       # Counter application
└── registration_form.dart # Registration form widget

test/
├── profile_card_test.dart
├── counter_app_test.dart
└── registration_form_test.dart
```

## Testing
Each component has its own test file that verifies:
- Widget rendering
- User interactions
- Input validation
- State management
