// lib/screens/learn/lesson_model.dart
class Lesson {
  final String id;
  final String title;
  final String subtitle;
  final String overview;
  final List<String> keyPoints;
  final List<String> steps;
  final String furtherReading;

  Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.overview,
    required this.keyPoints,
    required this.steps,
    required this.furtherReading,
  });
}
