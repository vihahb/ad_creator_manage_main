// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_campaign.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineCampaignAdapter extends TypeAdapter<OfflineCampaign> {
  @override
  final int typeId = 1;

  @override
  OfflineCampaign read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineCampaign(
      id: fields[0] as int,
      name: fields[1] as String,
      channel: fields[2] as String,
      locations: (fields[3] as List).cast<String>(),
      minAge: fields[4] as int?,
      maxAge: fields[5] as int?,
      gender: fields[6] as String?,
      occupation: fields[7] as String?,
      interests: (fields[8] as List).cast<String>(),
      startDate: fields[9] as DateTime,
      endDate: fields[10] as DateTime,
      budget: fields[11] as double,
      lastUpdate: fields[12] as DateTime?,
      impressions: fields[13] as int,
      clicks: fields[14] as int,
      conversions: fields[15] as int,
      cost: fields[16] as double,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineCampaign obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.channel)
      ..writeByte(3)
      ..write(obj.locations)
      ..writeByte(4)
      ..write(obj.minAge)
      ..writeByte(5)
      ..write(obj.maxAge)
      ..writeByte(6)
      ..write(obj.gender)
      ..writeByte(7)
      ..write(obj.occupation)
      ..writeByte(8)
      ..write(obj.interests)
      ..writeByte(9)
      ..write(obj.startDate)
      ..writeByte(10)
      ..write(obj.endDate)
      ..writeByte(11)
      ..write(obj.budget)
      ..writeByte(12)
      ..write(obj.lastUpdate)
      ..writeByte(13)
      ..write(obj.impressions)
      ..writeByte(14)
      ..write(obj.clicks)
      ..writeByte(15)
      ..write(obj.conversions)
      ..writeByte(16)
      ..write(obj.cost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineCampaignAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
