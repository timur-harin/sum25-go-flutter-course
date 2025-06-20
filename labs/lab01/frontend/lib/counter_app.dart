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
    // TODO: Implement counter UI
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("$_counter"),
        IconButton(
          onPressed: _increment,
          icon: const Icon(Icons.add),
        ),
        IconButton(
          onPressed: _decrement,
          icon: const Icon(Icons.remove),
        ),
        IconButton(onPressed: _reset, icon: const Icon(Icons.refresh))
      ],
    );
  }
}
