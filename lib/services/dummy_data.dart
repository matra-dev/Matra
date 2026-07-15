import '../models/supplement_model.dart';
import '../models/dose_log_model.dart';
import 'medication_search_service.dart';

class DummyData {
  DummyData._();

  static List<Supplement> get supplements {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    final threeDaysAgo = today.subtract(const Duration(days: 3));
    final weekAgo = today.subtract(const Duration(days: 7));

    // Get 12 diverse supplements from the local database
    final meds = MedicationSearchService.localMedications;
    final selectedMeds = [
      meds.firstWhere((m) => m['name'] == 'Vitamin D3'),
      meds.firstWhere((m) => m['name'] == 'Omega-3 Fish Oil'),
      meds.firstWhere((m) => m['name'] == 'Magnesium Glycinate'),
      meds.firstWhere((m) => m['name'] == 'Vitamin B12'),
      meds.firstWhere((m) => m['name'] == 'Zinc Picolinate'),
      meds.firstWhere((m) => m['name'] == 'Probiotics'),
      meds.firstWhere((m) => m['name'] == 'CoQ10'),
      meds.firstWhere((m) => m['name'] == 'Ashwagandha'),
      meds.firstWhere((m) => m['name'] == 'Melatonin'),
      meds.firstWhere((m) => m['name'] == 'Iron'),
      meds.firstWhere((m) => m['name'] == 'Calcium Carbonate'),
      meds.firstWhere((m) => m['name'] == 'Vitamin C'),
    ];

    return selectedMeds.asMap().entries.map((entry) {
      final i = entry.key;
      final med = entry.value;
      final name = med['name'] as String;
      final dosage = med['dosage'] as String;
      
      // Parse dosage
      final match = RegExp(r'(\d+)\s*(mg|mcg|IU|g|ml|CFU)').firstMatch(dosage);
      final amount = double.tryParse(match?.group(1) ?? '1') ?? 1;
      final unit = match?.group(2) ?? 'mg';
      
      // Vary stock levels and time slots for realism
      final stocks = [60, 5, 25, 3, 45, 12, 30, 8, 15, 20, 40, 10];
      final timeSlotsList = [
        ['Morning'],
        ['Morning', 'Evening'],
        ['Evening'],
        ['Morning', 'Afternoon'],
        ['Afternoon'],
        ['Morning'],
        ['Morning'],
        ['Evening'],
        ['Evening'],
        ['Morning'],
        ['Afternoon'],
        ['Morning'],
      ];
      final startDates = [
        weekAgo, weekAgo, threeDaysAgo, twoDaysAgo, yesterday, today,
        weekAgo, threeDaysAgo, twoDaysAgo, yesterday, today, weekAgo,
      ];

      return Supplement(
        id: 'supp_${i + 1}',
        name: name,
        dosageAmount: amount,
        dosageUnit: unit,
        frequency: timeSlotsList[i].length,
        stockCount: stocks[i],
        timeSlots: timeSlotsList[i],
        startDate: startDates[i].toIso8601String().split('T')[0],
        createdAt: startDates[i].millisecondsSinceEpoch + i * 1000,
      );
    }).toList();
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
        takenAt: today.subtract(const Duration(hours: 1)),
      ),
      DoseLog(
        id: 'log_2',
        supplementId: 'supp_4',
        date: todayStr,
        timestamp: today.millisecondsSinceEpoch - 7200000,
        takenAt: today.subtract(const Duration(hours: 2)),
      ),

      // Yesterday's doses
      DoseLog(
        id: 'log_3',
        supplementId: 'supp_1',
        date: yesterdayStr,
        timestamp: today.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        takenAt: today.subtract(const Duration(days: 1)),
      ),
      DoseLog(
        id: 'log_4',
        supplementId: 'supp_2',
        date: yesterdayStr,
        timestamp: today.subtract(const Duration(days: 1)).millisecondsSinceEpoch + 1000,
        takenAt: today.subtract(const Duration(days: 1)).add(const Duration(seconds: 1)),
      ),
      DoseLog(
        id: 'log_5',
        supplementId: 'supp_3',
        date: yesterdayStr,
        timestamp: today.subtract(const Duration(days: 1)).millisecondsSinceEpoch + 2000,
        takenAt: today.subtract(const Duration(days: 1)).add(const Duration(seconds: 2)),
      ),

      // 2 days ago
      DoseLog(
        id: 'log_6',
        supplementId: 'supp_1',
        date: twoDaysAgoStr,
        timestamp: today.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
        takenAt: today.subtract(const Duration(days: 2)),
      ),
      DoseLog(
        id: 'log_7',
        supplementId: 'supp_2',
        date: twoDaysAgoStr,
        timestamp: today.subtract(const Duration(days: 2)).millisecondsSinceEpoch + 1000,
        takenAt: today.subtract(const Duration(days: 2)).add(const Duration(seconds: 1)),
      ),
    ];
  }
}
