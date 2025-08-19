import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class OfflineCampaign extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  /// Advertising channel such as business card, direct mail, flyer,
  /// tv/radio, billboard, event, etc.
  @HiveField(2)
  String channel;

  /// Targeted geographic locations.
  @HiveField(3)
  List<String> locations;

  /// Target demographics
  @HiveField(4)
  int? minAge;

  @HiveField(5)
  int? maxAge;

  @HiveField(6)
  String? gender;

  @HiveField(7)
  String? occupation;

  @HiveField(8)
  List<String> interests;

  /// Schedule and budget
  @HiveField(9)
  DateTime startDate;

  @HiveField(10)
  DateTime endDate;

  @HiveField(11)
  double budget;

  /// Metrics
  @HiveField(12)
  DateTime? lastUpdate;

  @HiveField(13)
  int impressions;

  @HiveField(14)
  int clicks;

  @HiveField(15)
  int conversions;

  @HiveField(16)
  double cost;

  OfflineCampaign({
    required this.id,
    required this.name,
    required this.channel,
    required this.locations,
    this.minAge,
    this.maxAge,
    this.gender,
    this.occupation,
    this.interests = const [],
    required this.startDate,
    required this.endDate,
    required this.budget,
    this.lastUpdate,
    this.impressions = 0,
    this.clicks = 0,
    this.conversions = 0,
    this.cost = 0,
  });

  /// Computed metrics
  double get costPerClick => clicks == 0 ? 0 : cost / clicks;

  double get ctr => impressions == 0 ? 0 : clicks / impressions;

  double get conversionRate => impressions == 0 ? 0 : conversions / impressions;

  /// Update campaign metrics and optional timestamp
  void updateMetrics({
    DateTime? timestamp,
    int? impressions,
    int? clicks,
    int? conversions,
    double? cost,
  }) {
    if (timestamp != null) {
      lastUpdate = timestamp;
    }
    if (impressions != null) {
      this.impressions = impressions;
    }
    if (clicks != null) {
      this.clicks = clicks;
    }
    if (conversions != null) {
      this.conversions = conversions;
    }
    if (cost != null) {
      this.cost = cost;
    }
  }
}

/// Manual TypeAdapter so build_runner is not required.
class OfflineCampaignAdapter extends TypeAdapter<OfflineCampaign> {
  @override
  final int typeId = 0;

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
}
