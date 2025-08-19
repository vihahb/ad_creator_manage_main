import 'package:flutter/material.dart';

class StepTiles extends StatelessWidget {
  const StepTiles({
    Key? key,
    required this.avatar,
    required this.title,
    required this.sutitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          avatar,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sutitle),
        isThreeLine: true,
      ),
    );
  }

  final IconData avatar;
  final String title;
  final String sutitle;
}
