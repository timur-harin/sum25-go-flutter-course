import 'package:flutter/material.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({Key? key}) : super(key: key);

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter App'),
      ),
      body: Center(
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Current value:'),
                const SizedBox(height: 8),
                Text(
                  '$_counter',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      onPressed: _decrementCounter,
                      tooltip: 'Decrement',
                      heroTag: 'decrement',
                      mini: true,
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(width: 20),
                    FloatingActionButton(
                      onPressed: _incrementCounter,
                      tooltip: 'Increment',
                      heroTag: 'increment',
                      mini: true,
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _resetCounter,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}