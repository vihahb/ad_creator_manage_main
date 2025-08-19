// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ads_generated.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdsGeneratedAdapter extends TypeAdapter<AdsGenerated> {
  @override
  final int typeId = 0;

  @override
  AdsGenerated read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdsGenerated(
      title: fields[0] as String,
      subtitle: fields[1] as String,
      keyword: fields[2] as String,
      description: fields[3] as String,
      dateTime: fields[4] as DateTime,
      adInput: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AdsGenerated obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.subtitle)
      ..writeByte(2)
      ..write(obj.keyword)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.dateTime)
      ..writeByte(5)
      ..write(obj.adInput);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdsGeneratedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
