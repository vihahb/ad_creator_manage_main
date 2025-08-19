import 'package:ad_creator_manage_main/screen/helpful_generator.dart';
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


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Hive
//   await Hive.initFlutter();
//
//   runApp(const CampaignManagerApp());
// }
//
class CampaignManagerApp extends StatelessWidget {
  const CampaignManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campaign Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DemoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
