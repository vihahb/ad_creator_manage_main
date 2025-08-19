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
    return listData.isEmpty
        ? const Center(child: Text('Data empty!\nCreate on Ads generator.'))
        : ListView.builder(
            itemCount: listData.length,
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => AdsGeneratorDetail(
                                  ad: listData[index],
                                  isBack: true,
                                )));
                  },
                  child: campaignItem(listData[index]));
            },
          );
  }

  var load = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('History Ads Generator'),
      ),
      body: Stack(
        children: [
          historyGenerator(),
          (load)
              ? Container(
                  color: Colors.black54,
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 4,
                        child: const LinearProgressIndicator(),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Text(
                        'Please wait...',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  historyGenerator(){
    return  ValueListenableBuilder(
      valueListenable: Hive.box<AdsGenerated>(AppConst.db).listenable(),
      builder: (context, Box<AdsGenerated> data, _) {
        return buildCampaignList(data.values.toList());
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

  campaignItem(AdsGenerated item) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.fileText, color: Colors.blue),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Icon(CupertinoIcons.calendar_today,
                        color: Colors.indigo),
                    const SizedBox(width: 5),
                    Text(
                      '${DateFormat.Hm().format(item.dateTime)} ${DateFormat.MMMM().format(item.dateTime)} ',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.alignCenter,
                        color: Colors.orange),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item.subtitle,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            )),
            IconButton(
                onPressed: () {
                  shareAd(item);
                },
                icon: Icon(
                  FontAwesomeIcons.share,
                  color: Theme.of(context).colorScheme.primary,
                ))
          ],
        ),
      ),
    );
  }
}
