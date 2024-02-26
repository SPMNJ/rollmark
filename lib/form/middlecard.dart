import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rollmark/dto/form_input_data.dart';
import 'package:rollmark/form/card.dart';
import 'package:rollmark/form/cardview.dart';
import 'package:rollmark/provider.dart';

class FormMiddleCard extends StatefulWidget {
  final Function(Key key) requestFocus;
  final FormInputData data;
  final Function(Key key) onDelete;

  FormMiddleCard(
      {super.key,
      required this.requestFocus,
      required this.onDelete,
      required this.data});

  @override
  State<FormMiddleCard> createState() => FormMiddleCardState();

  final TextEditingController labelController = TextEditingController();
  final TextEditingController promptController = TextEditingController();
  final List<TextEditingController> optionsController =
      List<TextEditingController>.empty(growable: true);
}

class FormMiddleCardState extends State<FormMiddleCard> {
  bool isExpanded = false;
  bool _isRequired = true;
  FormInputType _dropdownValue = FormInputType.text;
  @override
  void initState() {
    super.initState();
    widget.labelController.text = widget.data.label;
    widget.promptController.text = widget.data.prompt;
    _dropdownValue = widget.data.type;
    _isRequired = widget.data.require;
    if (widget.data.options != null && widget.data.options!.isNotEmpty) {
      for (var element in widget.data.options!) {
        widget.optionsController.add(TextEditingController(text: element));
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.requestFocus(widget.key!);
      }
    });
  }

  @override
  void dispose() {
    widget.labelController.dispose();
    widget.promptController.dispose();
    for (var element in widget.optionsController) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget temp;
    if (isExpanded) {
      temp = FormEditCard(
          labelController: widget.labelController,
          promptController: widget.promptController,
          dropdownValue: _dropdownValue,
          checkboxValue: _isRequired,
          optionsController: widget.optionsController,
          addOption: () {
            ProviderScope.containerOf(context)
                .read(formEditing.notifier)
                .update((state) => true);
            widget.optionsController.add(TextEditingController());
            setState(() {});
          },
          removeOption: (int index) {
            ProviderScope.containerOf(context)
                .read(formEditing.notifier)
                .update((state) => true);
            widget.optionsController.removeAt(index);
            setState(() {});
          },
          onDelete: () {
            widget.onDelete(widget.key!);
          },
          onCheckbox: (bool checkbox) {
            ProviderScope.containerOf(context)
                .read(formEditing.notifier)
                .update((state) => true);
            _isRequired = checkbox;
            setState(() {});
          },
          onDropdown: (FormInputType dropdown) {
            ProviderScope.containerOf(context)
                .read(formEditing.notifier)
                .update((state) => true);
            _dropdownValue = dropdown;
            setState(() {});
          },
          onReset: () {
            widget.labelController.text = widget.data.label;
            widget.promptController.text = widget.data.prompt;
            _dropdownValue = widget.data.type;
            _isRequired = widget.data.require;
            widget.optionsController.clear();
            if (widget.data.options != null &&
                widget.data.options!.isNotEmpty) {
              for (var element in widget.data.options!) {
                widget.optionsController
                    .add(TextEditingController(text: element));
              }
            }
            setState(() {});
          });
    } else {
      temp = GestureDetector(
        child: FormEditCardView(
          label: widget.labelController.text,
          prompt: widget.promptController.text,
          type: _dropdownValue,
          options: widget.optionsController
              .map((e) => e.text)
              .where((element) => element.isNotEmpty)
              .toList(),
          require: _isRequired,
        ),
        onTap: () => widget.requestFocus(widget.key!),
      );
    }
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SizeTransition(sizeFactor: animation, child: child);
        },
        child: temp);
  }

  void expand() {
    setState(() {
      isExpanded = true;
    });
  }

  void shrink() {
    setState(() {
      isExpanded = false;
    });
  }

  bool validate() {
    if (widget.labelController.text.isEmpty) {
      return false;
    }
    if (widget.promptController.text.isEmpty) {
      return false;
    }
    if (_dropdownValue == FormInputType.checkbox ||
        _dropdownValue == FormInputType.radio ||
        _dropdownValue == FormInputType.select) {
      if (widget.optionsController
          .map((e) => e.text)
          .where((element) => element.isNotEmpty)
          .isEmpty) {
        return false;
      }
      return false;
    }
    return true;
  }

  FormInputData get data {
    return FormInputData(
      label: widget.labelController.text,
      prompt: widget.promptController.text,
      type: _dropdownValue,
      options: widget.optionsController
          .map((e) => e.text)
          .where((element) => element.isNotEmpty)
          .toList(),
      require: _isRequired,
    );
  }
}
