import 'package:flutter/material.dart';
import 'lesson_model.dart';

class LessonPanelItem extends StatelessWidget {
  final Lesson lesson;

  const LessonPanelItem({Key? key, required this.lesson}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: Text(
          lesson.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(lesson.subtitle),
      ),
    );
  }
}
