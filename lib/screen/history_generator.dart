import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

import '../version/ads_generated.dart';
import '../version/ver_app.dart';
import 'ads_generator_view.dart';

class HistoryAdsGenerator extends StatefulWidget {
  const HistoryAdsGenerator({super.key});

  @override
  State<HistoryAdsGenerator> createState() => _HistoryAdsGeneratorState();
}

class _HistoryAdsGeneratorState extends State<HistoryAdsGenerator> {
  late Box<AdsGenerated> dbFuture;

  @override
  void initState() {
    super.initState();
  }

  List<AdsGenerated> sortCampaigns(Box<AdsGenerated> db) {
    var campaigns = db.values.toList();
    campaigns.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return campaigns;
  }

  Widget buildCampaignList(List<AdsGenerated> listData) {
    if (listData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.folderOpen,
              size: 70,
              color: Colors.grey.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            const Text(
              'No campaign history',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create new ads in the generator',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: listData.length,
      itemBuilder: (context, index) {
        return AnimatedOpacity(
          duration: Duration(milliseconds: 300 + (index * 50)),
          opacity: 1.0,
          curve: Curves.easeInOut,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdsGeneratorDetail(
                    ad: listData[index],
                    isBack: true,
                  ),
                ),
              );
            },
            child: campaignItem(listData[index]),
          ),
        );
      },
    );
  }

  var load = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {
              // Filter functionality could be added here
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            historyGenerator(),
            if (load)
              Container(
                color: Colors.black45,
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8),
                          CircularProgressIndicator(color: theme.colorScheme.primary),
                          const SizedBox(height: 24),
                          Text(
                            'Please wait...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget historyGenerator() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<AdsGenerated>(AppConst.db).listenable(),
      builder: (context, Box<AdsGenerated> data, _) {
        final campaigns = sortCampaigns(data);
        return buildCampaignList(campaigns);
      },
    );
  }


  void shareAd(AdsGenerated item) {
    showLoad(true);
    final String title = item.toString();
    Share.share(title).then((value) {
      Future.delayed(const Duration(seconds: 2), () {
        showLoad(false);
      });
    });
  }

  showLoad(show) {
    setState(() {
      load = show;
    });
  }

  Widget campaignItem(AdsGenerated item) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
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
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      FontAwesomeIcons.bullhorn,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => shareAd(item),
                    icon: const Icon(Icons.share_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${DateFormat('MMM d').format(item.dateTime)} at ${DateFormat.Hm().format(item.dateTime)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
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
}


