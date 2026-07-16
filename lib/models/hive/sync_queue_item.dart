import 'package:hive/hive.dart';

part 'sync_queue_item.g.dart';

@HiveType(typeId: 12)
class SyncQueueItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // 'water_log', 'calorie_log', 'dose_log'

  @HiveField(2)
  String action; // 'create', 'delete'

  @HiveField(3)
  Map<String, dynamic> payload;

  @HiveField(4)
  int timestamp;

  @HiveField(5)
  int retryCount;

  SyncQueueItem({
    required this.id,
    required this.type,
    required this.action,
    required this.payload,
    required this.timestamp,
    this.retryCount = 0,
  });
}
