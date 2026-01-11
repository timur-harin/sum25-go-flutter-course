import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider(this._apiService);

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // TODO: Add loadMessages() method
  Future<void> loadMessages() async {
    try {
      _isLoading = true;
      notifyListeners();
      _messages = await _apiService.getMessages();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // Set loading state, call API, update messages, handle errors

  // TODO: Add createMessage(CreateMessageRequest request) method
  // Call API to create message, add to local list
  Future<void> createMessage(CreateMessageRequest request) async {
    try {
      _isLoading = true;
      notifyListeners();
      final newMessage = await _apiService.createMessage(request);
      _messages.add(newMessage);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // TODO: Add updateMessage(int id, UpdateMessageRequest request) method
  // Call API to update message, update in local list

  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
    try {
      _isLoading = true;
      notifyListeners();
      final updatedMessage = await _apiService.updateMessage(id, request);
      final index = _messages.indexWhere((msg) => msg.id == id);
      if (index != -1) {
        _messages[index] = updatedMessage;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // TODO: Add deleteMessage(int id) method
  // Call API to delete message, remove from local list

  Future<void> deleteMessage(int id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _apiService.deleteMessage(id);
      _messages.removeWhere((msg) => msg.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // TODO: Add refreshMessages() method
  // Clear current messages and reload from API
  Future<void> refreshMessages() async {
    try {
      _isLoading = true;
      _messages = [];
      notifyListeners();
      _messages = await _apiService.getMessages();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
