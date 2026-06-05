class DoseLog {
  final String id;
  final String supplementId;
  final String date;
  final int timestamp;

  DoseLog({
    required this.id,
    required this.supplementId,
    required this.date,
    required this.timestamp,
  });

  factory DoseLog.fromJson(Map<String, dynamic> json) {
    return DoseLog(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      supplementId: json['supplement_id']?.toString() ?? '',
      date: json['date'] ?? '',
      timestamp: json['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplement_id': supplementId,
      'date': date,
      'timestamp': timestamp,
    };
  }
}
