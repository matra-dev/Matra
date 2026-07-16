import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/supplement_model.dart';
import '../models/dose_log_model.dart';
import '../models/water_log_model.dart';
import '../models/calorie_log_model.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';
import '../utils/app_date_utils.dart' as app_date;

// Local Storage Provider
final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final api = ApiService();
  api.initialize();
  return api;
});

// Auth State
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<bool?>>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<bool?>> {
  final ApiService _api;

  AuthNotifier(this._api) : super(const AsyncValue.data(null)) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    state = const AsyncValue.loading();
    try {
      final isAuth = await _api.isAuthenticated();
      state = AsyncValue.data(isAuth);
    } catch (e) {
      state = AsyncValue.data(false);
    }
  }

  Future<void> logout() async {
    await _api.logout();
    state = const AsyncValue.data(false);
  }

  void setAuthenticated(bool value) {
    state = AsyncValue.data(value);
  }
}

// ─── Supplements State ──────────────────────────────────────────────────────

final supplementsProvider = StateNotifierProvider<SupplementsNotifier, AsyncValue<List<Supplement>>>((ref) {
  return SupplementsNotifier(
    ref.read(localStorageProvider),
    ref.read(apiServiceProvider),
  );
});

class SupplementsNotifier extends StateNotifier<AsyncValue<List<Supplement>>> {
  final LocalStorageService _local;
  final ApiService _api;

  SupplementsNotifier(this._local, this._api) : super(const AsyncValue.loading()) {
    loadSupplements();
  }

  Future<void> loadSupplements() async {
    try {
      state = const AsyncValue.loading();

      // Try API first
      final isAuth = await _api.isAuthenticated();
      if (isAuth) {
        final supplements = await _api.getSupplements();
        state = AsyncValue.data(supplements);
        // Sync to local for offline
        await _local.saveSupplements(supplements);
        return;
      }

      // Fallback to local
      final supplements = await _local.getSupplements();
      state = AsyncValue.data(supplements);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSupplement(Supplement supplement) async {
    final current = state.value ?? [];

    // Try API first
    final isAuth = await _api.isAuthenticated();
    if (isAuth) {
      try {
        final created = await _api.createSupplement(supplement);
        final updated = [...current, created];
        state = AsyncValue.data(updated);
        await _local.saveSupplements(updated);
        return;
      } catch (_) {
        // Fall through to local
      }
    }

    // Local fallback
    final updated = [...current, supplement];
    await _local.saveSupplements(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> updateSupplement(String id, Map<String, dynamic> data) async {
    final current = state.value ?? [];

    // Try API first
    final isAuth = await _api.isAuthenticated();
    if (isAuth) {
      try {
        final updated = await _api.updateSupplement(id, data);
        final newList = current.map((s) => s.id == id ? updated : s).toList();
        state = AsyncValue.data(newList);
        await _local.saveSupplements(newList);
        return;
      } catch (_) {
        // Fall through to local
      }
    }

    // Local fallback
    final newList = current.map((s) {
      if (s.id == id) {
        return s.copyWith(
          name: data['name'] ?? s.name,
          dosageAmount: data['dosage_amount'] != null ? (data['dosage_amount'] as num).toDouble() : s.dosageAmount,
          dosageUnit: data['dosage_unit'] ?? s.dosageUnit,
          frequency: data['frequency'] ?? s.frequency,
          stockCount: data['stock_count'] ?? s.stockCount,
          timeSlots: data['time_slots'] != null ? List<String>.from(data['time_slots']) : s.timeSlots,
        );
      }
      return s;
    }).toList();
    await _local.saveSupplements(newList);
    state = AsyncValue.data(newList);
  }

  Future<void> deleteSupplement(String id) async {
    final current = state.value ?? [];

    // Try API first
    final isAuth = await _api.isAuthenticated();
    if (isAuth) {
      try {
        await _api.deleteSupplement(id);
      } catch (_) {
        // Continue with local update regardless
      }
    }

    final newList = current.where((s) => s.id != id).toList();
    await _local.saveSupplements(newList);
    state = AsyncValue.data(newList);
  }

  Future<void> decrementStock(String id) async {
    final current = state.value ?? [];
    final newList = current.map((s) {
      if (s.id == id && s.stockCount > 0) {
        return s.copyWith(stockCount: s.stockCount - 1);
      }
      return s;
    }).toList();
    await _local.saveSupplements(newList);
    state = AsyncValue.data(newList);
  }

  Future<void> incrementStock(String id) async {
    final current = state.value ?? [];
    final newList = current.map((s) {
      if (s.id == id) {
        return s.copyWith(stockCount: s.stockCount + 1);
      }
      return s;
    }).toList();
    await _local.saveSupplements(newList);
    state = AsyncValue.data(newList);
  }
}

// ─── Dose Logs State ────────────────────────────────────────────────────────

final doseLogsProvider = StateNotifierProvider<DoseLogsNotifier, AsyncValue<List<DoseLog>>>((ref) {
  return DoseLogsNotifier(
    ref.read(localStorageProvider),
    ref.read(apiServiceProvider),
  );
});

class DoseLogsNotifier extends StateNotifier<AsyncValue<List<DoseLog>>> {
  final LocalStorageService _local;
  final ApiService _api;

  DoseLogsNotifier(this._local, this._api) : super(const AsyncValue.data([]));

  Future<void> loadTodayLogs() async {
    try {
      final today = app_date.DateUtils.getTodayDateString();

      // Try API first
      final isAuth = await _api.isAuthenticated();
      if (isAuth) {
        try {
          final logs = await _api.getTodayLogs(today);
          state = AsyncValue.data(logs);
          await _local.saveDoseLogs(logs);
          return;
        } catch (_) {
          // Fall through to local
        }
      }

      // Fallback to local
      final allLogs = await _local.getDoseLogs();
      final todayLogs = allLogs.where((l) => l.date == today).toList();
      state = AsyncValue.data(todayLogs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logDose(String supplementId) async {
    final current = state.value ?? [];
    final today = app_date.DateUtils.getTodayDateString();
    final now = DateTime.now();

    // Try API first
    final isAuth = await _api.isAuthenticated();
    if (isAuth) {
      try {
        final log = await _api.createDoseLog(supplementId, today);
        final updated = [...current, log];
        state = AsyncValue.data(updated);
        await _local.saveDoseLogs(updated);
        return;
      } catch (_) {
        // Fall through to local
      }
    }

    // Local fallback
    final log = DoseLog(
      id: now.millisecondsSinceEpoch.toString(),
      supplementId: supplementId,
      date: today,
      timestamp: now.millisecondsSinceEpoch,
      takenAt: now,
    );
    final updated = [...current, log];
    await _local.saveDoseLogs(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> unlogDose(String supplementId) async {
    final current = state.value ?? [];
    final today = app_date.DateUtils.getTodayDateString();

    // Try API first
    final isAuth = await _api.isAuthenticated();
    if (isAuth) {
      try {
        await _api.removeDoseLog(supplementId, today);
      } catch (_) {
        // Continue with local
      }
    }

    final updated = current.where((l) => !(l.supplementId == supplementId && l.date == today)).toList();
    await _local.saveDoseLogs(updated);
    state = AsyncValue.data(updated);
  }

  bool isTakenToday(String supplementId) {
    final today = app_date.DateUtils.getTodayDateString();
    return state.value?.any((l) => l.supplementId == supplementId && l.date == today) ?? false;
  }
}

// Selected supplement for detail view
final selectedSupplementProvider = StateProvider<Supplement?>((ref) => null);

// Navigation index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

// ─── Water Logs State ───────────────────────────────────────────────────────

final waterLogsProvider = StateNotifierProvider<WaterLogsNotifier, AsyncValue<List<WaterLog>>>((ref) {
  return WaterLogsNotifier(
    ref.read(localStorageProvider),
    ref.read(apiServiceProvider),
  );
});

class WaterLogsNotifier extends StateNotifier<AsyncValue<List<WaterLog>>> {
  final LocalStorageService _local;
  final ApiService _api;

  WaterLogsNotifier(this._local, this._api) : super(const AsyncValue.data([]));

  Future<void> loadTodayLogs() async {
    try {
      final today = app_date.DateUtils.getTodayDateString();

      // Try API first
      final isAuth = await _api.isAuthenticated();
      if (isAuth) {
        try {
          final logs = await _api.getTodayWaterLogs(today);
          state = AsyncValue.data(logs);
          await _local.saveWaterLogs(logs);
          return;
        } catch (_) {
          // Fall through to local
        }
      }

      // Fallback to local
      final allLogs = await _local.getWaterLogs();
      final todayLogs = allLogs.where((l) => l.date == today).toList();
      state = AsyncValue.data(todayLogs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadRangeLogs(String startDate, String endDate) async {
    try {
      // Try API first
      final isAuth = await _api.isAuthenticated();
      if (isAuth) {
        try {
          final logs = await _api.getWaterLogsRange(startDate, endDate);
          state = AsyncValue.data(logs);
          await _local.saveWaterLogs(logs);
          return;
        } catch (_) {
          // Fall through to local
        }
      }

      // Fallback to local
      final allLogs = await _local.getWaterLogs();
      final rangeLogs = allLogs.where((l) => l.date.compareTo(startDate) >= 0 && l.date.compareTo(endDate) <= 0).toList();
      state = AsyncValue.data(rangeLogs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addWaterLog(int amountMl, {String? note}) async {
    final current = state.value ?? [];
    final today = app_date.DateUtils.getTodayDateString();
    final now = DateTime.now();

    // Try API first
    final isAuth = await _api.isAuthenticated();
    if (isAuth) {
      try {
        final log = await _api.createWaterLog(amountMl, today, note: note);
        final updated = [...current, log];
        state = AsyncValue.data(updated);
        await _local.saveWaterLogs(updated);
        return;
      } catch (_) {
        // Fall through to local
      }
    }

    // Local fallback
    final log = WaterLog(
      id: now.millisecondsSinceEpoch.toString(),
      amountMl: amountMl,
      userId: 'local_user',
      date: today,
      timestamp: now.millisecondsSinceEpoch,
      note: note,
    );
    final updated = [...current, log];
    await _local.saveWaterLogs(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> deleteWaterLog(String id) async {
    final current = state.value ?? [];

    // Try API first
    final isAuth = await _api.isAuthenticated();
    if (isAuth) {
      try {
        await _api.deleteWaterLog(id);
      } catch (_) {
        // Continue with local update
      }
    }

    final updated = current.where((l) => l.id != id).toList();
    await _local.saveWaterLogs(updated);
    state = AsyncValue.data(updated);
  }

  int getTodayTotal() {
    final today = app_date.DateUtils.getTodayDateString();
    return state.value
            ?.where((l) => l.date == today)
            .fold<int>(0, (sum, l) => sum + l.amountMl) ??
        0;
  }

  List<WaterLog> getLogsForDate(String date) {
    return state.value?.where((l) => l.date == date).toList() ?? [];
  }

  int getTotalForDate(String date) {
    return state.value
            ?.where((l) => l.date == date)
            .fold<int>(0, (sum, l) => sum + l.amountMl) ??
        0;
  }
}

// ─── Calorie Logs State ─────────────────────────────────────────────────────

final calorieLogsProvider = StateNotifierProvider<CalorieLogsNotifier, AsyncValue<List<CalorieLog>>>((ref) {
  return CalorieLogsNotifier(
    ref.read(localStorageProvider),
    ref.read(apiServiceProvider),
  );
});

class CalorieLogsNotifier extends StateNotifier<AsyncValue<List<CalorieLog>>> {
  final LocalStorageService _local;
  final ApiService _api;

  CalorieLogsNotifier(this._local, this._api) : super(const AsyncValue.data([]));

  Future<void> loadTodayLogs() async {
    try {
      final today = app_date.DateUtils.getTodayDateString();

      // Try API first
      final isAuth = await _api.isAuthenticated();
      if (isAuth) {
        try {
          final logs = await _api.getTodayCalorieLogs(today);
          state = AsyncValue.data(logs);
          await _local.saveCalorieLogs(logs);
          return;
        } catch (_) {
          // Fall through to local
        }
      }

      // Fallback to local
      final allLogs = await _local.getCalorieLogs();
      final todayLogs = allLogs.where((l) => l.date == today).toList();
      state = AsyncValue.data(todayLogs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadRangeLogs(String startDate, String endDate) async {
    try {
      // Try API first
      final isAuth = await _api.isAuthenticated();
      if (isAuth) {
        try {
          final logs = await _api.getCalorieLogsRange(startDate, endDate);
          state = AsyncValue.data(logs);
          await _local.saveCalorieLogs(logs);
          return;
        } catch (_) {
          // Fall through to local
        }
      }

      // Fallback to local
      final allLogs = await _local.getCalorieLogs();
      final rangeLogs = allLogs.where((l) => l.date.compareTo(startDate) >= 0 && l.date.compareTo(endDate) <= 0).toList();
      state = AsyncValue.data(rangeLogs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCalorieLog(int calories, String mealType, {String? note}) async {
    final current = state.value ?? [];
    final today = app_date.DateUtils.getTodayDateString();
    final now = DateTime.now();

    // Try API first
    final isAuth = await _api.isAuthenticated();
    if (isAuth) {
      try {
        final log = await _api.createCalorieLog(calories, mealType, today, note: note);
        final updated = [...current, log];
        state = AsyncValue.data(updated);
        await _local.saveCalorieLogs(updated);
        return;
      } catch (_) {
        // Fall through to local
      }
    }

    // Local fallback
    final log = CalorieLog(
      id: now.millisecondsSinceEpoch.toString(),
      calories: calories,
      mealType: mealType,
      userId: 'local_user',
      date: today,
      timestamp: now.millisecondsSinceEpoch,
      note: note,
    );
    final updated = [...current, log];
    await _local.saveCalorieLogs(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> deleteCalorieLog(String id) async {
    final current = state.value ?? [];

    // Try API first
    final isAuth = await _api.isAuthenticated();
    if (isAuth) {
      try {
        await _api.deleteCalorieLog(id);
      } catch (_) {
        // Continue with local update
      }
    }

    final updated = current.where((l) => l.id != id).toList();
    await _local.saveCalorieLogs(updated);
    state = AsyncValue.data(updated);
  }

  int getTodayTotal() {
    final today = app_date.DateUtils.getTodayDateString();
    return state.value
            ?.where((l) => l.date == today)
            .fold<int>(0, (sum, l) => sum + l.calories) ??
        0;
  }

  List<CalorieLog> getLogsForDate(String date) {
    return state.value?.where((l) => l.date == date).toList() ?? [];
  }

  int getTotalForDate(String date) {
    return state.value
            ?.where((l) => l.date == date)
            .fold<int>(0, (sum, l) => sum + l.calories) ??
        0;
  }

  Map<String, int> getTodayByMeal() {
    final today = app_date.DateUtils.getTodayDateString();
    final todayLogs = state.value?.where((l) => l.date == today) ?? [];
    final result = <String, int>{};
    for (final log in todayLogs) {
      result[log.mealType] = (result[log.mealType] ?? 0) + log.calories;
    }
    return result;
  }
}
