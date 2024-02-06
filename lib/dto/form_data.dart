import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rollmark/dto/form_input_data.dart';

part 'form_data.freezed.dart';
part 'form_data.g.dart';

@freezed
class FormData with _$FormData {
  const FormData._();

  factory FormData({
    String? id,
    required String title,
    required String description,
    // ignore: invalid_annotation_target
    @JsonKey(
        fromJson: FormInputData.listFromJson, toJson: FormInputData.listToJson)
    required List<FormInputData> inputs,
  }) = _FormData;

  factory FormData.empty() => FormData(
        title: 'New Form',
        description: '',
        inputs: [],
      );

  factory FormData.fromJson(Map<String, dynamic> json) =>
      _$FormDataFromJson(json);

  factory FormData.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FormData.fromJson(data).copyWith(id: doc.id);
  }

  Map<String, dynamic> toDocument() => toJson()..remove('id');
}
