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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter App'),
        actions: [
          ElevatedButton(
            onPressed: _reset,
            child: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_counter',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
            onPressed: _decrement,
            child: Icon(Icons.remove),
          ),
                
                const SizedBox(width: 32),
                FloatingActionButton(
            onPressed: _increment,
            child: Icon(Icons.add),
          ),
                
              ],
            ),
          ],
        ),
      ),
    );
  }
}
