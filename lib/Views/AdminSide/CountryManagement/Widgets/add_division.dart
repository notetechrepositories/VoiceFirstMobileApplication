import 'package:flutter/material.dart';

class AddDivisionDialog extends StatefulWidget {
  final String label;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Future<bool> Function(String name) onSubmit;

  const AddDivisionDialog({
    super.key,
    required this.label,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.onSubmit,
  });

  @override
  State<AddDivisionDialog> createState() => _AddDivisionDialogState();
}

class _AddDivisionDialogState extends State<AddDivisionDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isSaving = false;

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);
    final success = await widget.onSubmit(name);
    setState(() => _isSaving = false);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? '${widget.label} added' : 'Failed to add ${widget.label}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.cardColor,
      title: Text(
        'Add ${widget.label}',
        style: TextStyle(color: widget.accentColor),
      ),
      content: TextField(
        controller: _controller,
        style: TextStyle(color: widget.textPrimary),
        decoration: InputDecoration(
          labelText: '${widget.label} Name',
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
          child: Text('Add', style: TextStyle(color: widget.accentColor)),
        ),
      ],
    );
  }
}
