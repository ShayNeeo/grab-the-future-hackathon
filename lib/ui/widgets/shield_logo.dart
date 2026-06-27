import 'package:flutter/material.dart';
import 'package:scamshield/core/theme/app_colors.dart';

class ShieldLogo extends StatelessWidget {
  final double size;
  final Color color;
  final bool showCheckmark;

  const ShieldLogo({
    super.key,
    this.size = 120,
    this.color = Colors.white,
    this.showCheckmark = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShieldPainter(color: color, showCheckmark: showCheckmark),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  final Color color;
  final bool showCheckmark;

  _ShieldPainter({required this.color, required this.showCheckmark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Shield shape
    path.moveTo(w * 0.5, h * 0.05);
    path.lineTo(w * 0.9, h * 0.2);
    path.lineTo(w * 0.9, h * 0.55);
    path.quadraticBezierTo(w * 0.9, h * 0.8, w * 0.5, h * 0.95);
    path.quadraticBezierTo(w * 0.1, h * 0.8, w * 0.1, h * 0.55);
    path.lineTo(w * 0.1, h * 0.2);
    path.close();

    canvas.drawPath(path, paint);

    if (showCheckmark) {
      final checkPaint = Paint()
        ..color = AppColors.shieldTeal
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.08
        ..strokeCap = StrokeCap.round;

      final checkPath = Path();
      checkPath.moveTo(w * 0.3, h * 0.5);
      checkPath.lineTo(w * 0.45, h * 0.65);
      checkPath.lineTo(w * 0.7, h * 0.38);

      canvas.drawPath(checkPath, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ShieldIcon extends StatelessWidget {
  final double size;
  final Color color;

  const ShieldIcon({
    super.key,
    this.size = 24,
    this.color = AppColors.shieldTeal,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.shield_rounded,
      size: size,
      color: color,
    );
  }
}
