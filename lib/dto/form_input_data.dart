import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'form_input_data.freezed.dart';
part 'form_input_data.g.dart';

enum FormInputType {
  text,
  number,
  date,
  time,
  select,
  checkbox,
  radio,
  file,
}

@freezed
class FormInputData with _$FormInputData {
  const FormInputData._();

  const factory FormInputData({
    required String label,
    required String prompt,
    // ignore: invalid_annotation_target
    @JsonEnum(alwaysCreate: true) required FormInputType type,
    List<String>? options,
    required bool require,
  }) = _FormInputData;

  factory FormInputData.empty() => const FormInputData(
        label: '',
        prompt: '',
        type: FormInputType.text,
        require: true,
        options: [],
      );

  static List<FormInputData> listFromJson(List<dynamic> json) =>
      json.map((e) => FormInputData.fromJson(e)).toList();

  static List<Map<String, dynamic>> listToJson(List<FormInputData> list) =>
      list.map((e) => e.toJson()).toList();

  factory FormInputData.fromJson(Map<String, dynamic> json) =>
      _$FormInputDataFromJson(json);

  factory FormInputData.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FormInputData.fromJson(data);
  }
}
