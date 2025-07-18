import 'package:flutter/material.dart';

class AddBusinessActivityDialog extends StatefulWidget {
  //for single add
  final Function({
    required String name,
    required bool company,
    required bool branch,
    required bool section,
    required bool subSection,
  })
  onSubmit;

  const AddBusinessActivityDialog({super.key, required this.onSubmit});

  @override
  State<AddBusinessActivityDialog> createState() =>
      _AddBusinessActivityDialogState();
}

class _AddBusinessActivityDialogState extends State<AddBusinessActivityDialog> {
  final TextEditingController _nameController = TextEditingController();
  bool _company = false;
  bool _branch = false;
  bool _section = false;
  bool _subSection = false;

  final Color _bgColor = Colors.black;
  final Color _accentColor = Color(0xFFFCC737);
  final Color _textPrimary = Colors.white;
  final Color _textSecondary = Colors.white60;
  final Color _cardColor = Color(0xFF262626);

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
              _company,
              (v) => setState(() => _company = v),
            ),
            _buildCheckbox(
              'Branch',
              _branch,
              (v) => setState(() => _branch = v),
            ),
            _buildCheckbox(
              'Section',
              _section,
              (v) => setState(() => _section = v),
            ),
            _buildCheckbox(
              'Sub-section',
              _subSection,
              (v) => setState(() => _subSection = v),
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
            widget.onSubmit(
              name: _nameController.text.trim(),
              company: _company,
              branch: _branch,
              section: _section,
              subSection: _subSection,
            );
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
