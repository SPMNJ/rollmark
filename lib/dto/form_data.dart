import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rollmark/dto/form_input_data.dart';

part 'form_data.freezed.dart';
part 'form_data.g.dart';

@freezed
class FormDoc with _$FormDoc {
  const FormDoc._();

  const factory FormDoc({
    String? id,
    required String title,
    required String description,
    // ignore: invalid_annotation_target
    @JsonKey(
        fromJson: FormInputData.listFromJson, toJson: FormInputData.listToJson)
    required List<FormInputData> inputs,
  }) = _F;

  factory FormDoc.empty() => FormDoc(
        title: 'New Form',
        description: '',
        inputs: [FormInputData.empty()],
      );

  factory FormDoc.fromJson(Map<String, dynamic> json) =>
      _$FormDocFromJson(json);

  factory FormDoc.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FormDoc.fromJson(data).copyWith(id: doc.id);
  }

  Map<String, dynamic> toDocument() => toJson()..remove('id');
}
