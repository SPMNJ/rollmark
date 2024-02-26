import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rollmark/dto/form_input_data.dart';

class FormEditCard extends StatelessWidget {
  const FormEditCard(
      {super.key,
      required this.formData,
      required this.onDelete,
      required this.onSave,
      required this.enableEditing,
      required this.onEdit});
  final FormInputData formData;
  final bool enableEditing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(FormInputData formData) onSave;

  @override
  Widget build(BuildContext context) {
    if (enableEditing) {
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
                      autofocus: true,
                      textCapitalization: TextCapitalization.none,
                      initialValue: formData.label,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-z]')),
                      ],
                      decoration: const InputDecoration(
                          labelText: 'Label',
                          contentPadding: EdgeInsets.all(0.0)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a label';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        onSave(formData.copyWith(label: value.toLowerCase()));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 1,
                    child: DropdownButtonFormField<FormInputType>(
                      value: formData.type,
                      decoration: const InputDecoration(
                          labelText: 'Type',
                          contentPadding: EdgeInsets.all(0.0)),
                      items: FormInputType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        onSave(formData.copyWith(type: value!));
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                initialValue: formData.prompt,
                decoration: const InputDecoration(
                  labelText: 'Prompt',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a prompt';
                  }
                  return null;
                },
                onChanged: (value) {
                  onSave(formData.copyWith(prompt: value));
                },
              ),
              if (formData.type == FormInputType.select ||
                  formData.type == FormInputType.radio ||
                  formData.type == FormInputType.checkbox)
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Options'),
                      if (formData.options == null || formData.options!.isEmpty)
                        Text('No ${formData.type.name} options')
                      else
                        for (var i = 0; i < formData.options!.length; i++)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                child: TextFormField(
                                  initialValue: formData.options![i],
                                  decoration: const InputDecoration(
                                    labelText: 'Option',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter an option';
                                    }
                                    for (var j = 0;
                                        j < formData.options!.length;
                                        j++) {
                                      if (j != i &&
                                          formData.options![j] == value) {
                                        return 'Option already exists';
                                      }
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    onSave(
                                      formData.copyWith(
                                        options: [
                                          for (var j = 0;
                                              j < formData.options!.length;
                                              j++)
                                            if (j == i)
                                              value
                                            else
                                              formData.options![j]
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  onSave(
                                    formData.copyWith(
                                      options: [
                                        for (var j = 0;
                                            j < formData.options!.length;
                                            j++)
                                          if (j == i)
                                            ...[]
                                          else
                                            formData.options![j]
                                      ],
                                    ),
                                  );
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                      const SizedBox(height: 5),
                      ElevatedButton(
                        onPressed: () {
                          onSave(
                            formData.copyWith(
                              options: [
                                ...formData.options!,
                                '',
                              ],
                            ),
                          );
                        },
                        child: const Text('Add Option'),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Checkbox(
                    value: formData.require,
                    onChanged: (value) {
                      onSave(formData.copyWith(require: value!));
                    },
                  ),
                  const Text('Required'),
                  const Spacer(),
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
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        onEdit();
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 30.0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Label: ${formData.label}'),
                Text('Prompt: ${formData.prompt}'),
                Text('Type: ${formData.type.name}'),
                if (formData.options != null && formData.options!.isNotEmpty)
                  Text('Options: ${formData.options!.join(', ')}'),
                Text('Required: ${formData.require}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
