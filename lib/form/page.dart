import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rollmark/dto/form_data.dart';
import 'package:rollmark/dto/form_input_data.dart';
import 'package:rollmark/form/middlecard.dart';
import 'package:rollmark/provider.dart';

class FormEditPage extends StatefulWidget {
  final FormDoc existingDoc;

  FormEditPage({super.key, existingDoc})
      : existingDoc = existingDoc ?? FormDoc.empty();

  @override
  State<FormEditPage> createState() => _FormEditPageState();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
}

class _FormEditPageState extends State<FormEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<GlobalKey<FormMiddleCardState>> _keys = List.empty(growable: true);
  final List<FormMiddleCard> inputs = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    widget.titleController.text = widget.existingDoc.title;
    widget.descriptionController.text = widget.existingDoc.description;
    for (var element in widget.existingDoc.inputs) {
      _keys.add(GlobalKey<FormMiddleCardState>());
      inputs.add(createFormInputCard(_keys.last, element));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: saveDoc,
              icon: const Icon(Icons.save),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: FormDocRef(
            inputs: inputs,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Form Title'),
                  controller: widget.titleController,
                  onChanged: (value) {
                    triggerEditing();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Form Description'),
                  controller: widget.descriptionController,
                  onChanged: (value) {
                    triggerEditing();
                  },
                ),
                Expanded(
                  child: ReorderableListView(
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = inputs[oldIndex];
                      setState(() {
                        triggerEditing();
                        inputs.removeAt(oldIndex);
                        inputs.insert(newIndex, item);
                      });
                    },
                    footer: ElevatedButton(
                      onPressed: addInput,
                      child: const Text('Add'),
                    ),
                    children: inputs,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void triggerEditing() {
    ProviderScope.containerOf(context)
        .read(formEditing.notifier)
        .update((state) => true);
  }

  void saveDoc() {
    if (_formKey.currentState!.validate()) {
      var data = List<FormInputData>.empty(growable: true);
      for (var input in inputs) {
        var key = input.key as GlobalKey<FormMiddleCardState>;
        data.add(key.currentState!.data);
      }
      if (widget.existingDoc.id == null) {
        FirebaseFirestore.instance.collection('forms').add(FormDoc(
                title: widget.titleController.text,
                description: widget.descriptionController.text,
                inputs: data.toList())
            .toDocument());
      } else {
        FirebaseFirestore.instance
            .collection('forms')
            .doc(widget.existingDoc.id)
            .update(FormDoc(
                    title: widget.titleController.text,
                    description: widget.descriptionController.text,
                    inputs: data.toList())
                .toDocument());
      }
      ProviderScope.containerOf(context)
          .read(formEditing.notifier)
          .update((state) => false);
      context.go('/forms');
    }
  }

  void addInput() {
    if (_formKey.currentState!.validate()) {
      triggerEditing();
      setState(() {
        var key = GlobalKey<FormMiddleCardState>();
        _keys.add(key);
        inputs.add(createFormInputCard(key, FormInputData.empty()));
      });
    }
  }

  void removeInput(Key key) {
    triggerEditing();
    setState(() {
      inputs.removeWhere((element) => element.key == key);
      _keys.remove(key);
      _keys.last.currentState!.expand();
    });
  }

  FormMiddleCard createFormInputCard(Key key, FormInputData data) {
    return FormMiddleCard(
      key: key,
      requestFocus: requestFocus,
      onDelete: removeInput,
      data: data,
    );
  }

  void requestFocus(Key key) {
    GlobalKey<FormMiddleCardState> key0 = key as GlobalKey<FormMiddleCardState>;
    for (var keyn in _keys) {
      if (keyn.currentState!.isExpanded) {
        if (keyn.currentState!.widget.labelController.text.isEmpty) {
          removeInput(keyn);
        } else if (!_formKey.currentState!.validate()) {
          return;
        }
      }
      keyn.currentState!.shrink();
    }
    key0.currentState!.expand();
  }
}

class FormDocRef extends InheritedWidget {
  final List<FormMiddleCard> inputs;
  // ignore: overridden_fields, annotate_overrides
  final Widget child;

  const FormDocRef({super.key, required this.inputs, required this.child})
      : super(child: child);

  static FormDocRef? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FormDocRef>();
  }

  @override
  bool updateShouldNotify(covariant FormDocRef oldWidget) {
    return oldWidget.inputs != inputs;
  }
}
