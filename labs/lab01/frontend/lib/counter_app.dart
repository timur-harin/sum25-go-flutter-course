import 'package:flutter/material.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$_counter', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _decrement,
                  icon: const Icon(Icons.remove),
                  tooltip: 'Decrement',
                ),
                IconButton(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset',
                ),
                IconButton(
                  onPressed: _increment,
                  icon: const Icon(Icons.add),
                  tooltip: 'Increment',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
