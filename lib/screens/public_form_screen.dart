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

class PublicFormScreen extends StatefulWidget {
  final String formId;

  const PublicFormScreen({Key? key, required this.formId}) : super(key: key);

  @override
  _PublicFormScreenState createState() => _PublicFormScreenState();
}

class _PublicFormScreenState extends State<PublicFormScreen> {
  FormModel? _form;
  final Map<String, dynamic> _responses = {};
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    try {
      final form = await context.read<ApiService>().getFormById(widget.formId);
      setState(() {
        _form = form;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading form: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF6366F1)),
              SizedBox(height: 16),
              Text('Loading form...'),
            ],
          ),
        ),
      );
    }

    if (_form == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Form not found'),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_form!.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(24),
          children: [
            _buildFormHeader(),
            SizedBox(height: 24),
            ..._form!.fields.map((field) => _buildField(field)).toList(),
            SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _form!.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          if (_form!.description.isNotEmpty) ...[
            SizedBox(height: 12),
            Text(
              _form!.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildField(FieldModel field) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              if (field.isRequired)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Required',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (field.description.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              field.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
          SizedBox(height: 16),
          _buildFieldWidget(field),
        ],
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
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Color(0xFF6366F1)),
            SizedBox(width: 12),
            Text(
              _responses[field.id] != null
                  ? DateTime.parse(_responses[field.id]).toString().split(' ')[0]
                  : 'Select Date',
              style: TextStyle(
                color: _responses[field.id] != null 
                    ? Color(0xFF1F2937) 
                    : Colors.grey,
                fontSize: 16,
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
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Color(0xFF6366F1)),
            SizedBox(width: 12),
            Text(
              _responses[field.id] ?? 'Select Time',
              style: TextStyle(
                color: _responses[field.id] != null 
                    ? Color(0xFF1F2937) 
                    : Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Submit Response',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check required fields
    for (final field in _form!.fields) {
      if (field.isRequired && 
          (_responses[field.id] == null || 
           _responses[field.id].toString().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all required fields'),
            backgroundColor: Color(0xFFEF4444),
          ),
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
        formId: _form!.id,
        answers: _responses,
        submittedAt: DateTime.now(),
      );

      await context.read<ApiService>().submitResponse(response);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 48,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Response Submitted!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Thank you for your submission.',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF10B981),
                ),
                child: Text('Done'),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting form: $e'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }

    setState(() {
      _isSubmitting = false;
    });
  }
}
