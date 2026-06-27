import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scamshield/core/theme/app_colors.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? accentColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: accentColor != null
              ? Border.all(color: accentColor!.withValues(alpha: 0.3), width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: accentColor ?? AppColors.shieldTeal),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.beVietnamPro(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
