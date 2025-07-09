class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException(this.message, [this.prefix]);

  @override
  String toString() {
    return '$prefix$message';
  }
}

class UninitializedDatabaseException extends AppException {
  UninitializedDatabaseException() : super("Database not initialized");
}

class UninitializedPreferencesException extends AppException {
  UninitializedPreferencesException()
      : super("Preferences service not initialized");
}

class PreferencesParseException extends AppException {
  PreferencesParseException(String message)
      : super(message, "Failed to parse JSON object for key ");
}

class UserNotFoundException extends AppException {
  UserNotFoundException() : super("User not found");
}
