// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/message.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // базовые поля — пригодятся позже
  final ApiService _apiService = ApiService();
  final List<Message> _messages = [];
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  // Заглушки — пока не нужны тестам
  Future<void> _loadMessages() async =>
      throw UnimplementedError('Implement _loadMessages');
  Future<void> _sendMessage() async =>
      throw UnimplementedError('Implement _sendMessage');
  Future<void> _editMessage(Message msg) async =>
      throw UnimplementedError('Implement _editMessage');
  Future<void> _deleteMessage(Message msg) async =>
      throw UnimplementedError('Implement _deleteMessage');
  Future<void> _showHTTPStatus(int code) async =>
      throw UnimplementedError('Implement _showHTTPStatus');

  // Плейсхолдеры-заглушки
  Widget _buildMessageTile(Message m) => const SizedBox.shrink();
  Widget _buildMessageInput() => const SizedBox.shrink();
  Widget _buildErrorWidget() => const SizedBox.shrink();
  Widget _buildLoadingWidget() => const Center(child: CircularProgressIndicator());

  @override
  Widget build(BuildContext context) {
    // Чтобы import provider не считался «неиспользуемым»
    final _ = Provider.of<ApiService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Chat'),
      ),
      body: Center(
        child: _isLoading
            ? _buildLoadingWidget()
            : _error != null
                ? _buildErrorWidget()
                : const Text('TODO: Implement chat functionality'),
      ),
    );
  }
}

// Заглушки для демонстрации HTTP-котиков
class HTTPStatusDemo {
  static Future<void> showRandomStatus(
          BuildContext context, ApiService api) async =>
      throw UnimplementedError('Implement showRandomStatus');

  static Future<void> showStatusPicker(
          BuildContext context, ApiService api) async =>
      throw UnimplementedError('Implement showStatusPicker');
}
