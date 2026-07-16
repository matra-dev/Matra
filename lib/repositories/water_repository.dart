import '../models/water_log_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import '../services/connectivity_service.dart';

/// Repository that abstracts online/offline logic for water logs.
/// Online: API first, sync to Hive on success.
/// Offline: Save to Hive, queue for sync.
class WaterRepository {
  final ApiService _api;
  final LocalStorageService _local;
  final SyncService _sync;
  final ConnectivityService _connectivity;

  WaterRepository(this._api, this._local, this._sync, this._connectivity);

  /// Load today's logs. Online: fetch from API + cache. Offline: read from Hive.
  Future<List<WaterLog>> loadTodayLogs(String date) async {
    final isOnline = await _connectivity.checkNow();

    if (isOnline) {
      try {
        final logs = await _api.getTodayWaterLogs(date);
        await _local.saveWaterLogs(logs);
        return logs;
      } catch (_) {
        // Fall through to local
      }
    }

    final allLogs = await _local.getWaterLogs();
    return allLogs.where((l) => l.date == date).toList();
  }

  /// Add a water log. Online: API first. Offline: queue for sync.
  Future<WaterLog> addLog(int amountMl, String date, {String? note}) async {
    final isOnline = await _connectivity.checkNow();
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();

    final log = WaterLog(
      id: id,
      amountMl: amountMl,
      userId: '', // Server assigns userId from auth token
      date: date,
      timestamp: now.millisecondsSinceEpoch,
      note: note,
    );

    // Always save locally first
    await _local.addWaterLog(log);

    if (isOnline) {
      try {
        final created = await _api.createWaterLog(amountMl, date, note: note);
        // Update local with server ID
        await _local.saveWaterLogs(
          (await _local.getWaterLogs())..removeWhere((l) => l.id == id)..add(created),
        );
        return created;
      } catch (_) {
        // Queue for later sync
        await _sync.queueItem(
          type: 'water_log',
          action: 'create',
          payload: log.toJson(),
        );
      }
    } else {
      // Offline: queue for sync
      await _sync.queueItem(
        type: 'water_log',
        action: 'create',
        payload: log.toJson(),
      );
    }

    return log;
  }

  /// Delete a water log.
  Future<void> deleteLog(String id, String date) async {
    await _local.deleteWaterLog(id, date);

    final isOnline = await _connectivity.checkNow();
    if (isOnline) {
      try {
        await _api.deleteWaterLog(id);
      } catch (_) {
        await _sync.queueItem(
          type: 'water_log',
          action: 'delete',
          payload: {'id': id, 'date': date},
        );
      }
    } else {
      await _sync.queueItem(
        type: 'water_log',
        action: 'delete',
        payload: {'id': id, 'date': date},
      );
    }
  }

  /// Get total for a specific date (always from local).
  Future<int> getTotalForDate(String date) async {
    final logs = await _local.getWaterLogs();
    return logs.where((l) => l.date == date).fold<int>(0, (sum, l) => sum + l.amountMl);
  }
}
