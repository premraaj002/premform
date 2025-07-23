import 'package:flutter/material.dart';
import '../../models/field_model.dart';

class MultipleChoiceWidget extends StatefulWidget {
  final FieldModel field;
  final Function(String?) onChanged;

  const MultipleChoiceWidget({
    Key? key,
    required this.field,
    required this.onChanged,
  }) : super(key: key);

  @override
  _MultipleChoiceWidgetState createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: widget.field.isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please select an option';
              }
              return null;
            }
          : null,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...widget.field.options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _selectedValue,
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value;
                  });
                  state.didChange(value);
                  widget.onChanged(value);
                },
              );
            }).toList(),
            if (state.hasError)
              Padding(
                padding: EdgeInsets.only(left: 16, top: 8),
                child: Text(
                  state.errorText!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
