import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scamshield/core/theme/app_colors.dart';
import 'package:scamshield/src/models/analysis_response.dart';

export 'package:scamshield/src/models/analysis_response.dart' show RiskLevel;

class RiskColors {
  final Color background;
  final Color text;
  final String label;
  final IconData icon;

  const RiskColors({
    required this.background,
    required this.text,
    required this.label,
    required this.icon,
  });

  static RiskColors forLevel(RiskLevel level) {
    switch (level) {
      case RiskLevel.critical:
        return const RiskColors(
          background: AppColors.alertRed,
          text: Colors.white,
          label: 'RỦI RO RẤT CAO',
          icon: Icons.shield_outlined,
        );
      case RiskLevel.high:
        return const RiskColors(
          background: AppColors.alertOrange,
          text: Colors.white,
          label: 'RỦI RO CAO',
          icon: Icons.warning_amber_rounded,
        );
      case RiskLevel.medium:
        return const RiskColors(
          background: AppColors.alertAmber,
          text: AppColors.textPrimary,
          label: 'RỦI RO TRUNG BÌNH',
          icon: Icons.info_outline,
        );
      case RiskLevel.low:
        return const RiskColors(
          background: AppColors.alertGreen,
          text: Colors.white,
          label: 'AN TOÀN',
          icon: Icons.check_circle_outline,
        );
    }
  }
}

class RiskBadge extends StatelessWidget {
  final RiskLevel level;
  final double fontSize;

  const RiskBadge({
    super.key,
    required this.level,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final risk = RiskColors.forLevel(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: risk.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(risk.icon, size: 16, color: risk.text),
          const SizedBox(width: 6),
          Text(
            risk.label,
            style: GoogleFonts.beVietnamPro(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: risk.text,
            ),
          ),
        ],
      ),
    );
  }
}

class RiskBanner extends StatelessWidget {
  final RiskLevel level;

  const RiskBanner({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final risk = RiskColors.forLevel(level);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: risk.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(risk.icon, color: risk.text, size: 28),
          const SizedBox(width: 10),
          Text(
            risk.label,
            style: GoogleFonts.beVietnamPro(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: risk.text,
            ),
          ),
        ],
      ),
    );
  }
}
