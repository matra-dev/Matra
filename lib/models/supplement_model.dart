class Supplement {
  final String id;
  final String name;
  final double dosageAmount;
  final String dosageUnit;
  final int frequency;
  final int stockCount;
  final List<String> timeSlots;
  final String startDate;
  final int createdAt;

  Supplement({
    required this.id,
    required this.name,
    required this.dosageAmount,
    required this.dosageUnit,
    required this.frequency,
    required this.stockCount,
    required this.timeSlots,
    required this.startDate,
    required this.createdAt,
  });

  factory Supplement.fromJson(Map<String, dynamic> json) {
    return Supplement(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      dosageAmount: (json['dosage_amount'] ?? 0).toDouble(),
      dosageUnit: json['dosage_unit'] ?? 'mg',
      frequency: json['frequency'] ?? 1,
      stockCount: json['stock_count'] ?? 0,
      timeSlots: List<String>.from(json['time_slots'] ?? []),
      startDate: json['start_date'] ?? '',
      createdAt: json['created_at'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage_amount': dosageAmount,
      'dosage_unit': dosageUnit,
      'frequency': frequency,
      'stock_count': stockCount,
      'time_slots': timeSlots,
      'start_date': startDate,
      'created_at': createdAt,
    };
  }

  Supplement copyWith({
    String? id,
    String? name,
    double? dosageAmount,
    String? dosageUnit,
    int? frequency,
    int? stockCount,
    List<String>? timeSlots,
    String? startDate,
    int? createdAt,
  }) {
    return Supplement(
      id: id ?? this.id,
      name: name ?? this.name,
      dosageAmount: dosageAmount ?? this.dosageAmount,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      frequency: frequency ?? this.frequency,
      stockCount: stockCount ?? this.stockCount,
      timeSlots: timeSlots ?? this.timeSlots,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isLowStock => stockCount <= frequency * 3;

  String get dosageText => '${dosageAmount.toStringAsFixed(dosageAmount.truncateToDouble() == dosageAmount ? 0 : 1)} $dosageUnit';

  int get daysSinceStart {
    if (startDate.isEmpty) return 0;
    final start = DateTime.parse(startDate);
    final now = DateTime.now();
    return now.difference(start).inDays;
  }
}
