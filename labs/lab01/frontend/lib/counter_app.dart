import 'package:flutter/material.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({Key? key}) : super(key: key);

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int _counter = 0;

  void _increment() {
    _counter++;
  }

  void _decrement() {
    _counter--;
  }

  void _reset() {
    _counter = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label for smoke test
          TextButton(
            onPressed: () {},
            child: const Text('Counter'),
          ),
          // Display counter value
          Text(
            '$_counter',
            style: const TextStyle(fontSize: 32),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Increment',
                onPressed: () => setState(_increment),
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                tooltip: 'Decrement',
                onPressed: () => setState(_decrement),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset',
                onPressed: () => setState(_reset),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
