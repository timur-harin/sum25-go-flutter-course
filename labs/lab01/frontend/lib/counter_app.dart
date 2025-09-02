import 'package:flutter/material.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({Key? key}) : super(key: key);

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int _counter = 0;

  void _incrementCounter() {
    // TODO: Implement this function
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    // TODO: Implement this function
    setState(() {
      _counter--;
    });
  }

  void _resetCounter() {
    // TODO: Implement this function
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
          // TODO: add a refresh button with Icon(Icons.refresh)
          IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _resetCounter,
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
                // TODO: add a decrement button with Icon(Icons.remove) and onPressed: _decrementCounter
                FloatingActionButton(
                  heroTag: 'decrement',
                  onPressed: _decrementCounter,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 32),
                // TODO: add a increment button with Icon(Icons.add) and onPressed: _incrementCounter
                FloatingActionButton(
                  heroTag: 'increment',
                  onPressed: _incrementCounter,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
