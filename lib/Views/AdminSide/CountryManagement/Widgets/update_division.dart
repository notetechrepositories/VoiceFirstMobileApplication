import 'package:flutter/material.dart';

class EditDivisionDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Future<bool> Function(String newName) onSubmit;

  const EditDivisionDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.onSubmit,
  });

  @override
  State<EditDivisionDialog> createState() => _EditDivisionDialogState();
}

class _EditDivisionDialogState extends State<EditDivisionDialog> {
  late TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  Future<void> _submit() async {
    final newName = _controller.text.trim();
    if (newName.isEmpty || newName == widget.initialValue) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);
    final success = await widget.onSubmit(newName);
    setState(() => _isSaving = false);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Updated successfully' : 'Update failed'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.cardColor,
      title: Text(widget.title, style: TextStyle(color: widget.accentColor)),
      content: TextField(
        controller: _controller,
        style: TextStyle(color: widget.textPrimary),
        decoration: InputDecoration(
          labelText: widget.title,
          labelStyle: TextStyle(color: widget.textSecondary),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: widget.textSecondary)),
        ),
        TextButton(
          onPressed: _isSaving ? null : _submit,
          child: Text('Save', style: TextStyle(color: widget.accentColor)),
        ),
      ],
    );
  }
}
