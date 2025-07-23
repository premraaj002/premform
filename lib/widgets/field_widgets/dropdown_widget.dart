import 'package:flutter/material.dart';
import '../../models/field_model.dart';

class DropdownWidget extends StatefulWidget {
  final FieldModel field;
  final Function(String?) onChanged;

  const DropdownWidget({
    Key? key,
    required this.field,
    required this.onChanged,
  }) : super(key: key);

  @override
  _DropdownWidgetState createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Choose...',
      ),
      value: _selectedValue,
      items: widget.field.options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedValue = value;
        });
        widget.onChanged(value);
      },
      validator: widget.field.isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please select an option';
              }
              return null;
            }
          : null,
    );
  }
}
