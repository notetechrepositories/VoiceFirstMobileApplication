import 'package:flutter/material.dart';
import 'package:voicefirst/Models/business_activity.dart';

class AddBusinessActivityDialog extends StatefulWidget {
  //for single add
  // final Function({
  //   required String activityName,
  //   required bool isForCompany,
  //   required bool isForBranch,
  //   // required bool section,
  //   // required bool subSection,
  // })
  // onSubmit;

  final Function(BusinessActivity) onSubmit;

  const AddBusinessActivityDialog({super.key, required this.onSubmit});

  @override
  State<AddBusinessActivityDialog> createState() =>
      _AddBusinessActivityDialogState();
}

class _AddBusinessActivityDialogState extends State<AddBusinessActivityDialog> {
  final TextEditingController _nameController = TextEditingController();
  bool _isForCompany = false;
  bool _isForBranch = false;
  // bool _section = false;
  // bool _subSection = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF262626),
      title: Text('Add Activity', style: TextStyle(color: Color(0xFFFCC737))),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Activity Name',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            _buildCheckbox(
              'Company',
              _isForCompany,
              (v) => setState(() => _isForCompany = v),
            ),
            _buildCheckbox(
              'Branch',
              _isForBranch,
              (v) => setState(() => _isForBranch = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) return;
            final newActivity = BusinessActivity(
              id: '',
              activityName: _nameController.text.trim(),
              isForCompany: _isForCompany,
              isForBranch: _isForBranch,
              status: true,
              // section: _section,
              // subSection: _subSection,
            );
            widget.onSubmit(newActivity);
            Navigator.of(context).pop();
          },
          child: Text('Add', style: TextStyle(color: Color(0xFFFCC737))),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v!),
      title: Text(label, style: TextStyle(color: Colors.white)),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
