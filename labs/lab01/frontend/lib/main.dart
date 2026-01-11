import 'package:flutter/material.dart';
import 'profile_card.dart';
import 'counter_app.dart';
import 'registration_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo Suite',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Suite'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.exposure_plus_1), text: 'Counter'),
            Tab(icon: Icon(Icons.app_registration), text: 'Register'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: ProfileCard(
                name: 'Alice Smith',
                age: 30,
                email: 'alice.smith@example.com',
              ),
            ),
          ),
          Center(child: CounterApp()),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: RegistrationForm(),
            ),
          ),
        ],
      ),
    );
  }
}
