import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CalculatorOperation {
  final double a;
  final double b;

  CalculatorOperation({required this.a, required this.b});

  Map<String, dynamic> toJson() {
    return {'a': a, 'b': b};
  }
}

class CalculatorResult {
  final double result;
  final String operation;
  final bool success;
  final String? error;

  CalculatorResult({
    required this.result,
    required this.operation,
    required this.success,
    this.error,
  });

  factory CalculatorResult.fromJson(Map<String, dynamic> json) {
    return CalculatorResult(
      result: (json['result'] ?? 0.0).toDouble(),
      operation: json['operation'] ?? '',
      success: json['success'] ?? false,
      error: json['error'],
    );
  }

  @override
  String toString() {
    return 'CalculatorResult(result: $result, operation: $operation, success: $success, error: $error)';
  }
}

class HistoryEntry {
  final String operation;
  final double a;
  final double b;
  final double result;
  final DateTime timestamp;

  HistoryEntry({
    required this.operation,
    required this.a,
    required this.b,
    required this.result,
    required this.timestamp,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      operation: json['operation'] ?? '',
      a: (json['a'] ?? 0.0).toDouble(),
      b: (json['b'] ?? 0.0).toDouble(),
      result: (json['result'] ?? 0.0).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestamp'] ?? 0) * 1000,
      ),
    );
  }

  @override
  String toString() {
    return 'HistoryEntry(operation: $operation, a: $a, b: $b, result: $result, timestamp: $timestamp)';
  }
}

class HistoryResponse {
  final List<HistoryEntry> entries;

  HistoryResponse({required this.entries});

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    final entriesJson = json['entries'] as List<dynamic>? ?? [];
    final entries = entriesJson
        .map((entry) => HistoryEntry.fromJson(entry as Map<String, dynamic>))
        .toList();

    return HistoryResponse(entries: entries);
  }
}

class ApiService {
  static const String defaultBaseUrl = 'http://localhost:8080';
  final String baseUrl;
  final http.Client _client;
  final Duration _timeout;

  ApiService({
    this.baseUrl = defaultBaseUrl,
    http.Client? client,
    Duration timeout = const Duration(seconds: 10),
  })  : _client = client ?? http.Client(),
        _timeout = timeout;

  /// Perform addition operation
  Future<CalculatorResult> add(double a, double b) async {
    return _performOperation('add', a, b);
  }

  /// Perform subtraction operation
  Future<CalculatorResult> subtract(double a, double b) async {
    return _performOperation('subtract', a, b);
  }

  /// Perform multiplication operation
  Future<CalculatorResult> multiply(double a, double b) async {
    return _performOperation('multiply', a, b);
  }

  /// Perform division operation
  Future<CalculatorResult> divide(double a, double b) async {
    return _performOperation('divide', a, b);
  }

  /// Get calculation history
  Future<HistoryResponse> getHistory({int limit = 10}) async {
    final url = Uri.parse('$baseUrl/api/v1/history?limit=$limit');

    print('📚 Getting history: $url');

    try {
      final response = await _client.get(url).timeout(_timeout);

      print('📥 History response: ${response.statusCode}');
      print('📄 History body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final result = HistoryResponse.fromJson(jsonData);
        print('✅ History retrieved: ${result.entries.length} entries');
        return result;
      } else {
        print('❌ Failed to get history: ${response.statusCode}');
        throw ApiException(
          'Failed to get history: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on TimeoutException {
      print('⏰ History request timeout');
      throw ApiException('Request timeout', 408);
    } catch (e) {
      print('💥 History error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  /// Check service health
  Future<Map<String, dynamic>> getHealth() async {
    final url = Uri.parse('$baseUrl/api/v1/health');

    print('🏥 Health check: $url');

    try {
      final response = await _client.get(url).timeout(_timeout);

      print('📥 Health response: ${response.statusCode}');
      print('📄 Health body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Health check successful');
        return result;
      } else {
        print('❌ Health check failed: ${response.statusCode}');
        throw ApiException(
          'Health check failed: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on TimeoutException {
      print('⏰ Health check timeout');
      throw ApiException('Health check timeout', 408);
    } catch (e) {
      print('💥 Health check error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Health check error: $e', 0);
    }
  }

  /// Test network connectivity
  Future<bool> testConnection() async {
    try {
      await getHealth();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get response time for health endpoint
  Future<Duration?> getResponseTime() async {
    final stopwatch = Stopwatch()..start();

    try {
      await getHealth();
      stopwatch.stop();
      return stopwatch.elapsed;
    } catch (e) {
      return null;
    }
  }

  Future<CalculatorResult> _performOperation(
      String operation, double a, double b) async {
    final url = Uri.parse('$baseUrl/api/v1/calculate/$operation');
    final requestBody = CalculatorOperation(a: a, b: b);

    print('🌐 API Request: $operation');
    print('📡 URL: $url');
    print('📤 Request body: ${jsonEncode(requestBody.toJson())}');

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody.toJson()),
          )
          .timeout(_timeout);

      print('📥 Response status: ${response.statusCode}');
      print('📋 Response headers: ${response.headers}');
      print('📄 Response body: ${response.body}');

      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 400) {
        final result = CalculatorResult.fromJson(jsonData);
        print('✅ Operation successful: ${result.toString()}');
        return result;
      } else {
        print('❌ Operation failed with status: ${response.statusCode}');
        throw ApiException(
          'Operation failed: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on TimeoutException {
      print('⏰ Request timeout for $operation');
      throw ApiException('Request timeout', 408);
    } catch (e) {
      print('💥 Network error in $operation: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
