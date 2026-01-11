import 'package:flutter/material.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  State<CounterApp> createState() => _CounterAppState();
}

// Private implementation of the CounterApp logic
// Private implementation of the CounterApp logic
class _CounterAppState extends State<CounterApp> {
  int _counter = 0;

  void _increment() {
    setState(() {
      // to redraw the window (widget)
      _counter++;
    });
  }

  void _decrement() {
    setState(() {
      _counter--;
    });
  }

  // Sets counter to it's initial value (0)
  // Sets counter to it's initial value (0)
  void _reset() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Home screen
    return Scaffold(
        appBar: AppBar(
          title: const Text("Counter App"),
          actions: [
            // Reset button
            ElevatedButton(
              onPressed: _reset,
              child: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("$_counter"), // cannot be const

            const SizedBox(height: 20.0), // margin bottom-top

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decrement button
                FloatingActionButton(
                  onPressed: _decrement,
                  child: const Icon(Icons.remove),
                ),

                const SizedBox(width: 20.0), // to split buttons

                const SizedBox(width: 20.0),

                FloatingActionButton(
                  onPressed: _increment,
                  child: const Icon(Icons.add),
                ),
              ],
            )
          ]),
        ));
  }
}
