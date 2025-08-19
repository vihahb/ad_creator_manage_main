import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/offline_campaign.dart';
import '../services/campaign_repository.dart';
import 'campaign_form_screen.dart';

class CampaignDetailsScreen extends StatefulWidget {
  final OfflineCampaign campaign;
  final CampaignRepository repository;

  const CampaignDetailsScreen({
    Key? key,
    required this.campaign,
    required this.repository,
  }) : super(key: key);

  @override
  State<CampaignDetailsScreen> createState() => _CampaignDetailsScreenState();
}

class _CampaignDetailsScreenState extends State<CampaignDetailsScreen> {
  late OfflineCampaign _campaign;

  @override
  void initState() {
    super.initState();
    _campaign = widget.campaign;
  }

  void _refreshCampaign() {
    final updated = widget.repository.getCampaignById(_campaign.id);
    if (updated != null) {
      setState(() {
        _campaign = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_campaign.name),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editCampaign,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCampaignHeader(),
            const SizedBox(height: 24),
            _buildMetricsOverview(),
            const SizedBox(height: 24),
            _buildPerformanceChart(),
            const SizedBox(height: 24),
            _buildTargetingInfo(),
            const SizedBox(height: 24),
            _buildTimelineInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _campaign.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getChannelColor(_campaign.channel),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _campaign.channel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _campaign.locations.join(', '),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Budget: \$${_campaign.budget.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Metrics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMetricCard('Impressions', _campaign.impressions.toString(), Icons.visibility)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Clicks', _campaign.clicks.toString(), Icons.mouse)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard('Conversions', _campaign.conversions.toString(), Icons.trending_up)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Cost', '\$${_campaign.cost.toStringAsFixed(2)}', Icons.money)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard('CTR', '${(_campaign.ctr * 100).toStringAsFixed(2)}%', Icons.percent)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('CPC', '\$${_campaign.costPerClick.toStringAsFixed(2)}', Icons.monetization_on)),
          ],
        ),
        const SizedBox(height: 12),
        _buildMetricCard('Conversion Rate', '${(_campaign.conversionRate * 100).toStringAsFixed(2)}%', Icons.bar_chart),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue[700]),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Visualization',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    title: ChartTitle(text: 'Campaign Metrics Overview'),
                    legend: Legend(isVisible: true),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<_ChartData, String>>[
                      AreaSeries<_ChartData, String>(
                        dataSource: _getChartData(),
                        xValueMapper: (_ChartData data, _) => data.category,
                        yValueMapper: (_ChartData data, _) => data.value,
                        name: 'Metrics',
                        color: Colors.blue.withOpacity(0.7),
                        borderColor: Colors.blue,
                        borderWidth: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildFunnelChart(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFunnelChart() {
    return Column(
      children: [
        const Text(
          'Conversion Funnel',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: SfPyramidChart(
            title: ChartTitle(text: 'Campaign Funnel'),
            series: PyramidSeries<_FunnelData, String>(
              dataSource: _getFunnelData(),
              xValueMapper: (_FunnelData data, _) => data.stage,
              yValueMapper: (_FunnelData data, _) => data.value,
              textFieldMapper: (_FunnelData data, _) => '${data.stage}: ${data.value}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Targeting Information',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTargetingRow('Geographic', _campaign.locations.join(', ')),
                if (_campaign.minAge != null || _campaign.maxAge != null)
                  _buildTargetingRow('Age Range', _buildAgeRangeText()),
                if (_campaign.gender != null)
                  _buildTargetingRow('Gender', _campaign.gender!),
                if (_campaign.occupation != null)
                  _buildTargetingRow('Occupation', _campaign.occupation!),
                if (_campaign.interests.isNotEmpty)
                  _buildTargetingRow('Interests', _campaign.interests.join(', ')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Campaign Timeline',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTimelineRow('Start Date', _formatDate(_campaign.startDate)),
                _buildTimelineRow('End Date', _formatDate(_campaign.endDate)),
                if (_campaign.lastUpdate != null)
                  _buildTimelineRow('Last Updated', _formatDate(_campaign.lastUpdate!)),
                _buildTimelineRow('Duration', _calculateDuration()),
                _buildTimelineRow('Status', _getStatus()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  List<_ChartData> _getChartData() {
    return [
      _ChartData('Impressions', _campaign.impressions.toDouble()),
      _ChartData('Clicks', _campaign.clicks.toDouble()),
      _ChartData('Conversions', _campaign.conversions.toDouble()),
    ];
  }

  List<_FunnelData> _getFunnelData() {
    return [
      _FunnelData('Impressions', _campaign.impressions),
      _FunnelData('Clicks', _campaign.clicks),
      _FunnelData('Conversions', _campaign.conversions),
    ];
  }

  String _buildAgeRangeText() {
    if (_campaign.minAge != null && _campaign.maxAge != null) {
      return '${_campaign.minAge} - ${_campaign.maxAge} years';
    } else if (_campaign.minAge != null) {
      return '${_campaign.minAge}+ years';
    } else if (_campaign.maxAge != null) {
      return 'Under ${_campaign.maxAge} years';
    }
    return 'Not specified';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _calculateDuration() {
    final duration = _campaign.endDate.difference(_campaign.startDate).inDays;
    return '$duration days';
  }

  String _getStatus() {
    final now = DateTime.now();
    if (now.isBefore(_campaign.startDate)) {
      return 'Scheduled';
    } else if (now.isAfter(_campaign.endDate)) {
      return 'Completed';
    } else {
      return 'Active';
    }
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

  void _editCampaign() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignFormScreen(
          repository: widget.repository,
          campaign: _campaign,
        ),
      ),
    );
    if (result == true) {
      _refreshCampaign();
    }
  }
}

class _ChartData {
  _ChartData(this.category, this.value);
  final String category;
  final double value;
}

class _FunnelData {
  _FunnelData(this.stage, this.value);
  final String stage;
  final int value;
}