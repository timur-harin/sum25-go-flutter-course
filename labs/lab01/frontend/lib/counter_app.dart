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
      _counter += 1;
    });
  }

  void _decrement() {
    setState(() {
      _counter -= 1;
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
        child: Column(children: [
      TextButton(
        onPressed: null,
        child: Text(
          "Counter",
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05),
        ),
      ),
      Text("$_counter"),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(onPressed: _increment, icon: Icon(Icons.add)),
          IconButton(onPressed: _reset, icon: Icon(Icons.refresh)),
          IconButton(onPressed: _decrement, icon: Icon(Icons.remove)),
        ],
      ),
    ]));
  }
}
