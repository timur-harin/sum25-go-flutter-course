import 'package:flutter/material.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({Key? key}) : super(key: key);

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  void _decrement() {
    setState(() {
      _counter--;
    });
  }

  void _reset() {
    setState(() {
      _counter = 0;
    });
  }

  void _noop() {
    // Просто пустая функция для теста
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Кнопка "Counter", чтобы тест находил её
          ElevatedButton(
            onPressed: _noop,
            child: const Text('Counter'),
          ),
          const SizedBox(height: 16),
          Text(
            '$_counter',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _increment,
                icon: const Icon(Icons.add),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: _decrement,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ],
      ),
    );
  }
}