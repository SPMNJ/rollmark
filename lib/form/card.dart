import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rollmark/constants.dart';
import 'package:rollmark/dto/form_input_data.dart';
import 'package:rollmark/form/page.dart';

class FormEditCard extends StatelessWidget {
  final TextEditingController labelController;
  final TextEditingController promptController;
  final FormInputType dropdownValue;
  final bool checkboxValue;
  final List<TextEditingController> optionsController;
  final Function addOption;
  final Function(int index) removeOption;
  final Function(bool checkbox) onCheckbox;
  final Function(FormInputType) onDropdown;
  final Function onReset;
  final Function onDelete;

  const FormEditCard(
      {super.key,
      required this.labelController,
      required this.promptController,
      required this.dropdownValue,
      required this.checkboxValue,
      required this.optionsController,
      required this.addOption,
      required this.removeOption,
      required this.onDelete,
      required this.onCheckbox,
      required this.onDropdown,
      required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    textCapitalization: TextCapitalization.none,
                    controller: labelController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-z]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a label';
                      }
                      int count = 0;
                      for (var element in FormDocRef.of(context)!.inputs) {
                        if (key != element.key &&
                            element.labelController.text == value) {
                          count++;
                        }
                        if (count > 1) {
                          return 'Label already exists';
                        }
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Label (lowercase)',
                        contentPadding: EdgeInsets.all(0.0)),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  flex: 1,
                  child: DropdownButtonFormField<FormInputType>(
                    value: dropdownValue,
                    onChanged: (FormInputType? newValue) {
                      onDropdown(newValue ?? FormInputType.text);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a type';
                      }
                      if (value == FormInputType.select ||
                          value == FormInputType.checkbox ||
                          value == FormInputType.radio) {
                        if (optionsController.isEmpty) {
                          return 'Please add option';
                        }
                      }
                      return null;
                    },
                    items: FormInputType.values
                        .map<DropdownMenuItem<FormInputType>>(
                            (FormInputType value) {
                      return DropdownMenuItem<FormInputType>(
                        value: value,
                        child:
                            Text(value.toString().split('.').last.capitalize()),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: promptController,
              decoration: const InputDecoration(
                labelText: 'Prompt',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a prompt';
                }
                return null;
              },
            ),
            if (dropdownValue == FormInputType.select ||
                dropdownValue == FormInputType.checkbox ||
                dropdownValue == FormInputType.radio)
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Options'),
                    if (optionsController.isEmpty)
                      const Text('No options')
                    else
                      for (var i = 0; i < optionsController.length; i++)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              child: TextFormField(
                                controller: optionsController[i],
                                decoration: const InputDecoration(
                                  labelText: 'Option',
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Please enter an option'
                                        : null,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                removeOption(i);
                              },
                              child: const Text('Delete'),
                            )
                          ],
                        ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => addOption(),
                      child: const Text('Add Option'),
                    )
                  ],
                ),
              ),
            Row(
              children: [
                Checkbox(
                  value: checkboxValue,
                  onChanged: (bool? value) {
                    onCheckbox(value!);
                  },
                ),
                const Text('Required'),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          onReset();
                        },
                        child: const Text('Reset')),
                    const SizedBox(width: 10),
                    if (FormDocRef.of(context)?.inputs != null &&
                        FormDocRef.of(context)!.inputs.length > 1)
                      ElevatedButton(
                        onPressed: () {
                          onDelete();
                        },
                        child: const Text('Delete'),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
