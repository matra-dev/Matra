import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../models/supplement_model.dart';
import '../models/dose_log_model.dart';
import '../models/water_log_model.dart';
import '../models/calorie_log_model.dart';
import '../models/hive/water_log_hive.dart';
import '../models/hive/calorie_log_hive.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;
  Box<WaterLogHive>? _waterBox;
  Box<CalorieLogHive>? _calorieBox;
  bool _hiveInitialized = false;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    if (!_hiveInitialized) {
      _waterBox = await Hive.openBox<WaterLogHive>('water_logs');
      _calorieBox = await Hive.openBox<CalorieLogHive>('calorie_logs');
      _hiveInitialized = true;
    }
  }

  // ─── Onboarding ───────────────────────────────────────────────────────────

  Future<bool> hasSeenOnboarding() async {
    await init();
    return _prefs?.getBool('@stacksense/onboarding_seen') ?? false;
  }

  Future<void> setOnboardingSeen() async {
    await init();
    await _prefs?.setBool('@stacksense/onboarding_seen', true);
  }

  // ─── Supplements ──────────────────────────────────────────────────────────

  Future<List<Supplement>> getSupplements() async {
    await init();
    final jsonStr = _prefs?.getString('@stacksense/supplements');
    if (jsonStr == null) return [];
    try {
      final List<dynamic> data = jsonDecode(jsonStr);
      return data.map((e) => Supplement.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSupplements(List<Supplement> supplements) async {
    await init();
    final data = supplements.map((s) => s.toJson()..['id'] = s.id).toList();
    await _prefs?.setString('@stacksense/supplements', jsonEncode(data));
  }

  // ─── Dose Logs ────────────────────────────────────────────────────────────

  Future<List<DoseLog>> getDoseLogs() async {
    await init();
    final jsonStr = _prefs?.getString('@stacksense/dose_logs');
    if (jsonStr == null) return [];
    try {
      final List<dynamic> data = jsonDecode(jsonStr);
      return data.map((e) => DoseLog.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDoseLogs(List<DoseLog> logs) async {
    await init();
    final data = logs.map((l) => l.toJson()..['id'] = l.id).toList();
    await _prefs?.setString('@stacksense/dose_logs', jsonEncode(data));
  }

  // ─── Auth Token ───────────────────────────────────────────────────────────

  Future<String?> getToken() async {
    await init();
    return _prefs?.getString('@stacksense/token');
  }

  Future<void> setToken(String token) async {
    await init();
    await _prefs?.setString('@stacksense/token', token);
  }

  Future<void> clearToken() async {
    await init();
    await _prefs?.remove('@stacksense/token');
  }

  // ─── User Goals ───────────────────────────────────────────────────────────

  Future<int> getWaterGoal() async {
    await init();
    return _prefs?.getInt('@stacksense/water_goal') ?? 2500;
  }

  Future<void> setWaterGoal(int ml) async {
    await init();
    await _prefs?.setInt('@stacksense/water_goal', ml);
  }

  Future<int> getCalorieGoal() async {
    await init();
    return _prefs?.getInt('@stacksense/calorie_goal') ?? 2000;
  }

  Future<void> setCalorieGoal(int kcal) async {
    await init();
    await _prefs?.setInt('@stacksense/calorie_goal', kcal);
  }

  // ─── Clear All ────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await init();
    await _prefs?.remove('@stacksense/supplements');
    await _prefs?.remove('@stacksense/dose_logs');
    await _prefs?.remove('@stacksense/token');
    await _prefs?.remove('@stacksense/onboarding_seen');
    await _waterBox?.clear();
    await _calorieBox?.clear();
  }

  // ─── Water Logs (Hive) ────────────────────────────────────────────────────

  Future<List<WaterLog>> getWaterLogs() async {
    await init();
    if (_waterBox == null) return [];
    try {
      return _waterBox!.values.map((h) => WaterLog(
        id: h.id,
        amountMl: h.amountMl,
        userId: h.userId,
        date: h.date,
        timestamp: h.timestamp,
        note: h.note,
      )).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWaterLogs(List<WaterLog> logs) async {
    await init();
    if (_waterBox == null) return;
    await _waterBox!.clear();
    for (var i = 0; i < logs.length; i++) {
      final log = logs[i];
      final hiveLog = WaterLogHive(
        id: log.id,
        amountMl: log.amountMl,
        userId: log.userId,
        date: log.date,
        timestamp: log.timestamp,
        note: log.note,
      );
      await _waterBox!.put('${log.date}_${log.id}', hiveLog);
    }
  }

  Future<void> addWaterLog(WaterLog log) async {
    await init();
    if (_waterBox == null) return;
    final hiveLog = WaterLogHive(
      id: log.id,
      amountMl: log.amountMl,
      userId: log.userId,
      date: log.date,
      timestamp: log.timestamp,
      note: log.note,
    );
    await _waterBox!.put('${log.date}_${log.id}', hiveLog);
  }

  Future<void> deleteWaterLog(String id, String date) async {
    await init();
    await _waterBox?.delete('${date}_$id');
  }

  // ─── Calorie Logs (Hive) ─────────────────────────────────────────────────

  Future<List<CalorieLog>> getCalorieLogs() async {
    await init();
    if (_calorieBox == null) return [];
    try {
      return _calorieBox!.values.map((h) => CalorieLog(
        id: h.id,
        calories: h.calories,
        mealType: h.mealType,
        userId: h.userId,
        date: h.date,
        timestamp: h.timestamp,
        note: h.note,
      )).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCalorieLogs(List<CalorieLog> logs) async {
    await init();
    if (_calorieBox == null) return;
    await _calorieBox!.clear();
    for (var i = 0; i < logs.length; i++) {
      final log = logs[i];
      final hiveLog = CalorieLogHive(
        id: log.id,
        calories: log.calories,
        mealType: log.mealType,
        userId: log.userId,
        date: log.date,
        timestamp: log.timestamp,
        note: log.note,
      );
      await _calorieBox!.put('${log.date}_${log.id}', hiveLog);
    }
  }

  Future<void> addCalorieLog(CalorieLog log) async {
    await init();
    if (_calorieBox == null) return;
    final hiveLog = CalorieLogHive(
      id: log.id,
      calories: log.calories,
      mealType: log.mealType,
      userId: log.userId,
      date: log.date,
      timestamp: log.timestamp,
      note: log.note,
    );
    await _calorieBox!.put('${log.date}_${log.id}', hiveLog);
  }

  Future<void> deleteCalorieLog(String id, String date) async {
    await init();
    await _calorieBox?.delete('${date}_$id');
  }
}
