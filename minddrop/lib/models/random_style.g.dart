// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'random_style.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RandomStyleAdapter extends TypeAdapter<RandomStyle> {
  @override
  final int typeId = 1;

  @override
  RandomStyle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RandomStyle(
      color: fields[0] as String,
      icon: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RandomStyle obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.color)
      ..writeByte(1)
      ..write(obj.icon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RandomStyleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
