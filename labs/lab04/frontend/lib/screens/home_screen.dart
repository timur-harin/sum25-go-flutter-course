import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/database_service.dart';
import '../services/secure_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _statusMessage = 'Welcome to Lab 04 - Database & Persistence';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 04 - Database & Persistence'),
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      _statusMessage = 'Checking SharedPreferences functionality...';
    });
    try {
      await PreferencesService.setBool('pref_test', true);
      final result = PreferencesService.getBool('pref_test');
      setState(() {
        _statusMessage = 'SharedPreferences outcome: $result';
      });
    } catch (exception) {
      setState(() {
        _statusMessage = 'Error in SharedPreferences test: $exception';
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
      _statusMessage = 'Examining SQLite database...';
    });
    try {
      int totalUsers = await DatabaseService.getUserCount();
      setState(() {
        _statusMessage = 'SQLite check: Discovered $totalUsers users';
      });
    } catch (error) {
      setState(() {
        _statusMessage = 'SQLite error: $error';
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
      _statusMessage = 'Evaluating Secure Storage...';
    });
    try {
      await SecureStorageService.saveSecureData('secure_key', 'Confidential info');
      final retrieved = await SecureStorageService.getSecureData('secure_key');
      setState(() {
        _statusMessage = 'Secure Storage outcome: $retrieved';
      });
    } catch (error) {
      setState(() {
        _statusMessage = 'Secure Storage error: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}