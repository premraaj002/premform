import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/form_model.dart';
import '../models/field_model.dart';
import '../services/api_service.dart';
import '../widgets/form_builder_widgets/field_editor.dart';
import 'form_preview_screen.dart';
import 'form_share_screen.dart'; // Add this import
import 'package:uuid/uuid.dart';

class FormBuilderScreen extends StatefulWidget {
  final FormModel form;

  const FormBuilderScreen({Key? key, required this.form}) : super(key: key);

  @override
  _FormBuilderScreenState createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends State<FormBuilderScreen>
    with TickerProviderStateMixin {
  late FormModel _form;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _form = widget.form;
    _titleController.text = _form.title;
    _descriptionController.text = _form.description;
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: _buildModernAppBar(),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF6366F1)),
                  SizedBox(height: 16),
                  Text('Saving form...', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _animationController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormHeader(),
                    SizedBox(height: 32),
                    _buildFieldsList(),
                    SizedBox(height: 24),
                    _buildAddFieldSection(),
                  ],
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
        ),
      ),
      title: Text(
        'Form Builder',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1F2937),
        ),
      ),
      actions: [
        // Preview Button
        Container(
          margin: EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      FormPreviewScreen(form: _form),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: Duration(milliseconds: 300),
                ),
              );
            },
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.preview, color: Color(0xFF8B5CF6)),
            ),
          ),
        ),
        // Share Button - NEW
        Container(
          margin: EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () {
              if (_form.fields.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Add at least one question before sharing'),
                      ],
                    ),
                    backgroundColor: Color(0xFFF59E0B),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
                return;
              }
              
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      FormShareScreen(form: _form),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: animation.drive(
                        Tween(begin: Offset(0.0, 1.0), end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeOutCubic)),
                      ),
                      child: child,
                    );
                  },
                  transitionDuration: Duration(milliseconds: 400),
                ),
              );
            },
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.share, color: Color(0xFF10B981)),
            ),
          ),
        ),
        // Save Button
        Container(
          margin: EdgeInsets.only(right: 16),
          child: ElevatedButton.icon(
            onPressed: _saveForm,
            icon: Icon(Icons.save, size: 18),
            label: Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6366F1), // Changed color for better distinction
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.settings, color: Color(0xFF6366F1)),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Form Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              // Quick Stats
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_form.fields.length} questions',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Form Title',
              prefixIcon: Icon(Icons.title),
            ),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            onChanged: (value) {
              setState(() {
                _form.title = value;
              });
            },
          ),
          SizedBox(height: 20),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Form Description',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _form.description = value;
              });
            },
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.publish, 
                  color: _form.isPublished ? Color(0xFF10B981) : Color(0xFFF59E0B)
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Publish Form',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        _form.isPublished 
                            ? 'Form is live and accepting responses'
                            : 'Form is saved as draft',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _form.isPublished,
                  onChanged: (value) {
                    setState(() {
                      _form.isPublished = value;
                    });
                    // Auto-save when publishing status changes
                    if (value) {
                      _saveForm();
                    }
                  },
                  activeColor: Color(0xFF10B981),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsList() {
    if (_form.fields.isEmpty) {
      return Container(
        padding: EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF6366F1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.quiz_outlined,
                size: 32,
                color: Color(0xFF6366F1),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'No questions yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first question to get started',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ReorderableListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      onReorder: _reorderFields,
      children: _form.fields.asMap().entries.map((entry) {
        final index = entry.key;
        final field = entry.value;
        return TweenAnimationBuilder(
          key: ValueKey(field.id),
          duration: Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: 0.95 + (0.05 * value),
              child: Opacity(
                opacity: value,
                child: Container(
                  margin: EdgeInsets.only(bottom: 20),
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
                  child: ModernFieldEditor(
                    field: field,
                    index: index,
                    onUpdate: (updatedField) {
                      setState(() {
                        _form.fields[index] = updatedField;
                      });
                    },
                    onDelete: () {
                      setState(() {
                        _form.fields.removeAt(index);
                        _updateFieldOrders();
                      });
                    },
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildAddFieldSection() {
    return Container(
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
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add, color: Color(0xFF10B981)),
                ),
                SizedBox(width: 16),
                Text(
                  'Add Question',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
          Padding(
            padding: EdgeInsets.all(20),
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
              children: FieldType.values.map((type) {
                return _buildFieldTypeButton(type);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldTypeButton(FieldType type) {
    return ElevatedButton(
      onPressed: () => _addField(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Color(0xFF1F2937),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getFieldTypeIcon(type), size: 18, color: Color(0xFF6366F1)),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              _getFieldTypeName(type),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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

  IconData _getFieldTypeIcon(FieldType type) {
    switch (type) {
      case FieldType.text:
        return Icons.text_fields;
      case FieldType.multipleChoice:
        return Icons.radio_button_checked;
      case FieldType.checkbox:
        return Icons.check_box;
      case FieldType.dropdown:
        return Icons.arrow_drop_down_circle;
      case FieldType.rating:
        return Icons.star_rate;
      case FieldType.email:
        return Icons.email;
      case FieldType.number:
        return Icons.numbers;
      case FieldType.date:
        return Icons.calendar_today;
      case FieldType.time:
        return Icons.access_time;
    }
  }

  void _addField(FieldType type) {
    final newField = FieldModel(
      id: Uuid().v4(),
      title: 'Untitled Question',
      type: type,
      order: _form.fields.length,
      options: type == FieldType.multipleChoice || 
               type == FieldType.checkbox || 
               type == FieldType.dropdown
          ? ['Option 1']
          : [],
    );

    setState(() {
      _form.fields.add(newField);
    });
  }

  void _reorderFields(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final field = _form.fields.removeAt(oldIndex);
      _form.fields.insert(newIndex, field);
      _updateFieldOrders();
    });
  }

  void _updateFieldOrders() {
    for (int i = 0; i < _form.fields.length; i++) {
      _form.fields[i].order = i;
    }
  }

  Future<void> _saveForm() async {
    if (_form.title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Text('Please enter a form title'),
            ],
          ),
          backgroundColor: Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _form.updatedAt = DateTime.now();
      
      if (widget.form.fields.isEmpty && _form.fields.isNotEmpty) {
        await context.read<ApiService>().createForm(_form);
      } else {
        await context.read<ApiService>().updateForm(_form);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Form saved successfully'),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Error saving form: $e')),
            ],
          ),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

// Keep your existing ModernFieldEditor class exactly as it is
class ModernFieldEditor extends StatefulWidget {
  final FieldModel field;
  final int index;
  final Function(FieldModel) onUpdate;
  final VoidCallback onDelete;

  const ModernFieldEditor({
    Key? key,
    required this.field,
    required this.index,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  _ModernFieldEditorState createState() => _ModernFieldEditorState();
}

class _ModernFieldEditorState extends State<ModernFieldEditor> {
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
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.field.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _getFieldTypeName(widget.field.type),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_isExpanded) ...[
          Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Question',
                    prefixIcon: Icon(Icons.help_outline),
                  ),
                  onChanged: _updateField,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    prefixIcon: Icon(Icons.description),
                  ),
                  onChanged: _updateField,
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFFEF4444)),
                      SizedBox(width: 12),
                      Text(
                        'Required',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Spacer(),
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
                        activeColor: Color(0xFF10B981),
                      ),
                    ],
                  ),
                ),
                if (_shouldShowOptions()) ...[
                  SizedBox(height: 20),
                  Text(
                    'Options',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 12),
                  ..._buildOptionsList(),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _addOption,
                    icon: Icon(Icons.add, size: 18),
                    label: Text('Add Option'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
      
      return Container(
        margin: EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Option ${index + 1}',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (_) => _updateOptions(),
              ),
            ),
            SizedBox(width: 12),
            IconButton(
              icon: Icon(Icons.remove_circle, color: Color(0xFFEF4444)),
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
