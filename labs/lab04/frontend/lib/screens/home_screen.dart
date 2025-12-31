import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/database_service.dart';
import '../services/secure_storage_service.dart';
import '../models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _statusMessage = 'Welcome to Lab 04 – Database & Persistence';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Initializing services…';
    });
    try {
      // Initialize SharedPreferences
      await PreferencesService.init();
      // Warm up SQLite
      await DatabaseService.database;
      setState(() {
        _statusMessage = 'All services ready!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Initialization failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 04 – Database & Persistence'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Storage Options',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // SharedPreferences Section
            _buildStorageSection(
              'SharedPreferences',
              'Simple key-value storage for app settings',
              [
                ElevatedButton(
                  onPressed: _testSharedPreferences,
                  child: const Text('Test SharedPreferences'),
                ),
              ],
            ),

            // SQLite Section
            _buildStorageSection(
              'SQLite Database',
              'Local SQL database for structured data',
              [
                ElevatedButton(
                  onPressed: _testSQLite,
                  child: const Text('Test SQLite'),
                ),
              ],
            ),

            // Secure Storage Section
            _buildStorageSection(
              'Secure Storage',
              'Encrypted storage for sensitive data',
              [
                ElevatedButton(
                  onPressed: _testSecureStorage,
                  child: const Text('Test Secure Storage'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSection(
      String title, String description, List<Widget> buttons) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: buttons,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testSharedPreferences() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing SharedPreferences…';
    });

    try {
      const key = 'test_key';
      const testValue = 'Hello from SharedPreferences!';
      await PreferencesService.setString(key, testValue);

      final value = PreferencesService.getString(key);
      setState(() {
        _statusMessage = 'SharedPreferences test: "$value"';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'SharedPreferences test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSQLite() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing SQLite database…';
    });

    try {
      // ensure table exists and start fresh for demo
      await DatabaseService.clearAllData();

      // insert a couple of users
      await DatabaseService.createUser(
          CreateUserRequest(name: 'Bob', email: 'bob@example.com'));
      await DatabaseService.createUser(
          CreateUserRequest(name: 'Carol', email: 'carol@example.com'));

      final userCount = await DatabaseService.getUserCount();
      setState(() {
        _statusMessage = 'SQLite test: $userCount users found';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'SQLite test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSecureStorage() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing Secure Storage…';
    });

    try {
      const key = 'test_secure';
      const secret = 'Secret data';
      await SecureStorageService.saveSecureData(key, secret);
      final value = await SecureStorageService.getSecureData(key);
      setState(() {
        _statusMessage = 'Secure Storage test: "$value"';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Secure Storage test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
