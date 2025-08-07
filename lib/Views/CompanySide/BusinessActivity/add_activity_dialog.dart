import 'package:flutter/material.dart';

class AddActivityDialog extends StatefulWidget {
  final Color bgColor;
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;
  final Function(Map<String, dynamic>) onAdd;

  const AddActivityDialog({
    super.key,
    required this.bgColor,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onAdd,
  });

  @override
  State<AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<AddActivityDialog> {
  final TextEditingController _nameController = TextEditingController();
  bool _company = false, _branch = false, _section = false, _subSection = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.bgColor,
      title: Text('Add Activity', style: TextStyle(color: widget.accentColor)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: widget.textPrimary),
              decoration: InputDecoration(
                labelText: 'Activity Name',
                labelStyle: TextStyle(color: widget.textSecondary),
              ),
            ),
            _buildCheckbox('Company', _company, (v) => _company = v),
            _buildCheckbox('Branch', _branch, (v) => _branch = v),
            _buildCheckbox('Section', _section, (v) => _section = v),
            _buildCheckbox('Sub-section', _subSection, (v) => _subSection = v),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: widget.textSecondary)),
        ),
        TextButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            final newActivity = {
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'business_activity_name': name,
              'company': _company ? 'y' : 'n',
              'branch': _branch ? 'y' : 'n',
              'section': _section ? 'y' : 'n',
              'sub_section': _subSection ? 'y' : 'n',
            };
            widget.onAdd(newActivity);
            Navigator.of(context).pop();
          },
          child: Text('Add', style: TextStyle(color: widget.accentColor)),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => setState(() => onChanged(v!)),
      title: Text(label, style: TextStyle(color: widget.textPrimary)),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
