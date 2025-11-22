import 'package:flutter/material.dart';
import 'lesson_model.dart';
import 'lessons_data.dart';
import 'lesson_panel_list.dart';
import 'lesson_detail.dart';
import 'learn_styles.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({Key? key}) : super(key: key);

  void _openLesson(BuildContext context, Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LessonDetail(lesson: lesson)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LearnStyles.pageBackground,
      body: SingleChildScrollView(
        padding: LearnStyles.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Learn Hub',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            LessonPanelList(
              lessons: lessons,
              onOpenLesson: (l) => _openLesson(context, l),
            ),
          ],
        ),
      ),
    );
  }
}
