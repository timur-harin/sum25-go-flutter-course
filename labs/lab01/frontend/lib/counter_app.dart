import 'package:flutter/material.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

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
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          border: BoxBorder.fromBorderSide(BorderSide(color: Colors.black12)),
        boxShadow: [BoxShadow(color: Colors.black12)]
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Counter'),
                Text(': $_counter')
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(onPressed: _increment, icon: const Icon(Icons.add)),
                IconButton(onPressed: _decrement, icon: const Icon(Icons.remove)),
                IconButton(onPressed: _reset, icon: const Icon(Icons.refresh))
              ],
            )
          ],
        ),
      ),
    );
  }
}
