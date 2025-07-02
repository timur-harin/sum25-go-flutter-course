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
          title: Text("Counter App"),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$_counter'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(onPressed: _increment, child: const Icon(Icons.add)),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: _decrement,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
            const SizedBox(height: 20),
            IconButton(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
            ),
          ],
        )));
  }
}
