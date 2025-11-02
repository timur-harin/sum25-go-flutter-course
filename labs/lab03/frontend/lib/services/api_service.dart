import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

// ... (ApiException classes remain the same as before) ...

class ApiService {
  final String _baseUrl = 'http://localhost:8080/api';
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<T> _sendRequest<T>(
      String endpoint,
      String method, {
        Map<String, dynamic>? body,
        T Function(dynamic json)? fromJsonT,
      }) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await _client.get(uri);
          break;
        case 'POST':
          response = await _client.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await _client.put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await _client.delete(uri);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }
    } on http.ClientException catch (e) {
      // Ensure NetworkException is explicitly caught and re-thrown
      throw NetworkException('Network error: ${e.message}');
    }

    // Handle empty response body early
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // For successful empty responses (e.g., 204 No Content for DELETE)
        if (T == dynamic || T == void) { // Assuming T could be dynamic or void for empty successful responses
          return true as T; // A simple `true` for `dynamic`, `null` for `void`
        }
        // If an empty body is received but a specific type T was expected, it's an error.
        throw ApiException('Empty response body when data of type $T was expected.', statusCode: response.statusCode);
      } else {
        // If it's an error status code but body is empty, still treat as unknown error
        throw ServerException('Server responded with empty error body', response.statusCode);
      }
    }

    Map<String, dynamic> responseJson;
    try {
      responseJson = jsonDecode(response.body);
    } catch (e) {
      throw ApiException('Invalid JSON response: ${response.body}', statusCode: response.statusCode);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Check if the response contains 'success' and 'data' fields typical of ApiResponse
      if (responseJson.containsKey('success')) {
        final apiResponse = ApiResponse<T>.fromJson(responseJson, fromJsonT);
        if (apiResponse.success) {
          if (apiResponse.data != null) {
            return apiResponse.data!;
          } else {
            // If success is true but data is null, and a type T was expected,
            // this is still an issue UNLESS T is intended to be null (e.g., void)
            // or fromJsonT would handle a null data.
            // For healthCheck, T is Map<String,dynamic>, so null data is an error here.
            throw ApiException('Received null data in successful ApiResponse when type $T was expected.', statusCode: response.statusCode);
          }
        } else {
          // If success is false
          final errorMessage = apiResponse.error ?? 'Unknown error';
          if (response.statusCode == 400) {
            throw ValidationException(errorMessage);
          }
          throw ServerException(errorMessage, response.statusCode);
        }
      } else {
        // If the successful response doesn't conform to ApiResponse structure
        // (e.g., health check directly returns {status: 'healthy'})
        if (fromJsonT != null) {
          try {
            return fromJsonT(responseJson); // Pass the whole responseJson to fromJsonT
          } catch (e) {
            throw ApiException('Failed to parse successful response: $e', statusCode: response.statusCode);
          }
        } else {
          // If no fromJsonT is provided and it's not ApiResponse, then return as T if possible
          if (responseJson is T) {
            return responseJson as T;
          }
          throw ApiException('Unexpected successful response format. Expected type $T', statusCode: response.statusCode);
        }
      }
    } else {
      // Error status codes (4xx, 5xx)
      final errorMessage = responseJson['error'] ?? 'Unknown error';

      if (response.statusCode >= 500) {
        throw ServerException(errorMessage, response.statusCode);
      } else if (response.statusCode == 400) {
        throw ValidationException(errorMessage);
      }
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  // ... (Other API methods like getMessages, createMessage, etc. remain the same) ...

  Future<Map<String, dynamic>> healthCheck() async {
    // fromJsonT will be applied directly to the responseJson because it won't have 'success'/'data'
    return _sendRequest<Map<String, dynamic>>('health', 'GET', fromJsonT: (json) => json as Map<String, dynamic>);
  }

  void dispose() {
    _client.close();
  }
}