import 'package:hive/hive.dart';
import '../models/offline_campaign.dart';

class CampaignRepository {
  static const String _boxName = 'campaigns';
  Box<OfflineCampaign>? _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OfflineCampaignAdapter());
    }
    _box = await Hive.openBox<OfflineCampaign>(_boxName);
  }

  Future<void> close() async {
    await _box?.close();
  }

  /// Get all campaigns
  List<OfflineCampaign> getAllCampaigns() {
    return _box?.values.toList() ?? [];
  }

  /// Get campaigns by channel
  List<OfflineCampaign> getCampaignsByChannel(String channel) {
    return _box?.values.where((campaign) => campaign.channel == channel).toList() ?? [];
  }

  /// Get campaign by ID
  OfflineCampaign? getCampaignById(int id) {
    if (_box == null) return null;
    try {
      return _box!.values.firstWhere((campaign) => campaign.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Save or update a campaign
  Future<void> saveCampaign(OfflineCampaign campaign) async {
    await _box?.put(campaign.id, campaign);
  }

  /// Delete a campaign
  Future<void> deleteCampaign(int id) async {
    await _box?.delete(id);
  }

  /// Get next available ID
  int getNextId() {
    final campaigns = getAllCampaigns();
    if (campaigns.isEmpty) return 1;
    return campaigns.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Get campaigns by location
  List<OfflineCampaign> getCampaignsByLocation(String location) {
    return _box?.values.where((campaign) => 
      campaign.locations.any((loc) => loc.toLowerCase().contains(location.toLowerCase()))
    ).toList() ?? [];
  }

  /// Get campaigns by target demographics
  List<OfflineCampaign> getCampaignsByDemographics({
    int? minAge,
    int? maxAge,
    String? gender,
    String? occupation,
  }) {
    return _box?.values.where((campaign) {
      bool matches = true;
      
      if (minAge != null && campaign.minAge != null) {
        matches = matches && campaign.minAge! <= minAge;
      }
      if (maxAge != null && campaign.maxAge != null) {
        matches = matches && campaign.maxAge! >= maxAge;
      }
      if (gender != null && campaign.gender != null) {
        matches = matches && campaign.gender!.toLowerCase() == gender.toLowerCase();
      }
      if (occupation != null && campaign.occupation != null) {
        matches = matches && campaign.occupation!.toLowerCase().contains(occupation.toLowerCase());
      }
      
      return matches;
    }).toList() ?? [];
  }

  /// Get aggregate metrics for all campaigns
  Map<String, dynamic> getAggregateMetrics() {
    final campaigns = getAllCampaigns();
    if (campaigns.isEmpty) {
      return {
        'totalCampaigns': 0,
        'totalBudget': 0.0,
        'totalImpressions': 0,
        'totalClicks': 0,
        'totalConversions': 0,
        'totalCost': 0.0,
        'avgCostPerClick': 0.0,
        'avgCtr': 0.0,
        'avgConversionRate': 0.0,
      };
    }

    final totalBudget = campaigns.fold(0.0, (sum, campaign) => sum + campaign.budget);
    final totalImpressions = campaigns.fold(0, (sum, campaign) => sum + campaign.impressions);
    final totalClicks = campaigns.fold(0, (sum, campaign) => sum + campaign.clicks);
    final totalConversions = campaigns.fold(0, (sum, campaign) => sum + campaign.conversions);
    final totalCost = campaigns.fold(0.0, (sum, campaign) => sum + campaign.cost);

    return {
      'totalCampaigns': campaigns.length,
      'totalBudget': totalBudget,
      'totalImpressions': totalImpressions,
      'totalClicks': totalClicks,
      'totalConversions': totalConversions,
      'totalCost': totalCost,
      'avgCostPerClick': totalClicks > 0 ? totalCost / totalClicks : 0.0,
      'avgCtr': totalImpressions > 0 ? totalClicks / totalImpressions : 0.0,
      'avgConversionRate': totalImpressions > 0 ? totalConversions / totalImpressions : 0.0,
    };
  }

  /// Get metrics data over time for charts
  List<Map<String, dynamic>> getMetricsTimeSeries() {
    final campaigns = getAllCampaigns();
    final Map<DateTime, Map<String, int>> timeSeriesData = {};

    for (final campaign in campaigns) {
      if (campaign.lastUpdate != null) {
        final date = DateTime(
          campaign.lastUpdate!.year,
          campaign.lastUpdate!.month,
          campaign.lastUpdate!.day,
        );
        
        if (!timeSeriesData.containsKey(date)) {
          timeSeriesData[date] = {
            'impressions': 0,
            'clicks': 0,
            'conversions': 0,
          };
        }
        
        timeSeriesData[date]!['impressions'] = timeSeriesData[date]!['impressions']! + campaign.impressions;
        timeSeriesData[date]!['clicks'] = timeSeriesData[date]!['clicks']! + campaign.clicks;
        timeSeriesData[date]!['conversions'] = timeSeriesData[date]!['conversions']! + campaign.conversions;
      }
    }

    final sortedEntries = timeSeriesData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sortedEntries.map((entry) => {
      'date': entry.key,
      'impressions': entry.value['impressions'],
      'clicks': entry.value['clicks'],
      'conversions': entry.value['conversions'],
    }).toList();
  }
}