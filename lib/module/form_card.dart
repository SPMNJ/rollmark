import 'package:flutter/material.dart';
import 'package:rollmark/dto/form_data.dart';

class FormCard extends StatelessWidget {
  const FormCard({super.key, required this.formData});

  final FormData formData;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formData.title,
            ),
            Text(
              formData.description,
            ),
          ],
        ),
      ),
    );
  }
}
