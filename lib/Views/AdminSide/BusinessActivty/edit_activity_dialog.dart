import 'package:flutter/material.dart';
import 'package:voicefirst/Core/Constants/snack_bar.dart';

class EditActivityDialog extends StatefulWidget {
  final Map<String, dynamic> activity;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Future<Map<String, dynamic>?> Function(Map<String, dynamic>) onUpdate;
  final VoidCallback onUpdated;
  final VoidCallback onCancel;

  const EditActivityDialog({
    super.key,
    required this.activity,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.onUpdate,
    required this.onUpdated,
    required this.onCancel,
  });

  @override
  State<EditActivityDialog> createState() => _EditActivityDialogState();
}

class _EditActivityDialogState extends State<EditActivityDialog> {
  late TextEditingController _nameController;
  late bool _company, _branch, _section, _subSection;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.activity['business_activity_name'],
    );
    _company = widget.activity['company'] == 'y';
    _branch = widget.activity['branch'] == 'y';
    _section = widget.activity['section'] == 'y';
    _subSection = widget.activity['sub_section'] == 'y';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    final updatedData = {"id": widget.activity['id']};

    if (widget.activity['business_activity_name'] != newName) {
      updatedData['activityName'] = newName;
    }
    if ((_company ? 'y' : 'n') != widget.activity['company']) {
      updatedData['company'] = _company;
    }
    if ((_branch ? 'y' : 'n') != widget.activity['branch']) {
      updatedData['branch'] = _branch;
    }
    if ((_section ? 'y' : 'n') != widget.activity['section']) {
      updatedData['section'] = _section;
    }
    if ((_subSection ? 'y' : 'n') != widget.activity['sub_section']) {
      updatedData['subSection'] = _subSection;
    }

    if (updatedData.length == 1) {
      Navigator.of(context).pop();
      SnackbarHelper.showSuccess('No changes to update');
      return;
    }

    final updatedActivity = await widget.onUpdate(updatedData);

    if (updatedActivity != null) {
      widget.activity['business_activity_name'] =
          updatedActivity['activityName'];
      widget.activity['company'] = updatedActivity['company'] ? 'y' : 'n';
      widget.activity['branch'] = updatedActivity['branch'] ? 'y' : 'n';
      widget.activity['section'] = updatedActivity['section'] ? 'y' : 'n';
      widget.activity['sub_section'] = updatedActivity['subSection']
          ? 'y'
          : 'n';
      widget.activity['status'] = updatedActivity['status']
          ? 'active'
          : 'inactive';

      widget.onUpdated();
      Navigator.of(context).pop();

      SnackbarHelper.showSuccess('Activity updated');
    } else {
      Navigator.of(context).pop();
      SnackbarHelper.showError('Failed to update activity');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.cardColor,
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
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _company,
              onChanged: (v) => setState(() => _company = v!),
              title: Text(
                'Company',
                style: TextStyle(color: widget.textPrimary),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _branch,
              onChanged: (v) => setState(() => _branch = v!),
              title: Text(
                'Branch',
                style: TextStyle(color: widget.textPrimary),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _section,
              onChanged: (v) => setState(() => _section = v!),
              title: Text(
                'Section',
                style: TextStyle(color: widget.textPrimary),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _subSection,
              onChanged: (v) => setState(() => _subSection = v!),
              title: Text(
                'Sub-section',
                style: TextStyle(color: widget.textPrimary),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onCancel();
            Navigator.of(context).pop();
          },
          child: Text('Cancel', style: TextStyle(color: widget.textSecondary)),
        ),
        TextButton(
          onPressed: _saveChanges,
          child: Text('Save', style: TextStyle(color: widget.accentColor)),
        ),
      ],
    );
  }
}
