import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/form_model.dart';
import '../models/field_model.dart';
import '../models/response_model.dart';
import '../services/api_service.dart';
import '../widgets/field_widgets/text_field_widget.dart';
import '../widgets/field_widgets/multiple_choice_widget.dart';
import '../widgets/field_widgets/checkbox_widget.dart';
import '../widgets/field_widgets/dropdown_widget.dart';
import '../widgets/field_widgets/rating_widget.dart';
import 'package:uuid/uuid.dart';

class FormPreviewScreen extends StatefulWidget {
  final FormModel form;

  const FormPreviewScreen({Key? key, required this.form}) : super(key: key);

  @override
  _FormPreviewScreenState createState() => _FormPreviewScreenState();
}

class _FormPreviewScreenState extends State<FormPreviewScreen> {
  final Map<String, dynamic> _responses = {};
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Preview'),
        backgroundColor: Color(int.parse(widget.form.backgroundColor.replaceFirst('#', '0xff'))),
      ),
      body: Container(
        color: Color(int.parse(widget.form.backgroundColor.replaceFirst('#', '0xff'))),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.form.title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(int.parse(widget.form.textColor.replaceFirst('#', '0xff'))),
                        ),
                      ),
                      if (widget.form.description.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          widget.form.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              ...widget.form.fields.map((field) => _buildField(field)).toList(),
              SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(FieldModel field) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    field.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (field.isRequired)
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
              ],
            ),
            if (field.description.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                field.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
            SizedBox(height: 12),
            _buildFieldWidget(field),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldWidget(FieldModel field) {
    switch (field.type) {
      case FieldType.text:
        return TextFieldWidget(
          field: field,
          onChanged: (value) => _responses[field.id] = value,
        );
      case FieldType.multipleChoice:
        return MultipleChoiceWidget(
          field: field,
          onChanged: (value) => _responses[field.id] = value,
        );
      case FieldType.checkbox:
        return CheckboxWidget(
          field: field,
          onChanged: (values) => _responses[field.id] = values,
        );
      case FieldType.dropdown:
        return DropdownWidget(
          field: field,
          onChanged: (value) => _responses[field.id] = value,
        );
      case FieldType.rating:
        return RatingWidget(
          field: field,
          onChanged: (value) => _responses[field.id] = value,
        );
      case FieldType.email:
        return TextFieldWidget(
          field: field,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => _responses[field.id] = value,
        );
      case FieldType.number:
        return TextFieldWidget(
          field: field,
          keyboardType: TextInputType.number,
          onChanged: (value) => _responses[field.id] = value,
        );
      case FieldType.date:
        return _buildDateField(field);
      case FieldType.time:
        return _buildTimeField(field);
    }
  }

  Widget _buildDateField(FieldModel field) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          setState(() {
            _responses[field.id] = date.toIso8601String();
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today),
            SizedBox(width: 12),
            Text(
              _responses[field.id] != null
                  ? DateTime.parse(_responses[field.id]).toString().split(' ')[0]
                  : 'Select Date',
              style: TextStyle(
                color: _responses[field.id] != null ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(FieldModel field) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          setState(() {
            _responses[field.id] = '${time.hour}:${time.minute}';
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time),
            SizedBox(width: 12),
            Text(
              _responses[field.id] ?? 'Select Time',
              style: TextStyle(
                color: _responses[field.id] != null ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Submit',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check required fields
    for (final field in widget.form.fields) {
      if (field.isRequired && 
          (_responses[field.id] == null || 
           _responses[field.id].toString().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all required fields')),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = ResponseModel(
        id: Uuid().v4(),
        formId: widget.form.id,
        answers: _responses,
        submittedAt: DateTime.now(),
      );

      await context.read<ApiService>().submitResponse(response);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Your response has been submitted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting form: $e')),
      );
    }

    setState(() {
      _isSubmitting = false;
    });
  }
}
