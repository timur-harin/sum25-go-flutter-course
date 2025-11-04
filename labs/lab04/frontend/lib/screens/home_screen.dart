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
        title: const Text(
          'Lab 04 - Database & Persistence',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFF8F9FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _statusMessage,
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.grey,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: const Text(
                  'Storage Options',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SharedPreferences Section
              _buildStorageSection(
                'SharedPreferences',
                'Simple key-value storage for app settings',
                Icons.settings,
                const LinearGradient(
                  colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)],
                ),
                [
                  ElevatedButton(
                    onPressed: _testSharedPreferences,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Test SharedPreferences'),
                  ),
                ],
              ),

              // SQLite Section
              _buildStorageSection(
                'SQLite Database',
                'Local SQL database for structured data',
                Icons.storage,
                const LinearGradient(
                  colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
                ),
                [
                  ElevatedButton(
                    onPressed: _testSQLite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Test SQLite'),
                  ),
                ],
              ),

              // Secure Storage Section
              _buildStorageSection(
                'Secure Storage',
                'Encrypted storage for sensitive data',
                Icons.security,
                const LinearGradient(
                  colors: [Color(0xFFFFB74D), Color(0xFFFFA726)],
                ),
                [
                  ElevatedButton(
                    onPressed: _testSecureStorage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Test Secure Storage'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStorageSection(
      String title, String description, IconData icon, Gradient gradient, List<Widget> buttons) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: gradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: buttons,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _testSharedPreferences() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing SharedPreferences...';
    });

    try {
      // TODO: Implement SharedPreferences test
      // This will test when students implement the methods

      await PreferencesService.setString(
          'test_key', 'Hello from SharedPreferences!');
      final value = PreferencesService.getString('test_key');

      setState(() {
        _statusMessage = 'SharedPreferences test result: $value';
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
      _statusMessage = 'Testing SQLite database...';
    });

    try {
      // TODO: Implement SQLite test
      // This will test when students implement the methods

      final userCount = await DatabaseService.getUserCount();

      setState(() {
        _statusMessage =
            'SQLite test result: Found $userCount users in database';
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
      _statusMessage = 'Testing Secure Storage...';
    });

    try {
      // TODO: Implement Secure Storage test
      // This will test when students implement the methods

      await SecureStorageService.saveSecureData('test_secure', 'Secret data');
      final value = await SecureStorageService.getSecureData('test_secure');

      setState(() {
        _statusMessage = 'Secure Storage test result: $value';
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
