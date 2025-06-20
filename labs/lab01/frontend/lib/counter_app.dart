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
    // TODO: Implement decrement
    setState(() {
      _counter--;
    });
  }

  void _reset() {
    // TODO: Implement reset
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement counter UI
    return Scaffold(
      // appBar: AppBar(title: const Text("Counter")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text('$_counter', style: const TextStyle(fontSize: 24)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Counter'),
                    const SizedBox(width: 2.0),
                    Text('$_counter')
                  ],
                ),
                IconButton(
                    icon: const Icon(Icons.remove), onPressed: _decrement),
                IconButton(icon: const Icon(Icons.add), onPressed: _increment),
                IconButton(icon: const Icon(Icons.refresh), onPressed: _reset),
              ],
            )
          ],
        ),
      ),
    );
  }
}
