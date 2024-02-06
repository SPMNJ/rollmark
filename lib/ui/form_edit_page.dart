import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rollmark/dto/form_data.dart';
import 'package:rollmark/dto/form_input_data.dart';
import 'package:rollmark/module/form_edit_card.dart';

class FormEditPage extends StatefulWidget {
  final String formID;

  const FormEditPage({super.key, required this.formID});

  @override
  State<FormEditPage> createState() => _FormEditPageState();
}

class _FormEditPageState extends State<FormEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FormData formData = FormData.empty();
  FormData savedData = FormData.empty();
  int showIndex = 0;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('forms')
        .doc(widget.formID)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          savedData = FormData.fromDocument(doc);
          formData = FormData.fromDocument(doc);
          if (kDebugMode) {
            print(formData);
          }
          if (formData.inputs.isEmpty) {
            formData = formData.copyWith(inputs: [FormInputData.empty()]);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('There was an error loading the form. Please try again.'),
          ),
        );
        context.go('/forms');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Form')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                initialValue: formData.title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  formData = formData.copyWith(title: value!);
                },
              ),
              TextFormField(
                initialValue: formData.description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                onSaved: (value) {
                  formData = formData.copyWith(description: value!);
                },
              ),
              Expanded(
                child: ReorderableListView(
                  proxyDecorator: proxyDecorator,
                  padding: const EdgeInsets.all(8.0),
                  primary: true,
                  scrollDirection: Axis.vertical,
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      oldIndex = oldIndex.clamp(0, formData.inputs.length - 1);
                      newIndex = newIndex.clamp(0, formData.inputs.length - 1);
                      formData = formData.copyWith(
                        inputs: [
                          for (var i = 0; i < formData.inputs.length; i++)
                            if (i == oldIndex)
                              formData.inputs[newIndex]
                            else if (i == newIndex)
                              formData.inputs[oldIndex]
                            else
                              formData.inputs[i]
                        ],
                      );
                      showIndex = newIndex.clamp(0, formData.inputs.length - 1);
                    });
                  },
                  footer: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          formData = formData.copyWith(
                            inputs: [
                              ...formData.inputs,
                              FormInputData.empty(),
                            ],
                          );
                          showIndex = formData.inputs.length - 1;
                        });
                      }
                    },
                    child: const Text('Add Input'),
                  ),
                  children: [
                    for (var i = 0; i < formData.inputs.length; i++)
                      FormEditCard(
                        key: ValueKey(i),
                        formData: formData.inputs[i],
                        enableEditing: i == showIndex,
                        onDelete: () {
                          setState(
                            () {
                              formData = formData.copyWith(
                                inputs: [
                                  for (var j = 0;
                                      j < formData.inputs.length;
                                      j++)
                                    if (j != i) formData.inputs[j]
                                ],
                              );
                              showIndex = max(0, i - 1);
                              if (formData.inputs.isEmpty) {
                                showIndex = 0;
                                formData = formData.copyWith(
                                  inputs: [FormInputData.empty()],
                                );
                              }
                            },
                          );
                        },
                        onEdit: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() => showIndex = i);
                          }
                        },
                        onSave: (formInputData) {
                          setState(
                            () {
                              formData = formData.copyWith(
                                inputs: [
                                  for (var j = 0;
                                      j < formData.inputs.length;
                                      j++)
                                    if (j == i)
                                      formInputData
                                    else
                                      formData.inputs[j]
                                ],
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _saveForm,
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: _resetForm,
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double scale = lerpDouble(1, 1.02, animValue)!;
        return Transform.scale(
            scale: scale,
            // Create a Card based on the color and the content of the dragged one
            // and set its elevation to the animated value.
            child: child);
      },
      child: child,
    );
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (formData.inputs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one input'),
        ),
      );
      return;
    }
    if (hasDuplicateInputLabel()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter unique labels for each input'),
        ),
      );
      return;
    }

    if (kDebugMode) {
      print("Saving form: $formData");
    }

    FirebaseFirestore.instance
        .collection('forms')
        .doc(widget.formID)
        .update(formData.toDocument())
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form saved'),
        ),
      );
      savedData = formData;
      context.go('/forms');
    });
  }

  bool hasDuplicateInputLabel() {
    Set<String> labels = <String>{};
    for (FormInputData input in formData.inputs) {
      if (labels.contains(input.label)) {
        return true;
      }
      labels.add(input.label);
    }
    return false;
  }

  void _resetForm() {
    setState(() {
      formData = savedData.copyWith();
    });
    _formKey.currentState!.reset();
  }
}
