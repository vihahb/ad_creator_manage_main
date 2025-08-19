import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ad_creator_manage_main/models/offline_campaign.dart';
import 'package:ad_creator_manage_main/services/campaign_repository.dart';

void main() {
  late CampaignRepository repository;
  
  setUpAll(() async {
    // Initialize Hive for testing
    Hive.init('./test_hive');
  });

  setUp(() async {
    repository = CampaignRepository();
    await repository.init();
  });

  tearDown(() async {
    await repository.close();
    await Hive.deleteBoxFromDisk('campaigns');
  });

  group('Campaign Repository Tests', () {
    test('should save and retrieve campaigns', () async {
      final campaign = OfflineCampaign(
        id: 1,
        name: 'Test Campaign',
        channel: 'Business Card',
        locations: ['New York', 'Los Angeles'],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        budget: 1000.0,
        minAge: 25,
        maxAge: 45,
        gender: 'All',
        occupation: 'Professionals',
        interests: ['Technology', 'Business'],
      );

      await repository.saveCampaign(campaign);

      final retrievedCampaign = repository.getCampaignById(1);
      expect(retrievedCampaign, isNotNull);
      expect(retrievedCampaign!.name, equals('Test Campaign'));
      expect(retrievedCampaign.channel, equals('Business Card'));
      expect(retrievedCampaign.locations, equals(['New York', 'Los Angeles']));
      expect(retrievedCampaign.minAge, equals(25));
      expect(retrievedCampaign.maxAge, equals(45));
      expect(retrievedCampaign.gender, equals('All'));
      expect(retrievedCampaign.occupation, equals('Professionals'));
      expect(retrievedCampaign.interests, equals(['Technology', 'Business']));
    });

    test('should filter campaigns by channel', () async {
      final campaign1 = OfflineCampaign(
        id: 1,
        name: 'Business Card Campaign',
        channel: 'Business Card',
        locations: ['New York'],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        budget: 500.0,
      );

      final campaign2 = OfflineCampaign(
        id: 2,
        name: 'Flyer Campaign',
        channel: 'Flyer',
        locations: ['Los Angeles'],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        budget: 800.0,
      );

      await repository.saveCampaign(campaign1);
      await repository.saveCampaign(campaign2);

      final businessCardCampaigns = repository.getCampaignsByChannel('Business Card');
      expect(businessCardCampaigns.length, equals(1));
      expect(businessCardCampaigns.first.name, equals('Business Card Campaign'));

      final flyerCampaigns = repository.getCampaignsByChannel('Flyer');
      expect(flyerCampaigns.length, equals(1));
      expect(flyerCampaigns.first.name, equals('Flyer Campaign'));
    });

    test('should filter campaigns by location', () async {
      final campaign1 = OfflineCampaign(
        id: 1,
        name: 'NYC Campaign',
        channel: 'Business Card',
        locations: ['New York', 'Brooklyn'],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        budget: 500.0,
      );

      final campaign2 = OfflineCampaign(
        id: 2,
        name: 'LA Campaign',
        channel: 'Flyer',
        locations: ['Los Angeles', 'Hollywood'],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        budget: 800.0,
      );

      await repository.saveCampaign(campaign1);
      await repository.saveCampaign(campaign2);

      final nyCampaigns = repository.getCampaignsByLocation('New York');
      expect(nyCampaigns.length, equals(1));
      expect(nyCampaigns.first.name, equals('NYC Campaign'));

      final laCampaigns = repository.getCampaignsByLocation('Los Angeles');
      expect(laCampaigns.length, equals(1));
      expect(laCampaigns.first.name, equals('LA Campaign'));
    });

    test('should calculate aggregate metrics correctly', () async {
      final campaign1 = OfflineCampaign(
        id: 1,
        name: 'Campaign 1',
        channel: 'Business Card',
        locations: ['New York'],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        budget: 1000.0,
        impressions: 10000,
        clicks: 500,
        conversions: 50,
        cost: 800.0,
      );

      final campaign2 = OfflineCampaign(
        id: 2,
        name: 'Campaign 2',
        channel: 'Flyer',
        locations: ['Los Angeles'],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        budget: 1500.0,
        impressions: 15000,
        clicks: 750,
        conversions: 75,
        cost: 1200.0,
      );

      await repository.saveCampaign(campaign1);
      await repository.saveCampaign(campaign2);

      final metrics = repository.getAggregateMetrics();
      
      expect(metrics['totalCampaigns'], equals(2));
      expect(metrics['totalBudget'], equals(2500.0));
      expect(metrics['totalImpressions'], equals(25000));
      expect(metrics['totalClicks'], equals(1250));
      expect(metrics['totalConversions'], equals(125));
      expect(metrics['totalCost'], equals(2000.0));
      expect(metrics['avgCostPerClick'], equals(1.6)); // 2000 / 1250
      expect(metrics['avgCtr'], equals(0.05)); // 1250 / 25000
      expect(metrics['avgConversionRate'], equals(0.005)); // 125 / 25000
    });

    test('should update campaign metrics', () async {
      final campaign = OfflineCampaign(
        id: 1,
        name: 'Test Campaign',
        channel: 'Business Card',
        locations: ['New York'],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        budget: 1000.0,
      );

      await repository.saveCampaign(campaign);

      // Update metrics
      campaign.updateMetrics(
        timestamp: DateTime.now(),
        impressions: 5000,
        clicks: 250,
        conversions: 25,
        cost: 400.0,
      );

      await repository.saveCampaign(campaign);

      final updatedCampaign = repository.getCampaignById(1);
      expect(updatedCampaign!.impressions, equals(5000));
      expect(updatedCampaign.clicks, equals(250));
      expect(updatedCampaign.conversions, equals(25));
      expect(updatedCampaign.cost, equals(400.0));
      expect(updatedCampaign.costPerClick, equals(1.6)); // 400 / 250
      expect(updatedCampaign.ctr, equals(0.05)); // 250 / 5000
    });

    test('should delete campaigns', () async {
      final campaign = OfflineCampaign(
        id: 1,
        name: 'Test Campaign',
        channel: 'Business Card',
        locations: ['New York'],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        budget: 1000.0,
      );

      await repository.saveCampaign(campaign);
      expect(repository.getCampaignById(1), isNotNull);

      await repository.deleteCampaign(1);
      expect(repository.getCampaignById(1), isNull);
    });

    test('should generate next available ID', () {
      expect(repository.getNextId(), equals(1));

      // Add some campaigns to test ID generation
      final campaigns = [
        OfflineCampaign(
          id: 1,
          name: 'Campaign 1',
          channel: 'Business Card',
          locations: ['NYC'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 12, 31),
          budget: 1000.0,
        ),
        OfflineCampaign(
          id: 3,
          name: 'Campaign 3',
          channel: 'Flyer',
          locations: ['LA'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 12, 31),
          budget: 1500.0,
        ),
      ];

      campaigns.forEach((campaign) async {
        await repository.saveCampaign(campaign);
      });

      expect(repository.getNextId(), equals(4));
    });
  });

  group('OfflineCampaign Model Tests', () {
    test('should calculate cost per click correctly', () {
      final campaign = OfflineCampaign(
        id: 1,
        name: 'Test Campaign',
        channel: 'Business Card',
        locations: ['NYC'],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        budget: 1000.0,
        clicks: 100,
        cost: 500.0,
      );

      expect(campaign.costPerClick, equals(5.0));
    });

    test('should handle zero clicks for cost per click', () {
      final campaign = OfflineCampaign(
        id: 1,
        name: 'Test Campaign',
        channel: 'Business Card',
        locations: ['NYC'],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        budget: 1000.0,
        clicks: 0,
        cost: 500.0,
      );

      expect(campaign.costPerClick, equals(0.0));
    });

    test('should calculate CTR correctly', () {
      final campaign = OfflineCampaign(
        id: 1,
        name: 'Test Campaign',
        channel: 'Business Card',
        locations: ['NYC'],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        budget: 1000.0,
        impressions: 10000,
        clicks: 500,
      );

      expect(campaign.ctr, equals(0.05));
    });

    test('should calculate conversion rate correctly', () {
      final campaign = OfflineCampaign(
        id: 1,
        name: 'Test Campaign',
        channel: 'Business Card',
        locations: ['NYC'],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        budget: 1000.0,
        impressions: 10000,
        conversions: 100,
      );

      expect(campaign.conversionRate, equals(0.01));
    });
  });
}