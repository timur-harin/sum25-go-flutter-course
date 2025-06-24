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
    // TODO: Implement counter UI
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Counter'),
      ),
      body: Container(
        child: Column(
          children: [
            Text(_counter.toString()),
            IconButton(onPressed: _increment, icon: Icon(Icons.add)),
            IconButton(onPressed: _decrement, icon: Icon(Icons.remove)),
            IconButton(onPressed: _reset, icon: Icon(Icons.refresh))
          ],
        )
      ),
    );
  }
}
