import 'package:hive/hive.dart';
part 'offline_campaign.g.dart';
@HiveType(typeId: 1)
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
