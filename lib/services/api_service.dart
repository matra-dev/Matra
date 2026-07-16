import 'dart:io';
import 'package:dio/dio.dart';
import '../models/supplement_model.dart';
import '../models/dose_log_model.dart';
import '../models/water_log_model.dart';
import '../models/calorie_log_model.dart';
import 'local_storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  bool _initialized = false;
  final _local = LocalStorageService();

  String get _defaultBaseUrl {
    // Check for environment variable first (production Render URL)
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    
    // Development fallback
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';  // Android emulator localhost
    }
    return 'http://localhost:8000';   // iOS simulator / desktop
  }

  void initialize({String? baseUrl}) {
    if (_initialized) return;
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? _defaultBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _local.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _local.clearToken();
        }
        handler.next(error);
      },
    ));
    _initialized = true;
  }

  Dio get dio => _dio;

  // ─── Auth ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register(String email, String password, {String? name}) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      if (name != null) 'name': name,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    await _local.setToken(token);
    return data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    await _local.setToken(token);
    return data;
  }

  Future<void> logout() async {
    await _local.clearToken();
  }

  Future<Map<String, dynamic>?> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data['data'] as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _local.getToken();
    if (token == null) return false;
    final me = await getMe();
    return me != null;
  }

  // ─── Supplements ────────────────────────────────────────────────────────

  Future<List<Supplement>> getSupplements() async {
    final response = await _dio.get('/supplements');
    final data = response.data['data'] as List<dynamic>?;
    return data?.map((e) => Supplement.fromJson(e)).toList() ?? [];
  }

  Future<Supplement> createSupplement(Supplement supplement) async {
    final response = await _dio.post('/supplements', data: supplement.toJson());
    return Supplement.fromJson(response.data['data']);
  }

  Future<Supplement> updateSupplement(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/supplements/$id', data: data);
    return Supplement.fromJson(response.data['data']);
  }

  Future<void> deleteSupplement(String id) async {
    await _dio.delete('/supplements/$id');
  }

  // ─── Dose Logs ──────────────────────────────────────────────────────────

  Future<List<DoseLog>> getTodayLogs(String date) async {
    final response = await _dio.get('/dose-logs/today/$date');
    final data = response.data['data'] as List<dynamic>?;
    return data?.map((e) => DoseLog.fromJson(e)).toList() ?? [];
  }

  Future<List<DoseLog>> getLogsForSupplement(String supplementId) async {
    final response = await _dio.get('/dose-logs/supplement/$supplementId');
    final data = response.data['data'] as List<dynamic>?;
    return data?.map((e) => DoseLog.fromJson(e)).toList() ?? [];
  }

  Future<DoseLog> createDoseLog(String supplementId, String date) async {
    final response = await _dio.post('/dose-logs', data: {
      'supplement_id': supplementId,
      'date': date,
    });
    return DoseLog.fromJson(response.data['data']);
  }

  Future<void> removeDoseLog(String supplementId, String date) async {
    await _dio.delete('/dose-logs/$supplementId/$date');
  }

  // ─── Water Logs ─────────────────────────────────────────────────────────

  Future<List<WaterLog>> getTodayWaterLogs(String date) async {
    final response = await _dio.get('/water-logs/today/$date');
    final data = response.data['data'] as List<dynamic>?;
    return data?.map((e) => WaterLog.fromJson(e)).toList() ?? [];
  }

  Future<List<WaterLog>> getWaterLogsRange(String startDate, String endDate) async {
    final response = await _dio.get('/water-logs/range/$startDate/$endDate');
    final data = response.data['data'] as List<dynamic>?;
    return data?.map((e) => WaterLog.fromJson(e)).toList() ?? [];
  }

  Future<WaterLog> createWaterLog(int amountMl, String date, {String? note}) async {
    final response = await _dio.post('/water-logs', data: {
      'amount_ml': amountMl,
      'date': date,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      if (note != null) 'note': note,
    });
    return WaterLog.fromJson(response.data['data']);
  }

  Future<void> deleteWaterLog(String id) async {
    await _dio.delete('/water-logs/$id');
  }

  // ─── Calorie Logs ───────────────────────────────────────────────────────

  Future<List<CalorieLog>> getTodayCalorieLogs(String date) async {
    final response = await _dio.get('/calorie-logs/today/$date');
    final data = response.data['data'] as List<dynamic>?;
    return data?.map((e) => CalorieLog.fromJson(e)).toList() ?? [];
  }

  Future<List<CalorieLog>> getCalorieLogsRange(String startDate, String endDate) async {
    final response = await _dio.get('/calorie-logs/range/$startDate/$endDate');
    final data = response.data['data'] as List<dynamic>?;
    return data?.map((e) => CalorieLog.fromJson(e)).toList() ?? [];
  }

  Future<CalorieLog> createCalorieLog(int calories, String mealType, String date, {String? note}) async {
    final response = await _dio.post('/calorie-logs', data: {
      'calories': calories,
      'meal_type': mealType,
      'date': date,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      if (note != null) 'note': note,
    });
    return CalorieLog.fromJson(response.data['data']);
  }

  Future<void> deleteCalorieLog(String id) async {
    await _dio.delete('/calorie-logs/$id');
  }

  // ─── Insights ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardInsights() async {
    final response = await _dio.get('/insights/dashboard');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSupplementInsights(String supplementId) async {
    final response = await _dio.get('/insights/supplement/$supplementId');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getTrends() async {
    final response = await _dio.get('/insights/trends');
    return response.data['data'] as Map<String, dynamic>;
  }

  // ─── Measurements ───────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMeasurements() async {
    final response = await _dio.get('/measurements');
    final data = response.data['data'] as List<dynamic>?;
    return data?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<Map<String, dynamic>> createMeasurement(Map<String, dynamic> data) async {
    final response = await _dio.post('/measurements', data: data);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteMeasurement(String id) async {
    await _dio.delete('/measurements/$id');
  }

  // ─── Appointments ───────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAppointments() async {
    final response = await _dio.get('/appointments');
    final data = response.data['data'] as List<dynamic>?;
    return data?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> data) async {
    final response = await _dio.post('/appointments', data: data);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteAppointment(String id) async {
    await _dio.delete('/appointments/$id');
  }
}
