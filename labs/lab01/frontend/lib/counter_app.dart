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
      _counter=0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column (
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
            Text('Counter', style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),),
          const SizedBox(height: 16),
            Text('$_counter',
              key: const Key('counterValue'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    key: const Key("decrement"),
                    onPressed: _decrement,
                    icon: const Icon(Icons.remove),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(250, 70),
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  ),
                  IconButton(
                    key: const Key("reset"),
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(250, 70),
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  ),
                  IconButton(
                    key: const Key("increment"),
                    onPressed: _increment,
                    icon: const Icon(Icons.add),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(250, 70),
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  ),
                ],
              ),
        ],
      )
    );
  }
}
