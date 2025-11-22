import 'package:flutter/material.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tutorials = [
      'Budgeting Basics',
      'Saving Strategies',
      'Investing 101',
      'Debt Management',
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tutorials.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Learn Hub',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          );
        }

        final title = tutorials[index - 1];

        return Card(
          child: ListTile(
            title: Text(title),
            subtitle: const Text('Tap to open detailed lesson (coming soon)'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title details will be added soon.')),
              );
            },
          ),
        );
      },
    );
  }
}
