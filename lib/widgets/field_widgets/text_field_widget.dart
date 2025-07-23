import 'package:flutter/material.dart';
import '../../models/field_model.dart';

class TextFieldWidget extends StatelessWidget {
  final FieldModel field;
  final Function(String) onChanged;
  final TextInputType keyboardType;

  const TextFieldWidget({
    Key? key,
    required this.field,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Your answer',
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: field.isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              if (field.type == FieldType.email) {
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
              }
              return null;
            }
          : null,
      onChanged: onChanged,
    );
  }
}
