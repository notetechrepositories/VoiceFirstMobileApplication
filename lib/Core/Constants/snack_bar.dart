import 'package:flutter/material.dart';

class SnackbarHelper {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void showSuccess(String message) {
    _show(
      message,
      backgroundColor: Colors.green.withAlpha(200),
      icon: Icons.check_circle,
    );
  }

  static void showError(String message) {
    _show(
      message,
      backgroundColor: Colors.redAccent.withAlpha(200),
      icon: Icons.error,
    );
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(27),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        backgroundColor: backgroundColor,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 18),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
