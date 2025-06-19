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
      _counter += 1;
    });
  }

  void _decrement() {
    setState(() {
      _counter -= 1;
    });
  }

  void _reset() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(onPressed: _reset, child: const Text('Counter')),
        Text(
          '$_counter',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _increment,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: _decrement,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
            ),
          ],
        ),
      ],
    );
  }
}
