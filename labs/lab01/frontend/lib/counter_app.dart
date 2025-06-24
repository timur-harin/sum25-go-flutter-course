import 'package:flutter/material.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({Key? key}) : super(key: key);

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int _counter = 0;

  void _increment() {
    setState((){
      _counter++;
    });
  }

  void _decrement() {
    setState((){
      _counter--;
    });
  }

  void _reset() {
    setState(({
      _cuonter = 0;
    }))
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children:[
            Text(
              'Counter: $_counter',
              style: const TextStyle(fontSize: 24),
            ),Row(
              children: [
                ElevatedButton(
                  onPressed: _increment,
                  child: const Text('Increment'),
                ),
                ElevatedButton(
                  onPressed: _decrement,
                  child: const Text('Decrement'),
                ),
                ElevatedButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
              ]
            )
          ]
        )
      )
    )
  }
}
