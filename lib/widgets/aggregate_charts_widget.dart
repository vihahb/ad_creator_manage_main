import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/campaign_repository.dart';

class AggregateChartsWidget extends StatefulWidget {
  final CampaignRepository repository;

  const AggregateChartsWidget({
    Key? key,
    required this.repository,
  }) : super(key: key);

  @override
  State<AggregateChartsWidget> createState() => _AggregateChartsWidgetState();
}

class _AggregateChartsWidgetState extends State<AggregateChartsWidget> {
  final ColorScheme _colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF5C6BC0),
    brightness: Brightness.light,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        elevation: 0,
        backgroundColor: _colorScheme.primary,
        foregroundColor: _colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_colorScheme.primary.withOpacity(0.05), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDashboardHeader(),
              const SizedBox(height: 16),
              _buildTimeSeriesChart(),
              const SizedBox(height: 24),
              _buildChannelDistributionChart(),
              const SizedBox(height: 24),
              _buildMetricsComparisonChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardHeader() {
    final campaigns = widget.repository.getAllCampaigns();
    final metrics = widget.repository.getMetricsTimeSeries();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Campaign Analytics',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: _colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                Icons.campaign_outlined,
                campaigns.length.toString(),
                'Total Campaigns',
                _colorScheme.primary,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                Icons.visibility_outlined,
                _calculateTotalMetric(metrics, 'impressions').toString(),
                'Impressions',
                _colorScheme.secondary,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                Icons.touch_app_outlined,
                _calculateTotalMetric(metrics, 'clicks').toString(),
                'Clicks',
                _colorScheme.tertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSeriesChart() {
    final timeSeriesData = widget.repository.getMetricsTimeSeries();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Performance Trends',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _colorScheme.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: _colorScheme.primary),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 320,
              child: timeSeriesData.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timeline_outlined,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No timeline data available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
                  : SfCartesianChart(
                margin: const EdgeInsets.all(0),
                plotAreaBorderWidth: 0,
                primaryXAxis: DateTimeAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: TextStyle(color: Colors.grey[600]),
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: Colors.grey[300],
                    dashArray: const <double>[5, 5],
                  ),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: TextStyle(color: Colors.grey[600]),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<_TimeSeriesData, DateTime>>[
                  SplineAreaSeries<_TimeSeriesData, DateTime>(
                    dataSource: _getTimeSeriesChartData(timeSeriesData, 'impressions'),
                    xValueMapper: (_TimeSeriesData data, _) => data.date,
                    yValueMapper: (_TimeSeriesData data, _) => data.value,
                    name: 'Impressions',
                    color: _colorScheme.primary.withOpacity(0.5),
                    borderColor: _colorScheme.primary,
                    borderWidth: 3,
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      color: _colorScheme.primary,
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
                  ),
                  SplineAreaSeries<_TimeSeriesData, DateTime>(
                    dataSource: _getTimeSeriesChartData(timeSeriesData, 'clicks'),
                    xValueMapper: (_TimeSeriesData data, _) => data.date,
                    yValueMapper: (_TimeSeriesData data, _) => data.value,
                    name: 'Clicks',
                    color: _colorScheme.secondary.withOpacity(0.5),
                    borderColor: _colorScheme.secondary,
                    borderWidth: 3,
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      color: _colorScheme.secondary,
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
                  ),
                  SplineAreaSeries<_TimeSeriesData, DateTime>(
                    dataSource: _getTimeSeriesChartData(timeSeriesData, 'conversions'),
                    xValueMapper: (_TimeSeriesData data, _) => data.date,
                    yValueMapper: (_TimeSeriesData data, _) => data.value,
                    name: 'Conversions',
                    color: _colorScheme.tertiary.withOpacity(0.5),
                    borderColor: _colorScheme.tertiary,
                    borderWidth: 3,
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      color: _colorScheme.tertiary,
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelDistributionChart() {
    final campaigns = widget.repository.getAllCampaigns();
    final channelData = <String, int>{};

    for (final campaign in campaigns) {
      channelData[campaign.channel] = (channelData[campaign.channel] ?? 0) + 1;
    }

    // Define a set of visually pleasing colors for the pie chart
    final List<Color> pieColors = [
      _colorScheme.primary,
      _colorScheme.secondary,
      _colorScheme.tertiary,
      Colors.amber,
      Colors.teal,
      Colors.purple,
      Colors.indigo,
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Channel Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _colorScheme.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: _colorScheme.primary),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 320,
              child: channelData.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart_outline,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No channel data available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
                  : SfCircularChart(
                margin: const EdgeInsets.all(0),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CircularSeries<_ChannelData, String>>[
                  DoughnutSeries<_ChannelData, String>(
                    dataSource: _getChannelChartData(channelData),
                    xValueMapper: (_ChannelData data, _) => data.channel,
                    yValueMapper: (_ChannelData data, _) => data.count,
                    pointColorMapper: (_ChannelData data, index) =>
                    pieColors[index! % pieColors.length],
                    dataLabelMapper: (_ChannelData data, _) => data.channel,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      connectorLineSettings: ConnectorLineSettings(
                        type: ConnectorType.curve,
                        length: '10%',
                      ),
                    ),
                    innerRadius: '60%',
                    radius: '80%',
                    explode: true,
                    explodeIndex: 0,
                    explodeOffset: '5%',
                    enableTooltip: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsComparisonChart() {
    final campaigns = widget.repository.getAllCampaigns();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Campaign Comparison',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _colorScheme.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: _colorScheme.primary),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 320,
              child: campaigns.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_outlined,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No campaign data available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
                  : SfCartesianChart(
                margin: const EdgeInsets.all(0),
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  labelRotation: -45,
                  labelStyle: TextStyle(color: Colors.grey[600], fontSize: 10),
                  axisLine: const AxisLine(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: Colors.grey[300],
                    dashArray: const <double>[5, 5],
                  ),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: TextStyle(color: Colors.grey[600]),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                series: <CartesianSeries<_CampaignMetrics, String>>[
                  BarSeries<_CampaignMetrics, String>(
                    dataSource: _getCampaignMetricsData(campaigns),
                    xValueMapper: (_CampaignMetrics data, _) => data.campaignName,
                    yValueMapper: (_CampaignMetrics data, _) => data.impressions,
                    name: 'Impressions',
                    color: _colorScheme.primary,
                    width: 0.7,
                    spacing: 0.2,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  BarSeries<_CampaignMetrics, String>(
                    dataSource: _getCampaignMetricsData(campaigns),
                    xValueMapper: (_CampaignMetrics data, _) => data.campaignName,
                    yValueMapper: (_CampaignMetrics data, _) => data.clicks,
                    name: 'Clicks',
                    color: _colorScheme.secondary,
                    width: 0.7,
                    spacing: 0.2,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  BarSeries<_CampaignMetrics, String>(
                    dataSource: _getCampaignMetricsData(campaigns),
                    xValueMapper: (_CampaignMetrics data, _) => data.campaignName,
                    yValueMapper: (_CampaignMetrics data, _) => data.conversions,
                    name: 'Conversions',
                    color: _colorScheme.tertiary,
                    width: 0.7,
                    spacing: 0.2,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTotalMetric(List<Map<String, dynamic>> metrics, String metricName) {
    if (metrics.isEmpty) return 0;
    return metrics.fold(0, (sum, item) => sum + (item[metricName] as int));
  }

  List<_TimeSeriesData> _getTimeSeriesChartData(
      List<Map<String, dynamic>> timeSeriesData,
      String metric,
      ) {
    return timeSeriesData.map((data) {
      return _TimeSeriesData(
        data['date'] as DateTime,
        (data[metric] as int).toDouble(),
      );
    }).toList();
  }

  List<_ChannelData> _getChannelChartData(Map<String, int> channelData) {
    return channelData.entries.map((entry) {
      return _ChannelData(entry.key, entry.value);
    }).toList();
  }

  List<_CampaignMetrics> _getCampaignMetricsData(campaigns) {
    // Limit to 6 campaigns for better readability
    return campaigns.take(6).map<_CampaignMetrics>((campaign) {
      return _CampaignMetrics(
        campaign.name.length > 12
            ? '${campaign.name.substring(0, 12)}...'
            : campaign.name,
        campaign.impressions.toDouble(),
        campaign.clicks.toDouble(),
        campaign.conversions.toDouble(),
      );
    }).toList();
  }
}

class _TimeSeriesData {
  _TimeSeriesData(this.date, this.value);
  final DateTime date;
  final double value;
}

class _ChannelData {
  _ChannelData(this.channel, this.count);
  final String channel;
  final int count;
}

class _CampaignMetrics {
  _CampaignMetrics(this.campaignName, this.impressions, this.clicks, this.conversions);
  final String campaignName;
  final double impressions;
  final double clicks;
  final double conversions;
}