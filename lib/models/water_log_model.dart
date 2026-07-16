/// Water intake log model
class WaterLog {
  final String id;
  final int amountMl;
  final String userId;
  final String date;
  final int timestamp;
  final String? note;

  const WaterLog({
    required this.id,
    required this.amountMl,
    required this.userId,
    required this.date,
    required this.timestamp,
    this.note,
  });

  factory WaterLog.fromJson(Map<String, dynamic> json) {
    return WaterLog(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      amountMl: (json['amount_ml'] as num?)?.toInt() ?? 0,
      userId: json['user_id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount_ml': amountMl,
      'user_id': userId,
      'date': date,
      'timestamp': timestamp,
      if (note != null) 'note': note,
    };
  }

  WaterLog copyWith({
    String? id,
    int? amountMl,
    String? userId,
    String? date,
    int? timestamp,
    String? note,
  }) {
    return WaterLog(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }
}
