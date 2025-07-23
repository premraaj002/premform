import 'field_model.dart';

class FormModel {
  String id;
  String title;
  String description;
  List<FieldModel> fields;
  DateTime createdAt;
  DateTime updatedAt;
  bool isPublished;
  String backgroundColor;
  String textColor;

  FormModel({
    required this.id,
    required this.title,
    required this.description,
    required this.fields,
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = false,
    this.backgroundColor = '#ffffff',
    this.textColor = '#000000',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fields': fields.map((field) => field.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_published': isPublished,
      'background_color': backgroundColor,
      'text_color': textColor,
    };
  }

  factory FormModel.fromJson(Map<String, dynamic> json) {
    return FormModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      fields: (json['fields'] as List)
          .map((field) => FieldModel.fromJson(field))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isPublished: json['is_published'] ?? false,
      backgroundColor: json['background_color'] ?? '#ffffff',
      textColor: json['text_color'] ?? '#000000',
    );
  }
}
