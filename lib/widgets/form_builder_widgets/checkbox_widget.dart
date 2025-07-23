import 'package:flutter/material.dart';
import '../../models/field_model.dart';

class CheckboxWidget extends StatefulWidget {
  final FieldModel field;
  final Function(List<String>) onChanged;

  const CheckboxWidget({
    Key? key,
    required this.field,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CheckboxWidgetState createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  List<String> _selectedValues = [];

  @override
  Widget build(BuildContext context) {
    return FormField<List<String>>(
      validator: widget.field.isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please select at least one option';
              }
              return null;
            }
          : null,
      builder: (FormFieldState<List<String>> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...widget.field.options.map((option) {
              return CheckboxListTile(
                title: Text(option),
                value: _selectedValues.contains(option),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedValues.add(option);
                    } else {
                      _selectedValues.remove(option);
                    }
                  });
                  state.didChange(_selectedValues);
                  widget.onChanged(_selectedValues);
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
