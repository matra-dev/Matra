import 'package:hive/hive.dart';

part 'water_log_hive.g.dart';

@HiveType(typeId: 10)
class WaterLogHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int amountMl;

  @HiveField(2)
  String userId;

  @HiveField(3)
  String date;

  @HiveField(4)
  int timestamp;

  @HiveField(5)
  String? note;

  WaterLogHive({
    required this.id,
    required this.amountMl,
    required this.userId,
    required this.date,
    required this.timestamp,
    this.note,
  });
}
