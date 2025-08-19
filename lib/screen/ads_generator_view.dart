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
  var load = false;

  // Theme colors
  final Color primaryColor = const Color(0xFF6200EE);
  final Color secondaryColor = const Color(0xFF03DAC6);
  final Color backgroundColor = const Color(0xFFF5F5F7);
  final Color cardColor = Colors.white;
  final Color textPrimaryColor = const Color(0xFF1D1D1F);
  final Color textSecondaryColor = const Color(0xFF86868B);

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

  showLoad(show) {
    setState(() {
      load = show;
    });
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

  void copyData(String title, String content, BuildContext context) {
    Clipboard.setData(ClipboardData(text: content)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title has been copied!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  Widget _buildSection(BuildContext context, String title, String content,
      IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.copy, size: 16),
                  color: textSecondaryColor,
                  onPressed: () => copyData(title, content, context),
                  tooltip: "Copy to clipboard",
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              content,
              style: TextStyle(
                fontSize: 15,
                color: textPrimaryColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordSection(String keywords) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.tags, color: primaryColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Keywords',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: keywords.split(',').map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SelectableText(
                    e.trim(),
                    style: TextStyle(
                      fontSize: 13,
                      color: primaryColor,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        leading: (!widget.isBack)
            ? IconButton(
          icon: const Icon(FontAwesomeIcons.house, size: 20),
          color: Colors.white,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (context) => const HomePage()),
            );
          },
        )
            : IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft, size: 20),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () => noticeFail(context, widget.ad),
            icon: const Icon(FontAwesomeIcons.trash, size: 20),
            color: Colors.white,
            tooltip: "Delete ad",
          ),
          IconButton(
            onPressed: () => shareAd(widget.ad),
            icon: const Icon(FontAwesomeIcons.shareNodes, size: 20),
            color: Colors.white,
            tooltip: "Share ad",
          ),
        ],
        title: const Text(
          "Ad Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ad info card with campaign title
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ad Campaign',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.ad.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.clock,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Created ${DateTime.now().difference(DateTime.now().subtract(const Duration(days: 1))).inDays} day ago',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                _buildSection(
                    context,
                    'Title',
                    widget.ad.title,
                    FontAwesomeIcons.heading,
                    const Color(0xFFE91E63)
                ),
                _buildSection(
                    context,
                    'Subtitle',
                    widget.ad.subtitle,
                    FontAwesomeIcons.textHeight,
                    const Color(0xFFFF9800)
                ),
                _buildSection(
                    context,
                    'Description',
                    widget.ad.description,
                    FontAwesomeIcons.alignLeft,
                    const Color(0xFF4CAF50)
                ),
                _buildSection(
                    context,
                    'Input campaign',
                    widget.ad.adInput,
                    FontAwesomeIcons.penToSquare,
                    const Color(0xFF2196F3)
                ),
                _buildKeywordSection(widget.ad.keyword)
              ],
            ),
          ),
          if (load)
            Container(
              color: Colors.black.withOpacity(0.7),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          strokeWidth: 4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Sharing Ad...',
                        style: TextStyle(
                          color: textPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                FontAwesomeIcons.triangleExclamation,
                color: Colors.red[700],
                size: 20,
              ),
              const SizedBox(width: 10),
              const Text(
                'Delete Ad',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Do you want to delete ad: "${ad.title}"?',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 8),
                Text(
                  'This action cannot be undone!',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(
                FontAwesomeIcons.trash,
                size: 16,
              ),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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