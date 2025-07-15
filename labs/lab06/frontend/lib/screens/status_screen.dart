import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import 'package:http/http.dart' as http;

class ServiceStatus {
  final String name;
  final String url;
  final bool isHealthy;
  final Duration? responseTime;
  final String? error;
  final DateTime lastChecked;

  ServiceStatus({
    required this.name,
    required this.url,
    required this.isHealthy,
    this.responseTime,
    this.error,
    required this.lastChecked,
  });
}

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final ApiService _apiService = ApiService();
  final WebSocketService _webSocketService = WebSocketService();

  List<ServiceStatus> _services = [];
  bool _isRefreshing = false;
  Timer? _autoRefreshTimer;
  bool _autoRefreshEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeServices(); // Services show up immediately

    // Start background refresh after a delay (doesn't affect initial display)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Do background refresh but don't block initial UI
        _refreshAllServices();
        _startAutoRefresh();
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _apiService.dispose();
    _webSocketService.dispose();
    super.dispose();
  }

  void _initializeServices() {
    _services = [
      ServiceStatus(
        name: 'Gateway HTTP Service',
        url: 'http://localhost:8080/api/v1/health',
        isHealthy: false, // Default to unhealthy until tested
        lastChecked: DateTime.now(),
      ),
      ServiceStatus(
        name: 'WebSocket Service',
        url: 'ws://localhost:8081/ws',
        isHealthy: false, // Default to unhealthy until tested
        lastChecked: DateTime.now(),
      ),
      ServiceStatus(
        name: 'Calculator gRPC (via Gateway)',
        url: 'http://localhost:8080/api/v1/calculate/add',
        isHealthy: false, // Default to unhealthy until tested
        lastChecked: DateTime.now(),
      ),
    ];
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_autoRefreshEnabled && mounted) {
        _refreshAllServices();
      }
    });
  }

  Future<void> _refreshAllServices() async {
    if (_isRefreshing) return;

    print('🔄 Starting service refresh cycle');

    setState(() {
      _isRefreshing = true;
    });

    List<ServiceStatus> updatedServices = [];

    // Check Gateway HTTP Service
    print('🏥 Checking Gateway HTTP Service...');
    try {
      final stopwatch = Stopwatch()..start();
      await _apiService.getHealth();
      stopwatch.stop();

      print(
          '✅ Gateway HTTP Service: HEALTHY (${stopwatch.elapsed.inMilliseconds}ms)');
      updatedServices.add(ServiceStatus(
        name: 'Gateway HTTP Service',
        url: 'http://localhost:8080/api/v1/health',
        isHealthy: true,
        responseTime: stopwatch.elapsed,
        lastChecked: DateTime.now(),
      ));
    } catch (e) {
      print('❌ Gateway HTTP Service: UNHEALTHY - $e');
      updatedServices.add(ServiceStatus(
        name: 'Gateway HTTP Service',
        url: 'http://localhost:8080/api/v1/health',
        isHealthy: false,
        error: e.toString(),
        lastChecked: DateTime.now(),
      ));
    }

    // Check WebSocket Service (via HTTP stats endpoint)
    print('🔌 Checking WebSocket Service...');
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(
        Uri.parse('http://localhost:8081/stats'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      stopwatch.stop();

      if (response.statusCode == 200) {
        print(
            '✅ WebSocket Service: HEALTHY (${stopwatch.elapsed.inMilliseconds}ms)');
        updatedServices.add(ServiceStatus(
          name: 'WebSocket Service',
          url: 'http://localhost:8081/stats',
          isHealthy: true,
          responseTime: stopwatch.elapsed,
          lastChecked: DateTime.now(),
        ));
      } else {
        print('❌ WebSocket Service: UNHEALTHY - Status ${response.statusCode}');
        updatedServices.add(ServiceStatus(
          name: 'WebSocket Service',
          url: 'http://localhost:8081/stats',
          isHealthy: false,
          error: 'HTTP ${response.statusCode}',
          lastChecked: DateTime.now(),
        ));
      }
    } catch (e) {
      print('❌ WebSocket Service: UNHEALTHY - $e');
      updatedServices.add(ServiceStatus(
        name: 'WebSocket Service',
        url: 'http://localhost:8081/stats',
        isHealthy: false,
        error: e.toString(),
        lastChecked: DateTime.now(),
      ));
    }

    // Check Calculator gRPC (via Gateway)
    print('🧮 Checking Calculator gRPC Service...');
    try {
      final stopwatch = Stopwatch()..start();
      await _apiService.add(2, 3); // Test calculation
      stopwatch.stop();

      print(
          '✅ Calculator gRPC Service: HEALTHY (${stopwatch.elapsed.inMilliseconds}ms)');
      updatedServices.add(ServiceStatus(
        name: 'Calculator gRPC (via Gateway)',
        url: 'http://localhost:8080/api/v1/calculate/add',
        isHealthy: true,
        responseTime: stopwatch.elapsed,
        lastChecked: DateTime.now(),
      ));
    } catch (e) {
      print('❌ Calculator gRPC Service: UNHEALTHY - $e');
      updatedServices.add(ServiceStatus(
        name: 'Calculator gRPC (via Gateway)',
        url: 'http://localhost:8080/api/v1/calculate/add',
        isHealthy: false,
        error: e.toString(),
        lastChecked: DateTime.now(),
      ));
    }

    setState(() {
      _services = updatedServices;
      _isRefreshing = false;
    });

    final healthyCount = _services.where((s) => s.isHealthy).length;
    print(
        '🔄 Service refresh complete: $healthyCount/${_services.length} healthy');
  }

  String _formatResponseTime(Duration? duration) {
    if (duration == null) return 'N/A';

    if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    } else {
      return '${(duration.inMilliseconds / 1000).toStringAsFixed(2)}s';
    }
  }

  String _formatLastChecked(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  Color _getStatusColor(ServiceStatus service) {
    if (service.isHealthy) {
      if (service.responseTime != null &&
          service.responseTime!.inMilliseconds > 2000) {
        return Colors.orange; // Slow but working
      }
      return Colors.green; // Healthy
    }
    return Colors.red; // Unhealthy
  }

  IconData _getStatusIcon(ServiceStatus service) {
    if (service.isHealthy) {
      if (service.responseTime != null &&
          service.responseTime!.inMilliseconds > 2000) {
        return Icons.warning; // Slow
      }
      return Icons.check_circle; // Healthy
    }
    return Icons.error; // Unhealthy
  }

  String _getStatusText(ServiceStatus service) {
    if (service.isHealthy) {
      if (service.responseTime != null &&
          service.responseTime!.inMilliseconds > 2000) {
        return 'Slow';
      }
      return 'Healthy';
    }
    return 'Unhealthy';
  }

  @override
  Widget build(BuildContext context) {
    final healthyCount = _services.where((s) => s.isHealthy).length;
    final totalCount = _services.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Monitor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_autoRefreshEnabled ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                _autoRefreshEnabled = !_autoRefreshEnabled;
              });
              if (_autoRefreshEnabled) {
                _startAutoRefresh();
              } else {
                _autoRefreshTimer?.cancel();
              }
            },
            tooltip: _autoRefreshEnabled
                ? 'Pause Auto-refresh'
                : 'Resume Auto-refresh',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshAllServices,
            tooltip: 'Refresh Now',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overall Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          healthyCount == totalCount
                              ? Icons.check_circle
                              : healthyCount > 0
                                  ? Icons.warning
                                  : Icons.error,
                          size: 48,
                          color: healthyCount == totalCount
                              ? Colors.green
                              : healthyCount > 0
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'System Status',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              '$healthyCount of $totalCount services healthy',
                              style: TextStyle(
                                color: healthyCount == totalCount
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isRefreshing)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Checking services...'),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Text(
                            'Last updated: ${_formatLastChecked(_services.isNotEmpty ? _services.first.lastChecked : DateTime.now())}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if (_autoRefreshEnabled)
                            const Text(
                              'Auto-refresh: every 10 seconds',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Services List
            Expanded(
              child: ListView.builder(
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  final statusColor = _getStatusColor(service);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: Icon(
                        _getStatusIcon(service),
                        color: statusColor,
                        size: 32,
                      ),
                      title: Text(
                        service.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            service.url,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  border: Border.all(color: statusColor),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getStatusText(service),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (service.responseTime != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  'Response: ${_formatResponseTime(service.responseTime)}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (service.error != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Error: ${service.error}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                      trailing: Text(
                        _formatLastChecked(service.lastChecked),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Architecture Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Architecture Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Gateway HTTP Service: Receives HTTP requests from Flutter\n'
                      '• Calculator gRPC Service: Performs calculations via gRPC protocol\n'
                      '• WebSocket Service: Handles real-time messaging\n'
                      '• Flutter App: Connects to all services for different features',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Services run on different ports: Gateway (8080), WebSocket (8081), Calculator gRPC (50051)',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
