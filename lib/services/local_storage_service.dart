import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/supplement_model.dart';
import '../models/dose_log_model.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
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

  // ─── Clear All ────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await init();
    await _prefs?.remove('@stacksense/supplements');
    await _prefs?.remove('@stacksense/dose_logs');
    await _prefs?.remove('@stacksense/token');
    await _prefs?.remove('@stacksense/onboarding_seen');
  }
}
