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
  final Color _primaryColor = const Color(0xFF3A86FF);
  final Color _secondaryColor = const Color(0xFFFF006E);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _surfaceColor = Colors.white;
  final Color _textPrimaryColor = const Color(0xFF212529);
  final Color _textSecondaryColor = const Color(0xFF6C757D);

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
      backgroundColor: _backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCampaignHeader(),
                const SizedBox(height: 24),
                _buildMetricsOverview(),
                const SizedBox(height: 24),
                _buildPerformanceChart(),
                const SizedBox(height: 24),
                _buildTargetingInfo(),
                const SizedBox(height: 24),
                _buildTimelineInfo(),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _editCampaign,
        backgroundColor: _secondaryColor,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: _primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _campaign.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshCampaign,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildCampaignHeader() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campaign Overview',
                        style: TextStyle(
                          fontSize: 16,
                          color: _textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _campaign.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildChannelChip(_campaign.channel),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(Icons.location_on_outlined, _campaign.locations.join(', ')),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.attach_money_outlined, 'Budget: \$${_campaign.budget.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today_outlined, '${_formatDate(_campaign.startDate)} - ${_formatDate(_campaign.endDate)}'),
            const SizedBox(height: 12),
            _buildStatusIndicator(_getStatus()),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelChip(String channel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getChannelColor(channel).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getChannelIcon(channel),
            size: 16,
            color: _getChannelColor(channel),
          ),
          const SizedBox(width: 6),
          Text(
            channel,
            style: TextStyle(
              color: _getChannelColor(channel),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: _textPrimaryColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color statusColor;
    switch (status) {
      case 'Active':
        statusColor = Colors.green;
        break;
      case 'Scheduled':
        statusColor = Colors.blue;
        break;
      case 'Completed':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Performance Metrics', Icons.insert_chart_outlined),
        // const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // crossAxisSpacing: 12,
          // mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildMetricCard('Impressions', _campaign.impressions.toString(), Icons.visibility_outlined, const Color(0xFF4361EE)),
            _buildMetricCard('Clicks', _campaign.clicks.toString(), Icons.touch_app_outlined, const Color(0xFF3A0CA3)),
            _buildMetricCard('Conversions', _campaign.conversions.toString(), Icons.shopping_cart_outlined, const Color(0xFF7209B7)),
            _buildMetricCard('Cost', '\$${_campaign.cost.toStringAsFixed(2)}', Icons.payments_outlined, const Color(0xFFF72585)),
            _buildMetricCard('CTR', '${(_campaign.ctr * 100).toStringAsFixed(2)}%', Icons.percent_outlined, const Color(0xFF4CC9F0)),
            _buildMetricCard('CPC', '\$${_campaign.costPerClick.toStringAsFixed(2)}', Icons.attach_money_outlined, const Color(0xFF4895EF)),
          ],
        ),
        const SizedBox(height: 12),
        _buildConversionRateCard(),
      ],
    );
  }

  Widget _buildConversionRateCard() {
    final conversionRate = _campaign.conversionRate * 100;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: _secondaryColor),
                const SizedBox(width: 8),
                Text(
                  'Conversion Rate',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 24,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: conversionRate / 100 > 1 ? 1 : conversionRate / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryColor, _secondaryColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0%',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSecondaryColor,
                  ),
                ),
                Text(
                  '${conversionRate.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _secondaryColor,
                  ),
                ),
                Text(
                  '100%',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textPrimaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: _textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Performance Analytics', Icons.analytics_outlined),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey.shade200),
                  axisLine: const AxisLine(width: 0),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                legend: Legend(isVisible: true, position: LegendPosition.bottom),
                series: <CartesianSeries<_ChartData, String>>[
                  AreaSeries<_ChartData, String>(
                    dataSource: _getChartData(),
                    xValueMapper: (_ChartData data, _) => data.category,
                    yValueMapper: (_ChartData data, _) => data.value,
                    name: 'Metrics',
                    borderWidth: 3,
                    borderColor: _primaryColor,
                    color: _primaryColor.withOpacity(0.2),
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      shape: DataMarkerType.circle,
                      borderColor: _primaryColor,
                      borderWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildFunnelChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildFunnelChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conversion Funnel',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: SfPyramidChart(
            palette: [
              _primaryColor,
              _primaryColor.withOpacity(0.8),
              _primaryColor.withOpacity(0.6),
            ],
            tooltipBehavior: TooltipBehavior(enable: true),
            series: PyramidSeries<_FunnelData, String>(
              dataSource: _getFunnelData(),
              xValueMapper: (_FunnelData data, _) => data.stage,
              yValueMapper: (_FunnelData data, _) => data.value,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetingInfo() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Audience Targeting', Icons.people_alt_outlined),
            const SizedBox(height: 20),
            _buildTargetingRow('Geographic', _campaign.locations.join(', '), Icons.map_outlined),
            if (_campaign.minAge != null || _campaign.maxAge != null)
              _buildTargetingRow('Age Range', _buildAgeRangeText(), Icons.person_outline),
            if (_campaign.gender != null)
              _buildTargetingRow('Gender', _campaign.gender!, Icons.wc_outlined),
            if (_campaign.occupation != null)
              _buildTargetingRow('Occupation', _campaign.occupation!, Icons.work_outline),
            if (_campaign.interests.isNotEmpty)
              _buildTargetingRow('Interests', _campaign.interests.join(', '), Icons.favorite_border),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetingRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: _textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: _textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineInfo() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Campaign Timeline', Icons.timeline_outlined),
            const SizedBox(height: 20),
            _buildTimelineItem('Start Date', _formatDate(_campaign.startDate), 0),
            _buildTimelineDivider(),
            _buildTimelineItem('Duration', _calculateDuration(), 1),
            _buildTimelineDivider(),
            _buildTimelineItem('End Date', _formatDate(_campaign.endDate), 2),
            if (_campaign.lastUpdate != null) ...[
              _buildTimelineDivider(),
              _buildTimelineItem('Last Updated', _formatDate(_campaign.lastUpdate!), 3),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String label, String value, int index) {
    final isActive = _isTimelineItemActive(index);

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? _primaryColor : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? _primaryColor.withOpacity(0.2) : Colors.grey.shade200,
              width: 4,
            ),
          ),
          child: isActive
              ? const Icon(Icons.check, color: Colors.white, size: 12)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: _textSecondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isActive ? _textPrimaryColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 11.5),
      child: SizedBox(
        height: 30,
        width: 1,
        child: Container(color: Colors.grey.shade300),
      ),
    );
  }

  bool _isTimelineItemActive(int index) {
    final now = DateTime.now();
    switch (index) {
      case 0:
        return true; // Start date is always active
      case 1:
        return now.isAfter(_campaign.startDate); // Duration is active if started
      case 2:
        return now.isAfter(_campaign.endDate); // End date is active if ended
      case 3:
        return true; // Last updated is always active
      default:
        return false;
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textPrimaryColor,
          ),
        ),
      ],
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
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
        return const Color(0xFF3A86FF);
      case 'Direct Mail':
        return const Color(0xFF2EC4B6);
      case 'Flyer':
        return const Color(0xFFFF9F1C);
      case 'TV/Radio':
        return const Color(0xFF7209B7);
      case 'Billboard':
        return const Color(0xFFE71D36);
      case 'Event':
        return const Color(0xFF06D6A0);
      default:
        return const Color(0xFF6C757D);
    }
  }

  IconData _getChannelIcon(String channel) {
    switch (channel) {
      case 'Business Card':
        return Icons.contact_page_outlined;
      case 'Direct Mail':
        return Icons.mail_outline;
      case 'Flyer':
        return Icons.description_outlined;
      case 'TV/Radio':
        return Icons.radio_outlined;
      case 'Billboard':
        return Icons.visibility_outlined;
      case 'Event':
        return Icons.event_outlined;
      default:
        return Icons.campaign_outlined;
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