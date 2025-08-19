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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Overview'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeSeriesChart(),
            const SizedBox(height: 24),
            _buildChannelDistributionChart(),
            const SizedBox(height: 24),
            _buildMetricsComparisonChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSeriesChart() {
    final timeSeriesData = widget.repository.getMetricsTimeSeries();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metrics Over Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: timeSeriesData.isEmpty
                  ? const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : SfCartesianChart(
                      primaryXAxis: DateTimeAxis(),
                      primaryYAxis: NumericAxis(),
                      title: ChartTitle(text: 'Campaign Performance Timeline'),
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <ChartSeries<_TimeSeriesData, DateTime>>[
                        AreaSeries<_TimeSeriesData, DateTime>(
                          dataSource: _getTimeSeriesChartData(timeSeriesData, 'impressions'),
                          xValueMapper: (_TimeSeriesData data, _) => data.date,
                          yValueMapper: (_TimeSeriesData data, _) => data.value,
                          name: 'Impressions',
                          color: Colors.blue.withOpacity(0.7),
                          borderColor: Colors.blue,
                          borderWidth: 2,
                        ),
                        AreaSeries<_TimeSeriesData, DateTime>(
                          dataSource: _getTimeSeriesChartData(timeSeriesData, 'clicks'),
                          xValueMapper: (_TimeSeriesData data, _) => data.date,
                          yValueMapper: (_TimeSeriesData data, _) => data.value,
                          name: 'Clicks',
                          color: Colors.green.withOpacity(0.7),
                          borderColor: Colors.green,
                          borderWidth: 2,
                        ),
                        AreaSeries<_TimeSeriesData, DateTime>(
                          dataSource: _getTimeSeriesChartData(timeSeriesData, 'conversions'),
                          xValueMapper: (_TimeSeriesData data, _) => data.date,
                          yValueMapper: (_TimeSeriesData data, _) => data.value,
                          name: 'Conversions',
                          color: Colors.orange.withOpacity(0.7),
                          borderColor: Colors.orange,
                          borderWidth: 2,
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

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Campaigns by Channel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: channelData.isEmpty
                  ? const Center(
                      child: Text(
                        'No campaigns available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : SfCircularChart(
                      title: ChartTitle(text: 'Channel Distribution'),
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <PieSeries<_ChannelData, String>>[
                        PieSeries<_ChannelData, String>(
                          dataSource: _getChannelChartData(channelData),
                          xValueMapper: (_ChannelData data, _) => data.channel,
                          yValueMapper: (_ChannelData data, _) => data.count,
                          dataLabelMapper: (_ChannelData data, _) => '${data.channel}\n${data.count}',
                          dataLabelSettings: const DataLabelSettings(isVisible: true),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Campaign Performance Comparison',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: campaigns.isEmpty
                  ? const Center(
                      child: Text(
                        'No campaigns available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(),
                      title: ChartTitle(text: 'Campaign Metrics Comparison'),
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <ChartSeries<_CampaignMetrics, String>>[
                        ColumnSeries<_CampaignMetrics, String>(
                          dataSource: _getCampaignMetricsData(campaigns),
                          xValueMapper: (_CampaignMetrics data, _) => data.campaignName,
                          yValueMapper: (_CampaignMetrics data, _) => data.impressions,
                          name: 'Impressions',
                          color: Colors.blue,
                        ),
                        ColumnSeries<_CampaignMetrics, String>(
                          dataSource: _getCampaignMetricsData(campaigns),
                          xValueMapper: (_CampaignMetrics data, _) => data.campaignName,
                          yValueMapper: (_CampaignMetrics data, _) => data.clicks,
                          name: 'Clicks',
                          color: Colors.green,
                        ),
                        ColumnSeries<_CampaignMetrics, String>(
                          dataSource: _getCampaignMetricsData(campaigns),
                          xValueMapper: (_CampaignMetrics data, _) => data.campaignName,
                          yValueMapper: (_CampaignMetrics data, _) => data.conversions,
                          name: 'Conversions',
                          color: Colors.orange,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
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
    return campaigns.take(10).map<_CampaignMetrics>((campaign) {
      return _CampaignMetrics(
        campaign.name.length > 10 
            ? '${campaign.name.substring(0, 10)}...' 
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