import 'package:flutter/material.dart';
import 'package:rollmark/constants.dart';
import 'package:rollmark/dto/form_input_data.dart';

class FormEditCardView extends StatelessWidget {
  final String label;
  final String prompt;
  final FormInputType type;
  final List<String> options;
  final bool require;

  const FormEditCardView(
      {super.key,
      required this.label,
      required this.prompt,
      required this.type,
      required this.options,
      required this.require});

  @override
  Widget build(BuildContext context) {
    String option = "";
    if (options.isNotEmpty) {
      option = "Options: ${options.join(", ")}";
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
        child: ListTile(
          title: Text("${label.capitalize()} "),
          leading: require
              ? const Text('*', style: TextStyle(color: Colors.red))
              : null,
          subtitle: Text("$prompt\n$option"),
          isThreeLine: options.isNotEmpty,
          trailing: Text(
            "Type: ${type.toString().split(".").last.capitalize()}",
          ),
        ),
      ),
    );
  }
}
