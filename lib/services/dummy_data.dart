import '../models/supplement_model.dart';
import '../models/dose_log_model.dart';

class DummyData {
  DummyData._();

  static List<Supplement> get supplements {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    final threeDaysAgo = today.subtract(const Duration(days: 3));
    final weekAgo = today.subtract(const Duration(days: 7));

    return [
      Supplement(
        id: 'supp_1',
        name: 'Vitamin D3',
        dosageAmount: 5000,
        dosageUnit: 'IU',
        frequency: 1,
        stockCount: 60,
        timeSlots: ['Morning'],
        startDate: weekAgo.toIso8601String().split('T')[0],
        createdAt: weekAgo.millisecondsSinceEpoch,
      ),
      Supplement(
        id: 'supp_2',
        name: 'Omega-3 Fish Oil',
        dosageAmount: 1000,
        dosageUnit: 'mg',
        frequency: 2,
        stockCount: 5,
        timeSlots: ['Morning', 'Evening'],
        startDate: weekAgo.toIso8601String().split('T')[0],
        createdAt: weekAgo.millisecondsSinceEpoch + 1000,
      ),
      Supplement(
        id: 'supp_3',
        name: 'Magnesium Glycinate',
        dosageAmount: 400,
        dosageUnit: 'mg',
        frequency: 1,
        stockCount: 25,
        timeSlots: ['Evening'],
        startDate: threeDaysAgo.toIso8601String().split('T')[0],
        createdAt: threeDaysAgo.millisecondsSinceEpoch,
      ),
      Supplement(
        id: 'supp_4',
        name: 'Vitamin C',
        dosageAmount: 1000,
        dosageUnit: 'mg',
        frequency: 2,
        stockCount: 3,
        timeSlots: ['Morning', 'Afternoon'],
        startDate: twoDaysAgo.toIso8601String().split('T')[0],
        createdAt: twoDaysAgo.millisecondsSinceEpoch,
      ),
      Supplement(
        id: 'supp_5',
        name: 'Zinc Picolinate',
        dosageAmount: 25,
        dosageUnit: 'mg',
        frequency: 1,
        stockCount: 45,
        timeSlots: ['Afternoon'],
        startDate: yesterday.toIso8601String().split('T')[0],
        createdAt: yesterday.millisecondsSinceEpoch,
      ),
      Supplement(
        id: 'supp_6',
        name: 'Probiotic Complex',
        dosageAmount: 50,
        dosageUnit: 'mg',
        frequency: 1,
        stockCount: 12,
        timeSlots: ['Morning'],
        startDate: today.toIso8601String().split('T')[0],
        createdAt: today.millisecondsSinceEpoch,
      ),
    ];
  }

  static List<DoseLog> get doseLogs {
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];
    final yesterdayStr = today.subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
    final twoDaysAgoStr = today.subtract(const Duration(days: 2)).toIso8601String().split('T')[0];

    return [
      // Today's doses (some taken, some not)
      DoseLog(
        id: 'log_1',
        supplementId: 'supp_1',
        date: todayStr,
        timestamp: today.millisecondsSinceEpoch - 3600000,
      ),
      DoseLog(
        id: 'log_2',
        supplementId: 'supp_4',
        date: todayStr,
        timestamp: today.millisecondsSinceEpoch - 7200000,
      ),

      // Yesterday's doses
      DoseLog(
        id: 'log_3',
        supplementId: 'supp_1',
        date: yesterdayStr,
        timestamp: today.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      ),
      DoseLog(
        id: 'log_4',
        supplementId: 'supp_2',
        date: yesterdayStr,
        timestamp: today.subtract(const Duration(days: 1)).millisecondsSinceEpoch + 1000,
      ),
      DoseLog(
        id: 'log_5',
        supplementId: 'supp_3',
        date: yesterdayStr,
        timestamp: today.subtract(const Duration(days: 1)).millisecondsSinceEpoch + 2000,
      ),

      // 2 days ago
      DoseLog(
        id: 'log_6',
        supplementId: 'supp_1',
        date: twoDaysAgoStr,
        timestamp: today.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
      ),
      DoseLog(
        id: 'log_7',
        supplementId: 'supp_2',
        date: twoDaysAgoStr,
        timestamp: today.subtract(const Duration(days: 2)).millisecondsSinceEpoch + 1000,
      ),
    ];
  }
}
