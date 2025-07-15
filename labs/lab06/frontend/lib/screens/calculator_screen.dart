import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _bController = TextEditingController();

  CalculatorResult? _lastResult;
  List<HistoryEntry> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _aController.text = '10';
    _bController.text = '5';
    _loadHistory();
  }

  @override
  void dispose() {
    _apiService.dispose();
    _aController.dispose();
    _bController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final historyResponse = await _apiService.getHistory();
      setState(() {
        _history = historyResponse.entries;
      });
    } catch (e) {
      // Silently ignore errors during testing or when backend is not available
      if (e.toString().contains('400') ||
          e.toString().contains('Failed to get history')) {
        // This is expected during testing - don't print errors
        return;
      }
      print('Failed to load history: $e');
    }
  }

  Future<void> _performOperation(String operation) async {
    final a = double.tryParse(_aController.text);
    final b = double.tryParse(_bController.text);

    if (a == null || b == null) {
      setState(() {
        _errorMessage = 'Please enter valid numbers';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      CalculatorResult result;

      switch (operation) {
        case 'add':
          result = await _apiService.add(a, b);
          break;
        case 'subtract':
          result = await _apiService.subtract(a, b);
          break;
        case 'multiply':
          result = await _apiService.multiply(a, b);
          break;
        case 'divide':
          result = await _apiService.divide(a, b);
          break;
        default:
          throw Exception('Unknown operation: $operation');
      }

      setState(() {
        _lastResult = result;
        _isLoading = false;
      });

      // Refresh history after successful operation
      if (result.success) {
        await _loadHistory();
      }

      if (!result.success && result.error != null) {
        setState(() {
          _errorMessage = result.error;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  String _getOperationSymbol(String operation) {
    switch (operation) {
      case 'add':
        return '+';
      case 'subtract':
        return '-';
      case 'multiply':
        return '×';
      case 'divide':
        return '÷';
      default:
        return operation;
    }
  }

  String _formatNumber(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    } else {
      return number.toStringAsFixed(2);
    }
  }

  Widget _buildCalculatorButton({
    required String operation,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : () => _performOperation(operation),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator (HTTP → gRPC)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'Refresh History',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.all(12.0), // Reduced from 16.0 to fix overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Calculator Inputs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _aController,
                              decoration: const InputDecoration(
                                labelText: 'First Number (A)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _bController,
                              decoration: const InputDecoration(
                                labelText: 'Second Number (B)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Calculator Buttons
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Operations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildCalculatorButton(
                            operation: 'add',
                            label: '+ Add',
                            color: Colors.green,
                          ),
                          _buildCalculatorButton(
                            operation: 'subtract',
                            label: '- Subtract',
                            color: Colors.orange,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildCalculatorButton(
                            operation: 'multiply',
                            label: '× Multiply',
                            color: Colors.blue,
                          ),
                          _buildCalculatorButton(
                            operation: 'divide',
                            label: '÷ Divide',
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Result Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Result',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('Calculating...'),
                          ],
                        )
                      else if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_lastResult != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _lastResult!.success
                                ? Colors.green[50]
                                : Colors.red[50],
                            border: Border.all(
                              color: _lastResult!.success
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _lastResult!.success
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: _lastResult!.success
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _lastResult!.success ? 'Success' : 'Error',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _lastResult!.success
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Operation: ${_lastResult!.operation}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Result: ${_formatNumber(_lastResult!.result)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_lastResult!.error != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Error: ${_lastResult!.error}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ],
                          ),
                        )
                      else
                        const Text(
                          'Perform a calculation to see results',
                          style: TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // History Section
              SizedBox(
                height: 300, // Fixed height instead of Expanded
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Calculation History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _history.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No calculations yet.\nPerform some operations to see history.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _history.length,
                                  itemBuilder: (context, index) {
                                    final entry = _history[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue[100],
                                        child: Text(
                                          _getOperationSymbol(entry.operation),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        '${_formatNumber(entry.a)} ${_getOperationSymbol(entry.operation)} ${_formatNumber(entry.b)} = ${_formatNumber(entry.result)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      subtitle: Text(
                                        entry.timestamp
                                            .toString()
                                            .substring(0, 19),
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      onTap: () {
                                        // Fill inputs with historical values
                                        _aController.text =
                                            _formatNumber(entry.a);
                                        _bController.text =
                                            _formatNumber(entry.b);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
