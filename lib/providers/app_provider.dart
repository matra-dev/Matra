import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/supplement_model.dart';
import '../models/dose_log_model.dart';
import '../services/local_storage_service.dart';
import '../services/dummy_data.dart';
import '../utils/app_date_utils.dart' as app_date;

// Local Storage Provider
final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// Flag to seed dummy data once
bool _seeded = false;

// Supplements State
final supplementsProvider = StateNotifierProvider<SupplementsNotifier, AsyncValue<List<Supplement>>>((ref) {
  return SupplementsNotifier(ref.read(localStorageProvider));
});

class SupplementsNotifier extends StateNotifier<AsyncValue<List<Supplement>>> {
  final LocalStorageService _local;

  SupplementsNotifier(this._local) : super(const AsyncValue.loading()) {
    loadSupplements();
  }

  Future<void> loadSupplements() async {
    try {
      state = const AsyncValue.loading();
      var supplements = await _local.getSupplements();

      // Seed dummy data if empty and not already seeded
      if (supplements.isEmpty && !_seeded) {
        _seeded = true;
        supplements = DummyData.supplements;
        await _local.saveSupplements(supplements);
        // Also seed dose logs
        await _local.saveDoseLogs(DummyData.doseLogs);
      }

      state = AsyncValue.data(supplements);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSupplement(Supplement supplement) async {
    final current = state.value ?? [];
    final updated = [...current, supplement];
    await _local.saveSupplements(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> updateSupplement(String id, Map<String, dynamic> data) async {
    final current = state.value ?? [];
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

// Dose Logs State
final doseLogsProvider = StateNotifierProvider<DoseLogsNotifier, AsyncValue<List<DoseLog>>>((ref) {
  return DoseLogsNotifier(ref.read(localStorageProvider));
});

class DoseLogsNotifier extends StateNotifier<AsyncValue<List<DoseLog>>> {
  final LocalStorageService _local;

  DoseLogsNotifier(this._local) : super(const AsyncValue.data([]));

  Future<void> loadTodayLogs() async {
    try {
      final allLogs = await _local.getDoseLogs();
      final today = app_date.DateUtils.getTodayDateString();
      final todayLogs = allLogs.where((l) => l.date == today).toList();
      state = AsyncValue.data(todayLogs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logDose(String supplementId) async {
    final current = state.value ?? [];
    final today = app_date.DateUtils.getTodayDateString();
    final log = DoseLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      supplementId: supplementId,
      date: today,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    final updated = [...current, log];
    await _local.saveDoseLogs(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> unlogDose(String supplementId) async {
    final current = state.value ?? [];
    final today = app_date.DateUtils.getTodayDateString();
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
