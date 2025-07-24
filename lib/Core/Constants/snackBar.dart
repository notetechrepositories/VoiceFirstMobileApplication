import 'package:flutter/material.dart';

class SnackbarHelper {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void showSuccess(String message) {
    _show(message, backgroundColor: Colors.green, icon: Icons.check_circle);
  }

  static void showError(String message) {
    _show(message, backgroundColor: Colors.redAccent, icon: Icons.error);
  }

  static void _show(
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
