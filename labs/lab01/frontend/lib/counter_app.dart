import 'package:flutter/material.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({Key? key}) : super(key: key);

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int _counter = 0;

  void _increment() {
    _counter++;
  }

  void _decrement() {
    _counter--;
  }

  void _reset() {
    _counter = 0;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement counter UI
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _counter.toString(),
            style: TextStyle(
              fontSize: 20
            ),
          ),
          Row(
            children: [
              TextButton(onPressed: () {
                  setState(() {
                    _increment();
                  });
                },
                child: const Icon(Icons.add)
              ),
              TextButton(onPressed: () {
                setState(() {
                  _decrement();
                });
              },
                  child: const Icon(Icons.remove)
              ),
              TextButton(onPressed: () {
                setState(() {
                  _reset();
                });
              },
                  child: const Icon(Icons.refresh)
              )
            ],
          )
        ],
      ),
    );
  }
}
