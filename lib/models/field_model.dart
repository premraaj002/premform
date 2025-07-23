enum FieldType {
  text,
  multipleChoice,
  checkbox,
  dropdown,
  rating,
  email,
  number,
  date,
  time,
}

class FieldModel {
  String id;
  String title;
  String description;
  FieldType type;
  bool isRequired;
  List<String> options;
  int order;
  Map<String, dynamic> settings;

  FieldModel({
    required this.id,
    required this.title,
    required this.type,
    this.description = '',
    this.isRequired = false,
    this.options = const [],
    required this.order,
    this.settings = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'is_required': isRequired,
      'options': options,
      'order': order,
      'settings': settings,
    };
  }

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      type: FieldType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      isRequired: json['is_required'] ?? false,
      options: List<String>.from(json['options'] ?? []),
      order: json['order'],
      settings: json['settings'] ?? {},
    );
  }
}
