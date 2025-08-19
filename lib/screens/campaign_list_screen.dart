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
  final List<Color> _gradientColors = const [
    Color(0xFF6A11CB),
    Color(0xFF2575FC)
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Campaigns', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: const Color(0xFF2A2D34),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
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
            icon: const Icon(Icons.insights_outlined),
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
        backgroundColor: Colors.white,
        foregroundColor: _gradientColors[0],
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search campaigns...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
              filled: true,
              fillColor: const Color(0xFFF0F4F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _filterCampaigns();
            },
          ),
          const SizedBox(height: 16),
          const Text('Filter by Channel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF2A2D34),
              )
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _channels.map((channel) {
                final isSelected = _selectedChannel == channel;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(channel),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedChannel = channel;
                        _filterCampaigns();
                      });
                    },
                    backgroundColor: const Color(0xFFF0F4F8),
                    selectedColor: const Color(0xFF3B82F6).withOpacity(0.15),
                    checkmarkColor: const Color(0xFF3B82F6),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                        width: 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
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
          Image.asset(
            'assets/images/empty_campaigns.png',
            height: 150,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.campaign_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No campaigns found',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first campaign to get started',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToForm(),
            icon: const Icon(Icons.add),
            label: const Text('New Campaign'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _filteredCampaigns.length,
      itemBuilder: (context, index) {
        final campaign = _filteredCampaigns[index];
        return _buildCampaignCard(campaign);
      },
    );
  }

  Widget _buildCampaignCard(OfflineCampaign campaign) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetails(campaign),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: _getChannelColor(campaign.channel).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getChannelIcon(campaign.channel),
                        color: _getChannelColor(campaign.channel),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2A2D34),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            campaign.channel,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey[600],
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.attach_money_rounded,
                        color: const Color(0xFF4CAF50),
                        label: 'Budget',
                        value: '\$${campaign.budget.toStringAsFixed(0)}',
                      ),
                      _buildDivider(),
                      _buildStatItem(
                        icon: Icons.visibility_outlined,
                        color: const Color(0xFF3B82F6),
                        label: 'Impressions',
                        value: _formatNumber(campaign.impressions),
                      ),
                      _buildDivider(),
                      _buildStatItem(
                        icon: Icons.trending_up_rounded,
                        color: const Color(0xFFF59E0B),
                        label: 'CTR',
                        value: '${(campaign.ctr * 100).toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                ),
                if (campaign.locations.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            campaign.locations.join(', '),
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (campaign.minAge != null || campaign.maxAge != null || campaign.gender != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(Icons.people_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          _buildTargetingText(campaign),
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A2D34),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
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
        return const Color(0xFF3B82F6);
      case 'Direct Mail':
        return const Color(0xFF10B981);
      case 'Flyer':
        return const Color(0xFFF59E0B);
      case 'TV/Radio':
        return const Color(0xFF8B5CF6);
      case 'Billboard':
        return const Color(0xFFEF4444);
      case 'Event':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getChannelIcon(String channel) {
    switch (channel) {
      case 'Business Card':
        return Icons.contact_page_outlined;
      case 'Direct Mail':
        return Icons.mail_outline_rounded;
      case 'Flyer':
        return Icons.description_outlined;
      case 'TV/Radio':
        return Icons.radio_outlined;
      case 'Billboard':
        return Icons.view_compact_outlined;
      case 'Event':
        return Icons.event_outlined;
      default:
        return Icons.category_outlined;
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
        title: const Text('Campaign Metrics',
            style: TextStyle(fontWeight: FontWeight.w600)
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMetricRow('Total Campaigns', '${metrics['totalCampaigns']}', Icons.campaign_outlined),
              _buildMetricRow('Total Budget', '\$${metrics['totalBudget'].toStringAsFixed(0)}', Icons.attach_money_rounded),
              _buildMetricRow('Total Impressions', '${metrics['totalImpressions']}', Icons.visibility_outlined),
              _buildMetricRow('Total Clicks', '${metrics['totalClicks']}', Icons.touch_app_outlined),
              _buildMetricRow('Total Conversions', '${metrics['totalConversions']}', Icons.check_circle_outline),
              _buildMetricRow('Avg Cost Per Click', '\$${metrics['avgCostPerClick'].toStringAsFixed(2)}', Icons.monetization_on_outlined),
              _buildMetricRow('Avg CTR', '${(metrics['avgCtr'] * 100).toStringAsFixed(2)}%', Icons.trending_up_rounded),
              _buildMetricRow('Avg Conversion Rate', '${(metrics['avgConversionRate'] * 100).toStringAsFixed(2)}%', Icons.stacked_line_chart),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF3B82F6))),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF3B82F6), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2A2D34),
            ),
          ),
        ],
      ),
    );
  }
}


