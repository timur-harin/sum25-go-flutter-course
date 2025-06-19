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
    return Container(
      height: 100,
      margin: const EdgeInsets.all(20),
      child: Column(
        spacing: 20,
        children: [
          const Text("Counter"),
          Text("$_counter"),
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: _decrement, child: const Icon(Icons.remove)),
              ElevatedButton(onPressed: _reset, child: const Icon(Icons.refresh)),
              ElevatedButton(onPressed: _increment, child: const Icon(Icons.add))
            ]
          )
        ]
      ),
    );
  }
}
