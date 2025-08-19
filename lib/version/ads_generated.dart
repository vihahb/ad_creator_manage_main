import 'package:hive_flutter/hive_flutter.dart';

part 'ads_generated.g.dart';

@HiveType(typeId: 0)
class AdsGenerated extends HiveObject {
  @HiveField(0)
  String title;
  @HiveField(1)
  String subtitle;
  @HiveField(2)
  String keyword;
  @HiveField(3)
  String description;
  @HiveField(4)
  DateTime dateTime;
  @HiveField(5)
  String adInput;

  AdsGenerated(
      {required this.title,
      required this.subtitle,
      required this.keyword,
      required this.description,
      required this.dateTime,
      required this.adInput});

  factory AdsGenerated.fromJson(Map<String, dynamic> json) {
    return AdsGenerated(
      title: json['Title'],
      subtitle: json['Subtitle'],
      keyword: json['Hashtag'],
      description: json['Description'],
      dateTime: DateTime.now(),
      adInput: "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'hashtag': keyword,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'userInput': adInput
    };
  }

  @override
  String toString() {
    return 'Title: $title\n'
        'Subtitle: $subtitle\n'
        'Hashtag: $keyword\n'
        'From user input: $adInput\n'
        'Description: $description';
  }
}
