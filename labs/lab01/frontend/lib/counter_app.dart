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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            const Text('Counter'),
            const SizedBox(width: 2),
            Text('$_counter'),
          ],
        ),
        IconButton(
          onPressed: _increment, icon: Icon(Icons.add)
        ),
        IconButton(
          onPressed: _decrement, icon: Icon(Icons.remove)
        ),
        IconButton(
          onPressed: _reset, icon: Icon(Icons.refresh)
        ),
      ]
    );
  }
}
