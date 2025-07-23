import 'package:flutter/material.dart';
import '../../models/field_model.dart';

class FieldEditor extends StatefulWidget {
  final FieldModel field;
  final Function(FieldModel) onUpdate;
  final VoidCallback onDelete;

  const FieldEditor({
    Key? key,
    required this.field,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  _FieldEditorState createState() => _FieldEditorState();
}

class _FieldEditorState extends State<FieldEditor> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late List<TextEditingController> _optionControllers;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.field.title);
    _descriptionController = TextEditingController(text: widget.field.description);
    _optionControllers = widget.field.options
        .map((option) => TextEditingController(text: option))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.field.title),
      subtitle: Text(_getFieldTypeName(widget.field.type)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: widget.onDelete,
          ),
          Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
        ],
      ),
      onExpansionChanged: (expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                onChanged: _updateField,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: _updateField,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Required'),
                  SizedBox(width: 8),
                  Switch(
                    value: widget.field.isRequired,
                    onChanged: (value) {
                      final updatedField = FieldModel(
                        id: widget.field.id,
                        title: widget.field.title,
                        description: widget.field.description,
                        type: widget.field.type,
                        isRequired: value,
                        options: widget.field.options,
                        order: widget.field.order,
                        settings: widget.field.settings,
                      );
                      widget.onUpdate(updatedField);
                    },
                  ),
                ],
              ),
              if (_shouldShowOptions()) ...[
                SizedBox(height: 16),
                Text('Options:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ..._buildOptionsList(),
                SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _addOption,
                  icon: Icon(Icons.add),
                  label: Text('Add Option'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  bool _shouldShowOptions() {
    return widget.field.type == FieldType.multipleChoice ||
           widget.field.type == FieldType.checkbox ||
           widget.field.type == FieldType.dropdown;
  }

  List<Widget> _buildOptionsList() {
    return _optionControllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      
      return Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Option ${index + 1}',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _updateOptions(),
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removeOption(index),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController(text: 'Option ${_optionControllers.length + 1}'));
    });
    _updateOptions();
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 1) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
      _updateOptions();
    }
  }

  void _updateOptions() {
    final options = _optionControllers.map((controller) => controller.text).toList();
    final updatedField = FieldModel(
      id: widget.field.id,
      title: widget.field.title,
      description: widget.field.description,
      type: widget.field.type,
      isRequired: widget.field.isRequired,
      options: options,
      order: widget.field.order,
      settings: widget.field.settings,
    );
    widget.onUpdate(updatedField);
  }

  void _updateField([String? value]) {
    final updatedField = FieldModel(
      id: widget.field.id,
      title: _titleController.text,
      description: _descriptionController.text,
      type: widget.field.type,
      isRequired: widget.field.isRequired,
      options: widget.field.options,
      order: widget.field.order,
      settings: widget.field.settings,
    );
    widget.onUpdate(updatedField);
  }

  String _getFieldTypeName(FieldType type) {
    switch (type) {
      case FieldType.text:
        return 'Short Text';
      case FieldType.multipleChoice:
        return 'Multiple Choice';
      case FieldType.checkbox:
        return 'Checkboxes';
      case FieldType.dropdown:
        return 'Dropdown';
      case FieldType.rating:
        return 'Rating';
      case FieldType.email:
        return 'Email';
      case FieldType.number:
        return 'Number';
      case FieldType.date:
        return 'Date';
      case FieldType.time:
        return 'Time';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
