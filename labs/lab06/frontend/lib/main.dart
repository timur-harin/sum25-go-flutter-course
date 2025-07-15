import 'package:flutter/material.dart';
import 'screens/websocket_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/status_screen.dart';

void main() {
  runApp(const Lab06App());
}

class Lab06App extends StatelessWidget {
  const Lab06App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 06: gRPC & WebSocket',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/websocket': (context) => const WebSocketScreen(),
        '/calculator': (context) => const CalculatorScreen(),
        '/status': (context) => const StatusScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 06: Microservices & Communication'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome to Lab 06!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'This lab demonstrates gRPC microservices and WebSocket communication. '
              'Choose a feature to explore:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // WebSocket Chat Card
            Card(
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/websocket'),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat,
                        size: 48,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'WebSocket Chat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Real-time messaging with time delays and connection management',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Calculator gRPC Card
            Card(
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/calculator'),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calculate,
                        size: 48,
                        color: Colors.green,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Calculator (gRPC)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'HTTP Gateway to gRPC Calculator microservice',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Service Status Card
            Card(
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/status'),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.monitor_heart,
                        size: 48,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Service Monitor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Monitor microservices health and performance',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            const Text(
              'Lab 06 Architecture:\n'
              '• Flutter → HTTP → Gateway Service\n'
              '• Gateway → gRPC → Calculator Service\n'
              '• Flutter → WebSocket → Message Service',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
