// Reference screenshot (for layout & styling inspiration):
// /mnt/data/a2de57d0-3adf-4447-9f1e-a8cb90fa187d.png

import 'package:flutter/material.dart';

/// Learn Hub - Dropdown / Accordion style implementation
/// File: learn_hub_accordion.dart
/// Copy this file into your Flutter project (e.g. lib/screens/learn_hub_accordion.dart)

class LearnHubAccordion extends StatefulWidget {
  const LearnHubAccordion({Key? key}) : super(key: key);

  @override
  State<LearnHubAccordion> createState() => _LearnHubAccordionState();
}

class Lesson {
  String title;
  String subtitle;
  String content;
  Lesson({required this.title, required this.subtitle, required this.content});
}

class _LearnHubAccordionState extends State<LearnHubAccordion> {
  final List<Lesson> lessons = [
    Lesson(
      title: 'Budgeting Basics',
      subtitle: 'Tap to open detailed lesson (coming soon)',
      content:
          'Budgeting basics content goes here. Use this space to show lesson summary, steps and a button to start lesson.',
    ),
    Lesson(
      title: 'Saving Strategies',
      subtitle: 'Tap to open detailed lesson (coming soon)',
      content: 'Saving strategies content placeholder.',
    ),
    Lesson(
      title: 'Investing 101',
      subtitle: 'Tap to open detailed lesson (coming soon)',
      content: 'Investing 101 content placeholder.',
    ),
    Lesson(
      title: 'Debt Management',
      subtitle: 'Tap to open detailed lesson (coming soon)',
      content: 'Debt management content placeholder.',
    ),
  ];

  final List<bool> _open = [];

  @override
  void initState() {
    super.initState();
    _open.addAll(List<bool>.filled(4, false));
  }

  @override
  Widget build(BuildContext context) {
    // Use a responsive scaffold similar to your app's layout. Here is a standalone page.
    return Scaffold(
      backgroundColor: const Color(
        0xFFF6F7FB,
      ), // soft background like screenshot
      appBar: AppBar(
        title: const Text(
          'Learn Hub',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Row(
        children: [
          // Left sidebar placeholder (mimics your app layout). Replace with your real drawer.
          Container(
            width: 260,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                // Logo area
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: const [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFFEEE7F7),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'SHEconomy',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // menu icons (simple)
                Expanded(
                  child: ListView(
                    children: const [
                      ListTile(
                        leading: Icon(Icons.account_balance_wallet),
                        title: Text('Wallet'),
                      ),
                      ListTile(
                        leading: Icon(Icons.build),
                        title: Text('Tools'),
                      ),
                      ListTile(leading: Icon(Icons.book), title: Text('Learn')),
                      ListTile(
                        leading: Icon(Icons.insights),
                        title: Text('Insights'),
                      ),
                      ListTile(
                        leading: Icon(Icons.show_chart),
                        title: Text('Stocks'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  const Text(
                    'Learn Hub',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 18),

                  // Accordion using ExpansionPanelList.radio for single-open behavior
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ExpansionPanelList.radio(
                      expandedHeaderPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      animationDuration: const Duration(milliseconds: 300),
                      children: List.generate(lessons.length, (index) {
                        final lesson = lessons[index];
                        return ExpansionPanelRadio(
                          value: index,
                          canTapOnHeader: true,
                          headerBuilder: (context, isExpanded) {
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              title: Text(
                                lesson.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(lesson.subtitle),
                              trailing: const Icon(Icons.keyboard_arrow_down),
                            );
                          },
                          body: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lesson.content),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Navigate to full lesson page or open modal
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Open ${lesson.title}',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Open Lesson'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Alternative: Compact card list with dropdown icon (optional)
                  const Text(
                    'Or use compact style',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: List.generate(lessons.length, (i) {
                      return _CompactLessonCard(lesson: lessons[i]);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactLessonCard extends StatefulWidget {
  final Lesson lesson;
  const _CompactLessonCard({Key? key, required this.lesson}) : super(key: key);

  @override
  State<_CompactLessonCard> createState() => _CompactLessonCardState();
}

class _CompactLessonCardState extends State<_CompactLessonCard>
    with SingleTickerProviderStateMixin {
  bool open = false;
  late final AnimationController _ctr;

  @override
  void initState() {
    super.initState();
    _ctr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _ctr.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() => open = !open);
    if (open)
      _ctr.forward();
    else
      _ctr.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FA),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: toggle,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lesson.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.lesson.subtitle,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_ctr),
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
          ),
          SizeTransition(
            sizeFactor: CurvedAnimation(parent: _ctr, curve: Curves.easeInOut),
            axisAlignment: -1.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.lesson.content),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Open Lesson'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// To use this widget in your main app, simply navigate to it:
// Navigator.push(context, MaterialPageRoute(builder: (_) => const LearnHubAccordion()));
