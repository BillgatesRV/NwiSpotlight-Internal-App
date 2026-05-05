import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final double aspectRatio;
  GridPainter({required this.aspectRatio});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 0.8;

    final width = size.width;
    final height = size.height;

    final colWidth = width / 3;
    final rowHeight = height / 3;

    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(colWidth * i, 0),
        Offset(colWidth * i, height),
        paint,
      );
    }

    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(0, rowHeight * i),
        Offset(width, rowHeight * i),
        paint,
      );
    }

    final borderPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), borderPaint);
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.aspectRatio != aspectRatio;
  }
}