import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:justful/core/theme/app_colors.dart';
import 'package:justful/src/models/analysis_response.dart';
import 'package:justful/ui/widgets/risk_badge.dart';
import 'package:justful/ui/widgets/shield_button.dart';

class ScamResultCardScreen extends StatelessWidget {
  const ScamResultCardScreen({super.key, required this.analysis});

  final AnalysisResponse analysis;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        title: Text(
          'Kết quả phân tích',
          style: GoogleFonts.beVietnamPro(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: SizedBox(
          width: 56,
          height: 56,
          child: IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 26),
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── Analysis Result Card ──
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RiskBanner(level: analysis.riskLevel),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Case type + stage header
                          if (analysis.caseType.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.shieldTealBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                analysis.caseType,
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.shieldTeal,
                                ),
                              ),
                            ),
                          if (analysis.stage.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Giai đoạn: ${analysis.stage}',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          // ── Red Flags ──
                          Text(
                            'Dấu hiệu nguy hiểm phát hiện được',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (analysis.redFlags.isEmpty)
                            _NoFlagsNotice()
                          else
                            Column(
                              children: [
                                for (int i = 0;
                                    i < analysis.redFlags.length;
                                    i++) ...[
                                  if (i > 0)
                                    const Divider(
                                        height: 1, color: AppColors.divider),
                                  _RedFlagRow(
                                    number: i + 1,
                                    title: analysis.redFlags[i].type,
                                    description: analysis.redFlags[i].detail,
                                  ),
                                ],
                              ],
                            ),

                          // ── Manipulation Tactics ──
                          if (analysis.manipulationTactics.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.amberTint,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.psychology_rounded,
                                        size: 22,
                                        color: AppColors.alertAmber,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Kỹ thuật thao túng tâm lý',
                                        style: GoogleFonts.beVietnamPro(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: analysis.manipulationTactics
                                        .map((t) => _TacticPill(label: t))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // ── Next Actions ──
                          if (analysis.nextActions.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Hành động được đề xuất',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            for (final action in analysis.nextActions)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 20,
                                        color: AppColors.shieldTeal,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        action,
                                        style: GoogleFonts.beVietnamPro(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textPrimary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Action Buttons ──
              ShieldButton(
                label: '🛑 Không ký / Không chuyển tiền',
                onPressed: () {},
                backgroundColor: AppColors.shieldTeal,
              ),
              const SizedBox(height: 12),
              ShieldButton(
                label:
                    '⏱️ Bật chế độ suy nghĩ ${analysis.coolingOffHours}h',
                onPressed: () => Navigator.pushNamed(context, '/cooling-off'),
                isOutlined: true,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                child: Text(
                  '📤 Gửi cho người thân',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.shieldTeal,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoFlagsNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.alertGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.alertGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: AppColors.alertGreen, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Không phát hiện dấu hiệu lừa đảo rõ ràng',
              style: GoogleFonts.beVietnamPro(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.alertGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RedFlagRow extends StatelessWidget {
  final int number;
  final String title;
  final String description;

  const _RedFlagRow({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      color: AppColors.redTint,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.alertRed,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: GoogleFonts.beVietnamPro(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TacticPill extends StatelessWidget {
  final String label;

  const _TacticPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.alertAmber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.alertAmber.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.beVietnamPro(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
