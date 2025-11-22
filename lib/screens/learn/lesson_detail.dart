import 'package:flutter/material.dart';
import 'lesson_model.dart';

class LessonDetail extends StatelessWidget {
  final Lesson lesson;
  const LessonDetail({Key? key, required this.lesson}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lesson.overview, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            const Text(
              'Key takeaways',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...lesson.keyPoints.map(
              (k) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text('• $k'),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Steps', style: TextStyle(fontWeight: FontWeight.bold)),
            ...lesson.steps.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text('${e.key + 1}. ${e.value}'),
              ),
            ),
            const SizedBox(height: 20),
            Text('Further reading: ${lesson.furtherReading}'),
          ],
        ),
      ),
    );
  }
}
