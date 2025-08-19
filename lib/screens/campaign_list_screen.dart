import 'package:flutter/material.dart';
import '../models/offline_campaign.dart';
import '../services/campaign_repository.dart';
import '../widgets/aggregate_charts_widget.dart';
import 'campaign_form_screen.dart';
import 'campaign_details_screen.dart';

class CampaignListScreen extends StatefulWidget {
  const CampaignListScreen({Key? key}) : super(key: key);

  @override
  State<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen> {
  final CampaignRepository _repository = CampaignRepository();
  List<OfflineCampaign> _campaigns = [];
  List<OfflineCampaign> _filteredCampaigns = [];
  String _selectedChannel = 'All';
  String _searchQuery = '';

  final List<String> _channels = [
    'All',
    'Business Card',
    'Direct Mail',
    'Flyer',
    'TV/Radio',
    'Billboard',
    'Event',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _initRepository();
  }

  Future<void> _initRepository() async {
    await _repository.init();
    _loadCampaigns();
  }

  void _loadCampaigns() {
    setState(() {
      _campaigns = _repository.getAllCampaigns();
      _filterCampaigns();
    });
  }

  void _filterCampaigns() {
    setState(() {
      _filteredCampaigns = _campaigns.where((campaign) {
        final matchesChannel = _selectedChannel == 'All' || campaign.channel == _selectedChannel;
        final matchesSearch = _searchQuery.isEmpty ||
            campaign.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            campaign.channel.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesChannel && matchesSearch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Catalog'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AggregateChartsWidget(repository: _repository),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showAggregateMetrics();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _filteredCampaigns.isEmpty
                ? _buildEmptyState()
                : _buildCampaignList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search campaigns...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _filterCampaigns();
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Channel: ', style: TextStyle(fontWeight: FontWeight.w500)),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedChannel,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      _selectedChannel = value!;
                      _filterCampaigns();
                    });
                  },
                  items: _channels.map((channel) {
                    return DropdownMenuItem(
                      value: channel,
                      child: Text(channel),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No campaigns found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first campaign to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignList() {
    return ListView.builder(
      itemCount: _filteredCampaigns.length,
      itemBuilder: (context, index) {
        final campaign = _filteredCampaigns[index];
        return _buildCampaignCard(campaign);
      },
    );
  }

  Widget _buildCampaignCard(OfflineCampaign campaign) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetails(campaign),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      campaign.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getChannelColor(campaign.channel),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      campaign.channel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      campaign.locations.join(', '),
                      style: TextStyle(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMetricChip('Budget', '\$${campaign.budget.toStringAsFixed(0)}'),
                  const SizedBox(width: 8),
                  _buildMetricChip('Impressions', campaign.impressions.toString()),
                  const SizedBox(width: 8),
                  _buildMetricChip('CTR', '${(campaign.ctr * 100).toStringAsFixed(1)}%'),
                ],
              ),
              if (campaign.minAge != null || campaign.maxAge != null || campaign.gender != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _buildTargetingText(campaign),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  String _buildTargetingText(OfflineCampaign campaign) {
    final parts = <String>[];
    if (campaign.minAge != null && campaign.maxAge != null) {
      parts.add('${campaign.minAge}-${campaign.maxAge} years');
    } else if (campaign.minAge != null) {
      parts.add('${campaign.minAge}+ years');
    } else if (campaign.maxAge != null) {
      parts.add('Under ${campaign.maxAge} years');
    }
    if (campaign.gender != null) {
      parts.add(campaign.gender!);
    }
    return parts.join(', ');
  }

  Color _getChannelColor(String channel) {
    switch (channel) {
      case 'Business Card':
        return Colors.blue;
      case 'Direct Mail':
        return Colors.green;
      case 'Flyer':
        return Colors.orange;
      case 'TV/Radio':
        return Colors.purple;
      case 'Billboard':
        return Colors.red;
      case 'Event':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  void _navigateToForm([OfflineCampaign? campaign]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignFormScreen(
          repository: _repository,
          campaign: campaign,
        ),
      ),
    );
    if (result == true) {
      _loadCampaigns();
    }
  }

  void _navigateToDetails(OfflineCampaign campaign) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignDetailsScreen(
          campaign: campaign,
          repository: _repository,
        ),
      ),
    );
    _loadCampaigns();
  }

  void _showAggregateMetrics() {
    final metrics = _repository.getAggregateMetrics();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aggregate Metrics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Campaigns: ${metrics['totalCampaigns']}'),
            Text('Total Budget: \$${metrics['totalBudget'].toStringAsFixed(2)}'),
            Text('Total Impressions: ${metrics['totalImpressions']}'),
            Text('Total Clicks: ${metrics['totalClicks']}'),
            Text('Total Conversions: ${metrics['totalConversions']}'),
            Text('Avg Cost Per Click: \$${metrics['avgCostPerClick'].toStringAsFixed(2)}'),
            Text('Avg CTR: ${(metrics['avgCtr'] * 100).toStringAsFixed(2)}%'),
            Text('Avg Conversion Rate: ${(metrics['avgConversionRate'] * 100).toStringAsFixed(2)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}