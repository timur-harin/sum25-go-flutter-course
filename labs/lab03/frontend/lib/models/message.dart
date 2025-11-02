// ... (Message, CreateMessageRequest, UpdateMessageRequest, HTTPStatusResponse remain the same) ...

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse({required this.success, this.data, this.error});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic json)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false, // Handle null success safely
      data: json.containsKey('data') && json['data'] != null
          ? fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T
          : null, // If 'data' key doesn't exist or is null, data is null
      error: json['error'] as String?,
    );
  }
}