import 'package:flutter/material.dart';
import '../models/offline_campaign.dart';
import '../services/campaign_repository.dart';
import 'campaign_list_screen.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({Key? key}) : super(key: key);

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final CampaignRepository _repository = CampaignRepository();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDemo();
  }

  Future<void> _initDemo() async {
    await _repository.init();
    await _createSampleCampaigns();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _createSampleCampaigns() async {
    // Check if we already have campaigns
    if (_repository.getAllCampaigns().isNotEmpty) {
      return;
    }

    // Create sample campaigns to demonstrate the system
    final sampleCampaigns = [
      OfflineCampaign(
        id: 1,
        name: 'Downtown Business Cards',
        channel: 'Business Card',
        locations: ['New York Downtown', 'Financial District'],
        minAge: 25,
        maxAge: 45,
        gender: 'All',
        occupation: 'Professionals',
        interests: ['Business', 'Finance', 'Technology'],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 6, 30),
        budget: 2500.0,
        impressions: 15000,
        clicks: 750,
        conversions: 85,
        cost: 1800.0,
        lastUpdate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      OfflineCampaign(
        id: 2,
        name: 'Summer Festival Flyers',
        channel: 'Flyer',
        locations: ['Central Park', 'Times Square', 'Brooklyn Bridge'],
        minAge: 18,
        maxAge: 35,
        gender: 'All',
        occupation: 'Students',
        interests: ['Music', 'Entertainment', 'Events'],
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 8, 31),
        budget: 5000.0,
        impressions: 35000,
        clicks: 1400,
        conversions: 210,
        cost: 3200.0,
        lastUpdate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      OfflineCampaign(
        id: 3,
        name: 'Tech Conference Direct Mail',
        channel: 'Direct Mail',
        locations: ['San Francisco', 'Palo Alto', 'Mountain View'],
        minAge: 25,
        maxAge: 50,
        gender: 'All',
        occupation: 'Software Engineers',
        interests: ['Technology', 'AI', 'Software Development'],
        startDate: DateTime(2024, 3, 15),
        endDate: DateTime(2024, 5, 15),
        budget: 8000.0,
        impressions: 12000,
        clicks: 960,
        conversions: 144,
        cost: 6400.0,
        lastUpdate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      OfflineCampaign(
        id: 4,
        name: 'Highway Billboard Campaign',
        channel: 'Billboard',
        locations: ['I-95 Corridor', 'Route 101', 'Highway 1'],
        minAge: 21,
        maxAge: 65,
        gender: 'All',
        interests: ['Automotive', 'Travel', 'Tourism'],
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 12, 31),
        budget: 25000.0,
        impressions: 250000,
        clicks: 5000,
        conversions: 375,
        cost: 18000.0,
        lastUpdate: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      OfflineCampaign(
        id: 5,
        name: 'Local Radio Spots',
        channel: 'TV/Radio',
        locations: ['Los Angeles', 'Orange County', 'Riverside'],
        minAge: 30,
        maxAge: 55,
        gender: 'All',
        occupation: 'Working Professionals',
        interests: ['News', 'Business', 'Local Events'],
        startDate: DateTime(2024, 4, 1),
        endDate: DateTime(2024, 7, 31),
        budget: 15000.0,
        impressions: 180000,
        clicks: 7200,
        conversions: 540,
        cost: 12500.0,
        lastUpdate: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];

    for (final campaign in sampleCampaigns) {
      await _repository.saveCampaign(campaign);
    }
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Setting up demo campaigns...'),
                ],
              ),
            )
          : const CampaignListScreen(),
    );
  }
}

// Update main.dart to use DemoScreen
class CampaignManagerApp extends StatelessWidget {
  const CampaignManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campaign Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DemoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}