import '../models/calorie_log_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import '../services/connectivity_service.dart';

/// Repository that abstracts online/offline logic for calorie logs.
class CalorieRepository {
  final ApiService _api;
  final LocalStorageService _local;
  final SyncService _sync;
  final ConnectivityService _connectivity;

  CalorieRepository(this._api, this._local, this._sync, this._connectivity);

  /// Load today's logs. Online: API first, cache to Hive. Offline: read Hive.
  Future<List<CalorieLog>> loadTodayLogs(String date) async {
    final isOnline = await _connectivity.checkNow();

    if (isOnline) {
      try {
        final logs = await _api.getTodayCalorieLogs(date);
        await _local.saveCalorieLogs(logs);
        return logs;
      } catch (_) {
        // Fall through to local
      }
    }

    final allLogs = await _local.getCalorieLogs();
    return allLogs.where((l) => l.date == date).toList();
  }

  /// Add a calorie log. Online: API first. Offline: queue for sync.
  Future<CalorieLog> addLog(int calories, String mealType, String date, {String? note}) async {
    final isOnline = await _connectivity.checkNow();
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();

    final log = CalorieLog(
      id: id,
      calories: calories,
      mealType: mealType,
      userId: '', // Server assigns userId from auth token
      date: date,
      timestamp: now.millisecondsSinceEpoch,
      note: note,
    );

    // Always save locally first
    await _local.addCalorieLog(log);

    if (isOnline) {
      try {
        final created = await _api.createCalorieLog(calories, mealType, date, note: note);
        await _local.saveCalorieLogs(
          (await _local.getCalorieLogs())..removeWhere((l) => l.id == id)..add(created),
        );
        return created;
      } catch (_) {
        await _sync.queueItem(
          type: 'calorie_log',
          action: 'create',
          payload: log.toJson(),
        );
      }
    } else {
      await _sync.queueItem(
        type: 'calorie_log',
        action: 'create',
        payload: log.toJson(),
      );
    }

    return log;
  }

  /// Delete a calorie log.
  Future<void> deleteLog(String id, String date) async {
    await _local.deleteCalorieLog(id, date);

    final isOnline = await _connectivity.checkNow();
    if (isOnline) {
      try {
        await _api.deleteCalorieLog(id);
      } catch (_) {
        await _sync.queueItem(
          type: 'calorie_log',
          action: 'delete',
          payload: {'id': id, 'date': date},
        );
      }
    } else {
      await _sync.queueItem(
        type: 'calorie_log',
        action: 'delete',
        payload: {'id': id, 'date': date},
      );
    }
  }

  /// Get total for a specific date (always from local).
  Future<int> getTotalForDate(String date) async {
    final logs = await _local.getCalorieLogs();
    return logs.where((l) => l.date == date).fold<int>(0, (sum, l) => sum + l.calories);
  }
}
