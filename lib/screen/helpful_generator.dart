import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'home.dart';
import 'step_tiles.dart';

class HelpfulGenerator extends StatefulWidget {
  const HelpfulGenerator({super.key});

  @override
  State<HelpfulGenerator> createState() => _HelpfulGeneratorState();
}

class _HelpfulGeneratorState extends State<HelpfulGenerator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text('Ads Manager Generator', style: TextStyle(color: Theme.of(context).colorScheme.primary),),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  StepTiles(
                    avatar: Icons.content_paste_search_outlined,
                    title: 'Flexible',
                    sutitle: 'Easy to use and get flexible ads results',
                  ),
                  StepTiles(
                    avatar: Icons.ads_click,
                    title: 'Ads details',
                    sutitle:
                        'Focus & get information that are easy to use in your campaigns',
                  ),
                  StepTiles(
                    avatar: Icons.update,
                    title: 'Always up to date',
                    sutitle: 'Continuously updated data eliminates limitations',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  icon: const Icon(FontAwesomeIcons.refresh),
                  label: Text(
                    'Generator Ads Now'.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
