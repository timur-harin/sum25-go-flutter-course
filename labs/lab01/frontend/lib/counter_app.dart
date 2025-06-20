import 'package:flutter/material.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int _counter = 0;

  void _increment() {
    // TODO: Implement increment
    setState(() {
      _counter ++;
    });
  }

  void _decrement() {
    // TODO: Implement decrement
    setState(() {
      _counter --;
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
      appBar: AppBar(
        title: const Text('CounterApp'),

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_counter',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 24),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: _increment, icon: Icon(Icons.add)),
                  const SizedBox(width: 16),
                  IconButton(onPressed: _decrement, icon: Icon(Icons.remove)),
                  const SizedBox(width: 16),
                  IconButton(onPressed: _reset, icon: Icon(Icons.refresh))
                ]
            )
          ],
        ),

      )
    );
  }
}
