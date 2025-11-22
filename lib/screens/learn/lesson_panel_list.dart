import 'package:flutter/material.dart';
import 'lesson_model.dart';
import 'lesson_panel_item.dart';

class LessonPanelList extends StatelessWidget {
  final List<Lesson> lessons;
  final void Function(Lesson) onOpenLesson;

  const LessonPanelList({
    Key? key,
    required this.lessons,
    required this.onOpenLesson,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: ExpansionPanelList.radio(
        elevation: 0,
        children: List.generate(lessons.length, (index) {
          final lesson = lessons[index];
          return ExpansionPanelRadio(
            value: lesson.id,
            headerBuilder: (ctx, isOpen) => LessonPanelItem(lesson: lesson),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.overview),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => onOpenLesson(lesson),
                      child: const Text('Open Lesson'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
