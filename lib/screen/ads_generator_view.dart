import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share/share.dart';

import '../version/ads_generated.dart';
import '../version/ver_app.dart';
import 'home.dart';

class AdsGeneratorDetail extends StatefulWidget {
  const AdsGeneratorDetail({
    super.key,
    required this.isBack,
    required this.ad,
  });

  final AdsGenerated ad;
  final isBack;

  @override
  State<AdsGeneratorDetail> createState() => _AdsGeneratorDetailState();
}

class _AdsGeneratorDetailState extends State<AdsGeneratorDetail> {
  Box<AdsGenerated>? box;

  void shareAd(AdsGenerated item) {
    showLoad(true);
    final String title = item.toString();
    Share.share(title).then((value) {
      Future.delayed(const Duration(seconds: 2), () {
        showLoad(false);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isBack) {
      saveAdsGenerator();
    }
  }

  saveAdsGenerator() async {
    box = await Hive.openBox<AdsGenerated>(AppConst.db);
    box?.add(widget.ad);
  }

  var load = false;

  showLoad(show) {
    setState(() {
      load = show;
    });
  }

  void copyData(String title, String content, BuildContext context) {
    Clipboard.setData(ClipboardData(text: content)).then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$title has been copied!')));
    });
  }

  Widget _buildSection(BuildContext context, String title, String content,
      IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(12.0),
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          subtitle: SelectableText(content,
              style: const TextStyle(color: Colors.black87)),
          trailing: IconButton(
            icon: const Icon(FontAwesomeIcons.copy, color: Colors.grey),
            onPressed: () {
              copyData(title, content, context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildKeywordSection(String keywords) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Keywords',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple)),
          Wrap(
            spacing: 8.0,
            children: keywords.split(',').map((e) {
              return Chip(
                label: SelectableText(e.trim(),
                    style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.deepPurple.shade100,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        // New color for AppBar
        leading: (!widget.isBack)
            ? IconButton(
                icon: const Icon(Icons.home), // Changed icon for consistency
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const HomePage()));
                },
              )
            : IconButton(
                icon: const Icon(FontAwesomeIcons.angleLeft),
                // Changed to a more modern icon
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
        actions: [
          IconButton(
            onPressed: () {
              noticeFail(context, widget.ad);
            },
            icon: const Icon(
                FontAwesomeIcons.remove), // Updated icon for a fresh look
          ),
          IconButton(
            onPressed: () {
              shareAd(widget.ad);
            },
            icon: const Icon(
                FontAwesomeIcons.share), // Updated icon for a fresh look
          ),
        ],
        title: const Text("Ads Generator Details",
            style: TextStyle(color: Colors.white)),
        // Updated title
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(context, 'Title', widget.ad.title, Icons.title,
                    Colors.pinkAccent),
                _buildSection(context, 'Subtitle', widget.ad.subtitle,
                    Icons.abc, Colors.orangeAccent),
                _buildSection(context, 'Description', widget.ad.description,
                    Icons.description, Colors.lightGreen),
                _buildSection(context, 'Input campaign', widget.ad.adInput,
                    Icons.input, Colors.lightBlue),
                _buildKeywordSection(widget.ad.keyword)
              ],
            ),
          ),
          if (load)
            Container(
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
            ),
        ],
      ),
    );
  }

  void noticeFail(BuildContext context, AdsGenerated ad) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you want delete ads generator: ${ad.title}?'),
                const Text('This action can\'t undo!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete it!',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                deleteGenerator();
              },
            ),
          ],
        );
      },
    );
  }

  deleteGenerator() async {
   await widget.ad.delete();
    Navigator.of(context).pop();
  }
}
