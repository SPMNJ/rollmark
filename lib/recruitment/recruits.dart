import 'package:flutter/material.dart';
import 'package:rollmark/module/pnm.dart';

class RecruitPage extends StatelessWidget {
  const RecruitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        addAutomaticKeepAlives: true,
        cacheExtent: 1000,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 20,
        itemBuilder: (context, index) => const PNMModule(),
      ),
    );
  }
}
