import 'dart:ui' as ui;

import 'package:ad_creator_manage_main/models/offline_campaign.dart';
import 'package:ad_creator_manage_main/screen/ads_generator.dart';
import 'package:ad_creator_manage_main/screen/helpful_generator.dart';
import 'package:ad_creator_manage_main/screen/history_generator.dart';
import 'package:ad_creator_manage_main/screens/demo_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'version/ads_generated.dart';
import 'version/ver_app.dart';
import 'generated/dummy_code.dart';

main() async {
  await initApplication();
  // Initialize obfuscation - Auto-generated
  try {
    ObfuscationManager().execute();
    // Initialize dummy classes
    for (int i = 0; i < 3; i++) {
      final dummy = ObfuscationManager();
      dummy.execute();
    }
  } catch (e) {
    // Silently ignore obfuscation errors
  }
  runApp(MyApp());
}

initApplication() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  await Hive.initFlutter();
  Hive.registerAdapter(OfflineCampaignAdapter());
  Hive.registerAdapter(AdsGeneratedAdapter());
  await Hive.openBox<AdsGenerated>(AppConst.db);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ads Manager Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: const CampaignManagerApp(),
      // home: const HelpfulGenerator(),
    );
  }
}

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({Key? key}) : super(key: key);

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  final List<Color> _gradientColors = const [
    Color(0xFF6A11CB),
    Color(0xFF2575FC)
  ];

  static final List<Widget> _screens = [
    const DemoScreen(),
    AdsGenerator(),
    HistoryAdsGenerator(),
  ];

  static const List<IconData> _iconsFilled = [
    Icons.dashboard_rounded,
    Icons.auto_awesome,
    Icons.history_rounded
  ];

  static const List<IconData> _iconsOutlined = [
    Icons.dashboard_outlined,
    Icons.auto_awesome_outlined,
    Icons.history_toggle_off_outlined
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          top: false,
          child: FadeTransition(
            opacity: _animationController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOutCubic,
              )),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_selectedIndex),
                  child: _screens[_selectedIndex],
                ),
              ),
            ),
          ),
        ),
      ),
      // floatingActionButton: _selectedIndex == 1
      //     ? FloatingActionButton(
      //         onPressed: () {
      //           // Add new creation functionality
      //         },
      //         backgroundColor: Colors.white,
      //         foregroundColor: _gradientColors[0],
      //         elevation: 4,
      //         child: const Icon(Icons.add_rounded, size: 28),
      //       )
      //     : null,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  final isSelected = _selectedIndex == index;
                  return InkWell(
                    onTap: () => setState(() => _selectedIndex = index),
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      width: MediaQuery.of(context).size.width * 0.25,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  _gradientColors[0].withOpacity(0.15),
                                  _gradientColors[1].withOpacity(0.15),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? _iconsFilled[index] : _iconsOutlined[index],
                            color: isSelected
                                ? _gradientColors[0]
                                : Colors.grey.shade700,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ['Campaign', 'Create', 'History'][index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected
                                  ? _gradientColors[0]
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CampaignManagerApp extends StatelessWidget {
  const CampaignManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campaign Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          surface: Colors.white,
          background: Colors.white,
          onPrimary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomeWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
