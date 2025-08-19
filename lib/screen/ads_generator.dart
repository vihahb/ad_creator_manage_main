import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';

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
  String apiKey =
      "c2stcHJvai13WnNTS3h1bnFsYnpoVFFfY2M2bUgzcXJuVDAxQU9rZEFyRE8zcDhBY0pDd1U4dS0xQTBDOGJPMWIwZG9uZUFRZ2tvZXpncVBuV1QzQmxia0ZKYmdjdjhlME1RVGtPLWIxTGxwc2xrTVdZTUxhUGlQdWJPRTlhM2p1Rkd4ZzJhWlptWTByTHpfYkpMVC14RU41aUFmdEhKZkp3RUE=";

  Future<void> startGenerator() async {
    showLoad(true);
    final String description = campaignDes.text;
    const String apiUrl = 'https://api.openai.com/v1/chat/completions';

    final openai = OpenAIClient(apiKey: utf8.decode(base64Decode(apiKey)));

    try {
      final chatResponse = await openai.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.model(
            ChatCompletionModels.gpt5,
          ),
          messages: [
            ChatCompletionMessage.system(
              content: "You are an advertising content analyst. The user will give you a description of their campaign. Your task is to return to them information about: title content, subtitle content, hastag, keywords. Note, only return data to json in the format:\nTitle: <Title content created by you>\nSubtitle: <Subtitle content created by you>\nHashtag: <6-8 Hashtag content created by you, separated by commas>\nKeyword: <Keyword content created by you, separated by commas>\nDescription of: <Description content created by you, limited to 80 words>",
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(
               description,
              ),
            ),
          ],
          responseFormat: ResponseFormat.jsonSchema(
            jsonSchema: JsonSchemaObject(
              name: 'AdContent',
              description: 'Structured ad content for AdsGenerated',
              strict: true,
              schema: {
                'type': 'object',
                'properties': {
                  'Title': {'type': 'string'},
                  'Subtitle': {'type': 'string'},
                  'Hashtag': {
                    'type': 'string',
                    'description': '6-8 hashtags separated by commas'
                  },
                  'Description': {'type': 'string'},
                },
                'required': ['Title', 'Subtitle', 'Hashtag', 'Description'],
                'additionalProperties': false,
              },
            ),
          ),
        )
      );

      print('Response: $chatResponse');

      if (chatResponse.choices.isNotEmpty) {
        final message = chatResponse.choices.first.message.content;
        if (message==null || message.isEmpty) {
          showLoad(false);
          noticeFail(context, 'Empty response');
        } else {
          try {
            final ad = AdsGenerated.fromJson(jsonDecode(message));
            ad.adInput = description;
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdsGeneratorDetail(
                  ad: ad,
                  isBack: false,
                ),
              ),
            );
            showLoad(false);
          } catch (e) {
            showLoad(false);
            noticeFail(context, message);
          }
        }
      } else {
        showLoad(false);
        noticeFail(context, 'No choices returned');
      }
    } catch (e) {
      showLoad(false);
      noticeFail(context, 'API Error: $e');
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
        elevation: 0,
        backgroundColor: const Color(0xFF6200EE),
        title: const Text('Ad Creator',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6200EE), Color(0xFF9C27B0)],
            stops: [0.0, 1.0],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6200EE).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.rocket_launch_rounded,
                              color: Color(0xFF6200EE),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create Compelling Ads',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E1E1E),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'AI-powered content for your campaigns',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Input area
                      Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'Describe your campaign',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                            if (load)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    const CircularProgressIndicator(
                                      color: Color(0xFF6200EE),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Creating your perfect ad content...',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'This may take a moment',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              TextFormField(
                                controller: campaignDes,
                                decoration: InputDecoration(
                                  hintText:
                                      'E.g., New fitness app for busy professionals...',
                                  hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14),
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                        color: const Color(0xFF6200EE)
                                            .withOpacity(0.3),
                                        width: 1.5),
                                  ),
                                ),
                                style: const TextStyle(
                                    fontSize: 16, color: Color(0xFF333333)),
                                minLines: 4,
                                maxLines: 6,
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Generate button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: load
                              ? null
                              : () {
                                  if (campaignDes.text.isNotEmpty) {
                                    startGenerator();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Please describe your campaign first'),
                                        backgroundColor: Colors.red.shade700,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6200EE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Find Ad Content',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Process steps
                      const Text(
                        'How it works',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),

                      ...List.generate(
                        4,
                        (index) => Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF6200EE).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Color(0xFF6200EE),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getStepTitle(index),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      getStepSubtitle(index),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getStepTitle(int index) {
    switch (index) {
      case 0:
        return "Describe Your Campaign";
      case 1:
        return "Get Ad Content analysis";
      case 2:
        return "Review Generated Results";
      case 3:
        return "Use in Your Marketing";
      default:
        return "";
    }
  }

  String getStepSubtitle(int index) {
    switch (index) {
      case 0:
        return "Provide details about your product, target audience, and goals.";
      case 1:
        return "Our AI analyzes your input to generate titles, hashtags, and keywords.";
      case 2:
        return "Review the AI-generated content and make any adjustments as needed.";
      case 3:
        return "Apply the generated content to your marketing campaigns for better engagement.";
      default:
        return "";
    }
  }
}
