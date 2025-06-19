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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Counter"),
        Text("$_counter"),
        Row(
          children: [
            IconButton(
              onPressed: _increment,
              icon: const Icon(Icons.add),
            ),
            IconButton(
              onPressed: _decrement,
              icon: const Icon(Icons.remove),
            ),
            IconButton(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ],
    );
  }
}
