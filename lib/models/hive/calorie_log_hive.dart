import 'package:hive/hive.dart';

part 'calorie_log_hive.g.dart';

@HiveType(typeId: 11)
class CalorieLogHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int calories;

  @HiveField(2)
  String mealType;

  @HiveField(3)
  String userId;

  @HiveField(4)
  String date;

  @HiveField(5)
  int timestamp;

  @HiveField(6)
  String? note;

  CalorieLogHive({
    required this.id,
    required this.calories,
    required this.mealType,
    required this.userId,
    required this.date,
    required this.timestamp,
    this.note,
  });
}
