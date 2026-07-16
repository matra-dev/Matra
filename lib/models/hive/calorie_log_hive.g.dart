// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calorie_log_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalorieLogHiveAdapter extends TypeAdapter<CalorieLogHive> {
  @override
  final int typeId = 11;

  @override
  CalorieLogHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalorieLogHive(
      id: fields[0] as String,
      calories: fields[1] as int,
      mealType: fields[2] as String,
      userId: fields[3] as String,
      date: fields[4] as String,
      timestamp: fields[5] as int,
      note: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CalorieLogHive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.calories)
      ..writeByte(2)
      ..write(obj.mealType)
      ..writeByte(3)
      ..write(obj.userId)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalorieLogHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
