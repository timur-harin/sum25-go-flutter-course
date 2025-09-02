import 'package:flutter/material.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({Key? key}) : super(key: key);

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int _counter = 0;

  // Method to increment counter by one and to update the user interface
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // Method to decrement counter and to update the user interface
  void _decrementCounter() {
    setState(() {
        _counter--;
    });
  }

  // Method to reset counter to 0 and to update the user interface
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
        actions: [
          // Refresh button with appropriate icon, this button calls _resetCounter to reset counter to zero
          IconButton(
            onPressed: _resetCounter,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Displaying the current counter value
            Text(
              '$_counter',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decrement button with icon "-", this button calls _decrementCounter to decrement counter by one
                FloatingActionButton(
                  onPressed: _decrementCounter,
                  child: const Icon(Icons.remove),
                ),
                
                const SizedBox(width: 32),
                // Increment button with icon "+", this button calls _incrementCounter to increment counter by one
                FloatingActionButton(
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
