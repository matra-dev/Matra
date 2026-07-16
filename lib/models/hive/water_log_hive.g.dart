// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_log_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WaterLogHiveAdapter extends TypeAdapter<WaterLogHive> {
  @override
  final int typeId = 10;

  @override
  WaterLogHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaterLogHive(
      id: fields[0] as String,
      amountMl: fields[1] as int,
      userId: fields[2] as String,
      date: fields[3] as String,
      timestamp: fields[4] as int,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WaterLogHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amountMl)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaterLogHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
