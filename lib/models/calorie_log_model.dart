/// Calorie intake log model
class CalorieLog {
  final String id;
  final int calories;
  final String mealType;
  final String userId;
  final String date;
  final int timestamp;
  final String? note;

  const CalorieLog({
    required this.id,
    required this.calories,
    required this.mealType,
    required this.userId,
    required this.date,
    required this.timestamp,
    this.note,
  });

  factory CalorieLog.fromJson(Map<String, dynamic> json) {
    return CalorieLog(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      mealType: json['meal_type'] as String? ?? 'snack',
      userId: json['user_id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'calories': calories,
      'meal_type': mealType,
      'user_id': userId,
      'date': date,
      'timestamp': timestamp,
      if (note != null) 'note': note,
    };
  }

  CalorieLog copyWith({
    String? id,
    int? calories,
    String? mealType,
    String? userId,
    String? date,
    int? timestamp,
    String? note,
  }) {
    return CalorieLog(
      id: id ?? this.id,
      calories: calories ?? this.calories,
      mealType: mealType ?? this.mealType,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }
}
