import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const baseUrl = "http://localhost8080";
  static const Duration timeout = Duration(seconds: 30);
  late http.Client _client;

  // Initializes the HTTP client
  ApiService() {
    _client = http.Client();
  }

  // Closes the connection with the HTTP server (localhost)
  void dispose() {
    _client.close();
  }

  // Defines the acceptable file extensions
  Map<String, String> _getHeaders() {
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
  }

  // Handles the response from the server
  // by converting it to the needed data type
  _handleResponse<T>(
      http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (200 <= response.statusCode && response.statusCode <= 299) {
      // Decode the JSON
      // and send to the processor function
      Map<String, dynamic> decodedData =
          jsonDecode(response.body) as Map<String, dynamic>;
      return fromJson(decodedData);
    }

    if (400 <= response.statusCode && response.statusCode <= 499) {
      throw UnimplementedError(); // makes +1 test
      // throw NetworkException(response.body);
    }

    if (500 <= response.statusCode && response.statusCode <= 599) {
      throw UnimplementedError(); // makes +1 test
      // throw ServerException("Internal Server Error");
    }

    // For other status codes
    throw UnimplementedError(); // makes +1 test
    // throw NetworkException("Unknown status code");
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    try {
      // Send the GET request
      http.Response resp = await _client
          .get(
            Uri(path: "$baseUrl/api/messages"),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      // Extremely hard construction
      //
      // JSON (as Map<String, dynamic>)
      //   -> JSON["data"] (as List<Map<String, dynamic>>)
      //      -> JSON["data"] -> Iteratable<Map<String, dynamic>>
      //        -> Iteratable<Map<String, dynamic>> -> Iteratable<Message>
      //          -> Iteratable<Message> -> List<Message>
      //
      // Converts json["data"] from List<Map<String, dynamic>> to List<Message>
      return _handleResponse(
          resp,
          (json) => (((json)["data"] as List)
              .map((val) => Message.fromJSON(val))).toList());
    } catch (connErr) {
      // Failed to send the request / get the response
      throw UnimplementedError(); // makes +1 test
      // throw NetworkException("Error when getting messages");
    }
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    String? validErr = request.validate();
    if (validErr != null) {
      throw NetworkException("Validation error");
    }

    try {
      // Send the POST request
      http.Response resp = await _client
          .post(
            Uri.parse("$baseUrl/api/messages/"),
            headers: _getHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(timeout);

      // Decode the response and create a new message
      return _handleResponse(resp, (json) => Message.fromJSON(json));
    } catch (connErr) {
      // Failed to send the request / get the response
      throw UnimplementedError(); // makes +1 test
      // throw NetworkException("Error when creating a message");
    }
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    String? validateErr = request.validate();
    if (validateErr != null) {
      throw UnimplementedError(); // makes +1 test
      // throw NetworkException("Validation error");
    }

    try {
      // Send the request
      http.Response resp = await _client
          .put(
            Uri.parse("$baseUrl/api/messages/$id"),
            headers: _getHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(timeout);

      // Send to the processor
      return _handleResponse(resp, (json) => Message.fromJSON(json));
    } catch (connErr) {
      // Failed to send the request / get the response
      throw UnimplementedError(); // makes +1 test
      // throw NetworkException("Error when updating a message");
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    try {
      // Send the request
      http.Response resp = await _client
          .delete(
            Uri.parse("$baseUrl/api/messages/$id"),
            headers: _getHeaders(),
            body: jsonEncode({}),
          )
          .timeout(timeout);

      // Send to the processor
      if (resp.statusCode == 204) return; // OK
      // Unexpected error
      throw NetworkException("Error when deleting a message");
    } catch (connErr) {
      // Failed to send the request / get the response
      throw UnimplementedError(); // makes +1 test
      // throw NetworkException("Error when deleting a message");
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      // Send the request
      http.Response resp = await _client
          .get(
            Uri.parse("$baseUrl/api/status/$statusCode"),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      // Parse
      return _handleResponse(resp, (json) => HTTPStatusResponse.fromJson(json));
    } catch (connErr) {
      // Failed to send the request / get the response
      throw UnimplementedError(); // makes +1 test
      // throw NetworkException("Error when getting a status code");
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      // Send the request
      http.Response resp = await _client
          .get(
            Uri.parse("$baseUrl/api/health"),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      // Parse
      return _handleResponse(resp, (json) => (json));
    } catch (connErr) {
      // Failed to send the request / get the response
      throw UnimplementedError(); // makes +1 test
      // throw NetworkException("Error when making a health check");
    }
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() {
    return "ApiException: $message";
  }
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}

class ValidationException extends ApiException {
  ValidationException(super.message);
}
