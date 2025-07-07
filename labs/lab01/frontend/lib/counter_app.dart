import 'package:flutter/material.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({Key? key}) : super(key: key);

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int _counter = 0;

  void _incrementCounter() {
    setState((){
      _counter+=1;
    });
    // TODO: Implement this function
  }

  void _decrementCounter() {
    // TODO: Implement this function
    setState((){
      _counter-=1;
    });
  }

  void _resetCounter() {
    // TODO: Implement this function
    setState((){
      _counter=0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter App'),
        actions: [
          // TODO: add a refresh button with Icon(Icons.refresh)
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 225, 199, 0),
                  Color.fromARGB(255, 221, 0, 213),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              border: Border.all(
                color: Color.fromARGB(255, 39, 39, 39)
              ),
              borderRadius: BorderRadius.circular(20)
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetCounter,
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_counter',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TODO: add a decrement button with Icon(Icons.remove) and onPressed: _decrementCounter
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 225, 199, 0),
                        Color.fromARGB(255, 221, 0, 213),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    border: Border.all(
                      color: Color.fromARGB(255, 39, 39, 39)
                    ),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: FloatingActionButton(
                    onPressed: _decrementCounter,
                    child: const Icon(Icons.remove),
                  ),
                ),
                
                const SizedBox(width: 32),
                // TODO: add a increment button with Icon(Icons.add) and onPressed: _incrementCounter
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 225, 199, 0),
                        Color.fromARGB(255, 221, 0, 213),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    border: Border.all(
                      color: Color.fromARGB(255, 39, 39, 39)
                    ),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: FloatingActionButton(
                    onPressed: _incrementCounter,
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
