import 'package:flutter/material.dart';
import 'package:justful/core/theme/app_colors.dart';

class JustfulLogo extends StatelessWidget {
  final double size;

  const JustfulLogo({
    super.key,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/justful_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

// Keep backward compatibility
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
    return JustfulLogo(size: size);
  }
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
