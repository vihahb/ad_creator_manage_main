import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ads_generator.dart';
import 'history_generator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  int _pageInt = 0;

  void selectedIndex(int index) {
    setState(() {
      _pageInt = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: selectedIndex,
        currentIndex: _pageInt,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.arrow_2_circlepath),
            label: 'Ads Generator',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_number_rtl),
            label: 'History Generator',
          ),
        ],
      ),
      body: IndexedStack(
        children: [
          AdsGenerator(),
          HistoryAdsGenerator(),
        ],
        index: _pageInt,
      ),
    );
  }
}
