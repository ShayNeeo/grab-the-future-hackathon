import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:justifty/core/theme/app_colors.dart';

class ShieldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isFullWidth;
  final double height;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const ShieldButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.height = 56,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppColors.shieldTeal,
            minimumSize: Size.fromHeight(height),
            side: BorderSide(
              color: backgroundColor ?? AppColors.shieldTeal,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.beVietnamPro(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.shieldTeal,
            foregroundColor: textColor ?? AppColors.surfaceWhite,
            minimumSize: Size.fromHeight(height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.beVietnamPro(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          );

    final button = isOutlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: _buildChild(),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: style,
            child: _buildChild(),
          );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  Widget _buildChild() {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }
    return Text(label);
  }
}

class ShieldIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  const ShieldIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 56,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: size * 0.45, color: color ?? AppColors.shieldTeal),
        tooltip: tooltip,
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
