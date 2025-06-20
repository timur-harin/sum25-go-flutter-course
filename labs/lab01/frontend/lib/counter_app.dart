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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Counter Example App")
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 70,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "$_counter",
                  style: const TextStyle(
                    fontSize: 50
                  ),
                ),
              )
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _increment, 
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.green,
                minimumSize: const Size(200, 50)
              ),
              child: const Icon(Icons.add)
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _decrement,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.blue,
                minimumSize: const Size(200, 50)
              ),
              child: const Icon(Icons.remove)
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _reset,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.red,
                minimumSize: const Size(200, 50)
              ),
              child: const Icon(Icons.refresh)
            )
          ],
        ),
      ),
    );
  }
}