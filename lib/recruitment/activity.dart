import 'package:flutter/material.dart';
import 'package:rollmark/module/activity_note.dart';

class RecruitLogPage extends StatelessWidget {
  const RecruitLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) => const ActivityNote(),
      ),
    );
  }
}
