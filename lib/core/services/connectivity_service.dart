import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

enum ConnectivityStatus { online, offline, unknown }

/// Service to monitor network connectivity status
class ConnectivityService {
  static ConnectivityService? _instance;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;

  ConnectivityService._internal();

  static ConnectivityService get instance {
    _instance ??= ConnectivityService._internal();
    return _instance!;
  }

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) => _updateStatus(result),
      onError: (error) {
        print('Connectivity error: $error');
        _statusController.add(ConnectivityStatus.unknown);
      },
    );
  }

  /// Update status based on connectivity result
  void _updateStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _currentStatus = ConnectivityStatus.offline;
    } else if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet) {
      _currentStatus = ConnectivityStatus.online;
    } else {
      _currentStatus = ConnectivityStatus.unknown;
    }

    _statusController.add(_currentStatus);
  }

  /// Get current connectivity status
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  /// Check if currently online
  bool get isOnline => _currentStatus == ConnectivityStatus.online;

  /// Check if currently offline
  bool get isOffline => _currentStatus == ConnectivityStatus.offline;

  /// Dispose resources
  void dispose() {
    _connectivitySubscription.cancel();
    _statusController.close();
  }
}

