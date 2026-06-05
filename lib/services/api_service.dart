import 'package:dio/dio.dart';
import '../models/supplement_model.dart';
import '../models/dose_log_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  bool _initialized = false;

  void initialize({String baseUrl = 'http://localhost:8000'}) {
    if (_initialized) return;
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _initialized = true;
  }

  // Supplements
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

  // Dose Logs
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
}
