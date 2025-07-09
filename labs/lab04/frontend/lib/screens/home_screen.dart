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

            // SharedPreferences Section
            _buildStorageSection(
              'SharedPreferences',
              'Simple key-value storage for app settings',
              [
                ElevatedButton(
                  onPressed: _testSharedPreferences,
                  child: const Text('Test SharedPreferences'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _clearSharedPreferences,
                  child: const Text('Clear SharedPreferences'),
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
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _clearSQLite,
                  child: const Text('Clear SQLite'),
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
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _clearSecureStorage,
                  child: const Text('Clear Secure Storage'),
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
      _statusMessage = 'Testing SharedPreferences...';
    });

    try {
      await PreferencesService.init();

      // Test basic data types
      await PreferencesService.setString('test_string', 'Hello from SharedPreferences!');
      await PreferencesService.setInt('test_int', 42);
      await PreferencesService.setBool('test_bool', true);
      
      // Test object storage
      final testObject = {'name': 'Test Object', 'value': 123};
      await PreferencesService.setObject('test_object', testObject);

      // Verify all stored values
      final results = '''
SharedPreferences Test Results:
String: ${PreferencesService.getString('test_string')}
Int: ${PreferencesService.getInt('test_int')}
Bool: ${PreferencesService.getBool('test_bool')}
Object: ${PreferencesService.getObject('test_object')}
''';

      setState(() {
        _statusMessage = results;
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

  Future<void> _clearSharedPreferences() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Clearing SharedPreferences...';
    });

    try {
      await PreferencesService.clear();
      setState(() {
        _statusMessage = 'SharedPreferences cleared successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to clear SharedPreferences: $e';
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
      // Create test user
      final user = await DatabaseService.createUser(
        CreateUserRequest(name: 'Test User', email: 'test@example.com')
      );

      // Test CRUD operations
      final initialCount = await DatabaseService.getUserCount();
      final allUsers = await DatabaseService.getAllUsers();
      final updatedUser = await DatabaseService.updateUser(
        user.id, 
        {'name': 'Updated Name'}
      );
      await DatabaseService.deleteUser(user.id);
      final finalCount = await DatabaseService.getUserCount();

      setState(() {
        _statusMessage = '''
SQLite Test Results:
Initial user count: $initialCount
Created user ID: ${user.id}
All users count: ${allUsers.length}
Updated name: ${updatedUser.name}
Final user count: $finalCount
''';
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

  Future<void> _clearSQLite() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Clearing SQLite database...';
    });

    try {
      await DatabaseService.clearAllData();
      setState(() {
        _statusMessage = 'SQLite database cleared successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to clear SQLite database: $e';
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
      // Test secure data storage
      await SecureStorageService.saveSecureData('test_secure', 'Sensitive data');
      await SecureStorageService.saveAuthToken('test_auth_token');
      
      // Test credentials storage
      await SecureStorageService.saveUserCredentials('test_user', 'test_password');
      
      // Test object storage
      final secureObject = {'key': 'secure_value'};
      await SecureStorageService.saveObject('test_object', secureObject);

      // Verify stored data
      final results = '''
Secure Storage Test Results:
Secure Data: ${await SecureStorageService.getSecureData('test_secure')}
Auth Token: ${await SecureStorageService.getAuthToken()}
Credentials: ${await SecureStorageService.getUserCredentials()}
Object: ${await SecureStorageService.getObject('test_object')}
''';

      setState(() {
        _statusMessage = results;
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

  Future<void> _clearSecureStorage() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Clearing Secure Storage...';
    });

    try {
      await SecureStorageService.clearAll();
      setState(() {
        _statusMessage = 'Secure Storage cleared successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to clear Secure Storage: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}