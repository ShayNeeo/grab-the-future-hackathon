import 'package:flutter/material.dart';
import '../../core/api/models/analysis_response.dart';

class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.level});

  final RiskLevel level;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (level) {
      RiskLevel.critical => ('NGUY HIỂM CAO', const Color(0xFFFF4D4D), Icons.dangerous),
      RiskLevel.high     => ('RỦI RO CAO',    const Color(0xFFFF8C42), Icons.warning),
      RiskLevel.medium   => ('RỦI RO VỪA',   const Color(0xFFF5C542), Icons.info),
      RiskLevel.low      => ('AN TOÀN',       const Color(0xFF4ADE80), Icons.check_circle),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
