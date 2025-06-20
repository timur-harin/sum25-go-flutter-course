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
      _counter--; // Убрали проверку на > 0, чтобы разрешить отрицательные значения
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
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Count:',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              '$_counter', // Будет показывать и отрицательные числа
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _decrement,
                  tooltip: 'Decrement',
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _reset,
                  tooltip: 'Reset',
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _increment,
                  tooltip: 'Increment',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}