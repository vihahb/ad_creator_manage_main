import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../version/ads_generated.dart';
import 'ads_generator_view.dart';
import 'step_line.dart';

class AdsGenerator extends StatefulWidget {
  @override
  _AdsGeneratorState createState() => _AdsGeneratorState();
}

class _AdsGeneratorState extends State<AdsGenerator> {
  final TextEditingController campaignDes = TextEditingController();
  String title = "";
  String hashtags = "";
  String subtitle = "";

  Future<void> startGenerator() async {
    showLoad(true);
    final String description = campaignDes.text;
    const String apiUrl = 'https://api.openai.com/v1/chat/completions';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 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',
      },
      body: json.encode({
        'model': 'gpt-4',
        'max_tokens': 350,
        'temperature': 1.5,
        'top_p': .7,
        "messages": [
          {
            "role": "system",
            "content":
                "You are an advertising content analyst. The user will give you a description of their campaign. Your task is to return to them information about: title content, subtitle content, hastag, keywords. Note, only return data to json in the format:\nTitle: <Title content created by you>\nSubtitle: <Subtitle content created by you>\nHashtag: <6-8 Hashtag content created by you, separated by commas>\nKeyword: <Keyword content created by you, separated by commas>\nDescription of: <Description content created by you, limited to 80 words>"
          },
          {"role": "user", "content": description}
        ]
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        var jsonResponse = json.decode(response.body);
        var data = jsonResponse['choices'][0]['message']['content'];
        try {
          var ad = AdsGenerated.fromJson(jsonDecode(data));
          if (ad != null) {
            ad.adInput = description;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AdsGeneratorDetail(
                          ad: ad,
                          isBack: false,
                        )));
          } else {
            noticeFail(context, data);
          }
        } catch (e) {
          noticeFail(context, data);
        }
      });
      showLoad(false);
    } else {
      showLoad(false);
      // Xử lý lỗi
    }
  }

  void noticeFail(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sorry'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                    'We don\'t understand what you want.\nPlease try again!'),
                Text('$message'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got It'),
              onPressed: () {
                campaignDes.clear();
                showLoad(false);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showLoad(show) {
    setState(() {
      load = show;
    });
  }

  var load = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple, // New color for the AppBar
        title: const Text('Ads Generator Wizard',
            style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: Colors.grey.shade200, // Background color for the body
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Campaign Details:',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              const SizedBox(height: 20),
              if (load)
                Card(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(
                            'Ads Generator is working.\nPlease wait a moments...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500)),
                        const SizedBox(
                          height: 16,
                        ),
                        const LinearProgressIndicator(),
                      ],
                    ),
                  ),
                )
              else
                TextFormField(
                  controller: campaignDes,
                  decoration: InputDecoration(
                    labelText: 'Campaign Description',
                    prefixIcon:
                        const Icon(Icons.description, color: Colors.deepPurple),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  style: const TextStyle(fontSize: 18),
                  minLines: 3,
                  maxLines: 5,
                ),
              const SizedBox(height: 20),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  // New button color
                  onPressed: (load)
                      ? null
                      : () {
                          if (campaignDes.text.isNotEmpty) {
                            startGenerator();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please enter field campaign description.')));
                          }
                        },
                  icon: const Icon(CupertinoIcons.arrow_2_circlepath),
                  label: Text(
                    'Generate Ads Content'.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "This tool will help you create content for your advertising campaign",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              ...List.generate(
                4,
                (index) => CampaignStep(
                  title: 'Step ${index + 1}: ${getStepTitle(index)}',
                  icon: Icons.check_circle_outline,
                  description: 'Objective:\n${getStepSubtitle(index)}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getStepTitle(index) {
    switch (index) {
      case 0:
        return "Identify the Core Message";
      case 1:
        return "Brainstorm Key Words and Phrases";
      case 2:
        return "Create the Title";
      case 3:
        return "Compose the Subtitle";
    }
  }

  getStepSubtitle(index) {
    switch (index) {
      case 0:
        return "Determine the main message or value proposition of your campaign.";
      case 1:
        return "List words and phrases that resonate with your campaign's core message.";
      case 2:
        return "Develop a concise and impactful title using your brainstormed words.";
      case 3:
        return "Expand on the title with a subtitle that provides more detail.";
    }
  }
}
