import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitors network connectivity and exposes an online/offline stream.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  bool _isOnline = true;

  Stream<bool> get onConnectivityChanged => _controller.stream;
  bool get isOnline => _isOnline;

  Future<void> init() async {
    // Check initial connectivity state
    final results = await _connectivity.checkConnectivity();
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _isOnline = result != ConnectivityResult.none;

    _connectivity.onConnectivityChanged.listen((results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      if (wasOnline != _isOnline) {
        _controller.add(_isOnline);
      }
    });
  }

  void initialize() => init(); // Backward compatibility

  Future<bool> checkNow() async {
    final results = await _connectivity.checkConnectivity();
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _isOnline = result != ConnectivityResult.none;
    return _isOnline;
  }

  void dispose() {
    _controller.close();
  }
}
