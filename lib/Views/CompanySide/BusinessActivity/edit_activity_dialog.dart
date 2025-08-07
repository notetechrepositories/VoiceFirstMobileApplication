import 'package:flutter/material.dart';

class EditActivityDialog extends StatefulWidget {
  final Map<String, dynamic> activity;
  final Color? bgColor;
  final Color? accentColor;
  final Color? textPrimary;
  final Color? textSecondary;
  final Function(Map<String, dynamic>) onSave;

  const EditActivityDialog({
    super.key,
    required this.activity,
    this.bgColor,
    this.accentColor,
    this.textPrimary,
    this.textSecondary,
    required this.onSave,
  });

  @override
  State<EditActivityDialog> createState() => _EditActivityDialogState();
}

class _EditActivityDialogState extends State<EditActivityDialog> {
  late TextEditingController _nameController;
  bool _company = false, _branch = false, _section = false, _subSection = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController = TextEditingController(
      text: widget.activity['business-activity'],
    );
    _company = widget.activity['company'] == 'y';
    _branch = widget.activity['branch'] == 'y';
    _section = widget.activity['section'] == 'y';
    _subSection = widget.activity['sub_section'] == 'y';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.bgColor,
      title: Text('Edit Activity', style: TextStyle(color: widget.accentColor)),
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
            _buildCheckbox('Sub_section', _subSection, (v) => _subSection = v),
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
            final updated = {
              'id': widget.activity['id'],
              'business_activity-name': _nameController.text.trim(),
              'company': _company ? 'y' : 'n',
              'branch': _branch ? 'y' : 'n',
              'section': _section ? 'y' : 'n',
              'sub_section': _subSection ? 'y' : 'n',
            };
            widget.onSave(updated);
            Navigator.of(context).pop();
          },
          child: Text('Save', style: TextStyle(color: widget.accentColor)),
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
