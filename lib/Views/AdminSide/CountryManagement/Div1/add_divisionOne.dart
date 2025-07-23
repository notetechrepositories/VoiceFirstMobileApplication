import 'package:flutter/material.dart';

class AddDivisionOneDialog extends StatelessWidget {
  final String label;
  final Function(String divisionName) onSubmit;
  final Color backgroundColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;

  AddDivisionOneDialog({
    required this.label,
    required this.onSubmit,
    required this.backgroundColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
  });

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text('Add $label', style: TextStyle(color: textPrimary)),
      content: TextField(
        controller: _controller,
        style: TextStyle(color: textPrimary),
        decoration: InputDecoration(
          labelText: '$label Name',
          labelStyle: TextStyle(color: textSecondary),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: accentColor),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: accentColor)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: accentColor),
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              onSubmit(name);
              Navigator.of(context).pop();
            }
          },
          child: Text('Add', style: TextStyle(color: backgroundColor)),
        ),
      ],
    );
  }
}
