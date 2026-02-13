import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class UserService {
  final Random _random = Random();
  bool _simulateFailure = false;
  bool _simulateDelay = true;

  /// Опциональные параметры для тестирования
  UserService({
    bool simulateFailure = false,
    bool simulateDelay = true,
  })  : _simulateFailure = simulateFailure,
        _simulateDelay = simulateDelay;

  /// Получает данные пользователя
  Future<Map<String, String>> fetchUser() async {
    // Симулируем задержку сети (по умолчанию 500-1000 мс)
    if (_simulateDelay) {
      await Future.delayed(
        Duration(milliseconds: 500 + _random.nextInt(500)),
      );
    }

    // Симулируем случайные ошибки (если включено)
    if (_simulateFailure && _random.nextDouble() > 0.7) {
      throw Exception('Failed to fetch user data');
    }

    // Возвращаем mock-данные пользователя
    return {
      'name': 'User${_random.nextInt(1000)}', // Случайное имя пользователя
      'email': 'user${_random.nextInt(1000)}@example.com', // Случайный email
    };
  }

  /// Для тестов: включить/выключить симуляцию ошибок
  @visibleForTesting
  void setSimulateFailure(bool value) {
    _simulateFailure = value;
  }

  /// Для тестов: включить/выключить симуляцию задержки
  @visibleForTesting
  void setSimulateDelay(bool value) {
    _simulateDelay = value;
  }
}
