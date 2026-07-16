import 'dart:async';
import 'package:hive/hive.dart';
import '../models/hive/sync_queue_item.dart';
import '../models/sync_status.dart';
import 'api_service.dart';
import 'connectivity_service.dart';
import 'local_storage_service.dart';

/// Processes the sync queue when network is available.
/// All local changes are queued and pushed to backend when online.
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _local = LocalStorageService();
  final _api = ApiService();
  final _connectivity = ConnectivityService();
  final _statusController = StreamController<SyncStatus>.broadcast();
  Box<SyncQueueItem>? _queueBox;
  bool _isProcessing = false;

  Stream<SyncStatus> get statusStream => _statusController.stream;

  Future<void> init() async {
    await _local.init();
    _queueBox = await Hive.openBox<SyncQueueItem>('sync_queue');
    _connectivity.initialize();
    _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline) _processQueue();
    });
    // Process any existing queue on startup
    await _processQueue();
  }

  /// Add an item to the sync queue.
  Future<void> queueItem({
    required String type,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final item = SyncQueueItem(
      id: '${type}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      action: action,
      payload: payload,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await _queueBox?.add(item);
    _statusController.add(SyncStatus.pending);
    // Try to process immediately if online
    if (_connectivity.isOnline) {
      await _processQueue();
    }
  }

  /// Process all pending sync queue items.
  Future<void> _processQueue() async {
    if (_isProcessing) return;
    if (!_connectivity.isOnline) {
      _statusController.add(SyncStatus.pending);
      return;
    }
    if (_queueBox == null || _queueBox!.isEmpty) {
      _statusController.add(SyncStatus.synced);
      return;
    }

    _isProcessing = true;
    _statusController.add(SyncStatus.syncing);

    final items = _queueBox!.values.toList();
    final toDelete = <SyncQueueItem>[];
    var hasError = false;

    for (final item in items) {
      try {
        await _syncItem(item);
        toDelete.add(item);
      } catch (e) {
        hasError = true;
        item.retryCount++;
        if (item.retryCount > 3) {
          // Max retries reached, remove from queue
          toDelete.add(item);
        } else {
          await item.save();
        }
      }
    }

    // Remove successfully synced items
    for (final item in toDelete) {
      final key = _queueBox!.keyAt(_queueBox!.values.toList().indexOf(item));
      await _queueBox!.delete(key);
    }

    _isProcessing = false;
    _statusController.add(hasError ? SyncStatus.error : (_queueBox!.isEmpty ? SyncStatus.synced : SyncStatus.pending));
  }

  Future<void> _syncItem(SyncQueueItem item) async {
    switch (item.type) {
      case 'water_log':
        if (item.action == 'create') {
          await _api.createWaterLog(
            item.payload['amount_ml'] as int,
            item.payload['date'] as String,
            note: item.payload['note'] as String?,
          );
        }
        break;
      case 'calorie_log':
        if (item.action == 'create') {
          await _api.createCalorieLog(
            item.payload['calories'] as int,
            item.payload['meal_type'] as String,
            item.payload['date'] as String,
            note: item.payload['note'] as String?,
          );
        }
        break;
      case 'dose_log':
        if (item.action == 'create') {
          await _api.createDoseLog(
            item.payload['supplement_id'] as String,
            item.payload['date'] as String,
          );
        } else if (item.action == 'delete') {
          await _api.removeDoseLog(
            item.payload['supplement_id'] as String,
            item.payload['date'] as String,
          );
        }
        break;
    }
  }

  int get pendingCount => _queueBox?.length ?? 0;

  void dispose() {
    _statusController.close();
  }
}
