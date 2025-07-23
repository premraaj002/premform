import 'package:flutter/material.dart';
import '../../models/field_model.dart';

class RatingWidget extends StatefulWidget {
  final FieldModel field;
  final Function(int?) onChanged;

  const RatingWidget({
    Key? key,
    required this.field,
    required this.onChanged,
  }) : super(key: key);

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  int? _selectedRating;

  @override
  Widget build(BuildContext context) {
    return FormField<int>(
      validator: widget.field.isRequired
          ? (value) {
              if (value == null) {
                return 'Please provide a rating';
              }
              return null;
            }
          : null,
      builder: (FormFieldState<int> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: _selectedRating != null && index < _selectedRating!
                        ? Colors.amber
                        : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                    state.didChange(_selectedRating);
                    widget.onChanged(_selectedRating);
                  },
                );
              }),
            ),
            if (state.hasError)
              Padding(
                padding: EdgeInsets.only(top: 8),
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
