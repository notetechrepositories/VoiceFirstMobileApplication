import 'package:flutter/material.dart';
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color bgColor;
  final Color textColor;
  final Color accentColor;
  final VoidCallback onConfirmed;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Yes',
    this.cancelText = 'Cancel',
    required this.bgColor,
    required this.textColor,
    required this.accentColor,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: bgColor,
      title: Text(title, style: TextStyle(color: accentColor)),
      content: Text(message, style: TextStyle(color: textColor)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Cancel
          child: Text(cancelText, style: TextStyle(color: textColor)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog first
            onConfirmed(); // Then run the callback
          },
          child: Text(confirmText, style: TextStyle(color: accentColor)),
        ),
      ],
    );
  }
}
