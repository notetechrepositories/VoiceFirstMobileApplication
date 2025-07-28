import 'package:flutter/material.dart';

class ArrowPainter extends CustomPainter {
  final bool isFirst;
  final bool isLast;
  final Color color;

  ArrowPainter({
    required this.isFirst,
    required this.isLast,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    // Left side
    if (isFirst) {
      path.moveTo(0, 0);
    } else {
      path.moveTo(10, 0);
    }

    // Top right
    path.lineTo(size.width - 10, 0);

    // Arrow tip
    if (!isLast) {
      path.lineTo(size.width, size.height / 2);
      path.lineTo(size.width - 10, size.height);
    } else {
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    }

    // Bottom left
    if (!isFirst) {
      path.lineTo(10, size.height);
      path.lineTo(0, size.height / 2);
    } else {
      path.lineTo(0, size.height);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
