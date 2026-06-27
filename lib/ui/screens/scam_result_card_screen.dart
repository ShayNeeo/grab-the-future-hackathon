import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scamshield/core/theme/app_colors.dart';
import 'package:scamshield/ui/widgets/risk_badge.dart';
import 'package:scamshield/ui/widgets/shield_button.dart';

class ScamResultCardScreen extends StatelessWidget {
  const ScamResultCardScreen({super.key});

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
                    // Risk Banner
                    const RiskBanner(level: RiskLevel.critical),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Case summary
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
                              'Hợp đồng kỳ nghỉ',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.shieldTeal,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Giai đoạn: Trước khi đặt cọc',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Red flags section
                          Text(
                            'Dấu hiệu nguy hiểm phát hiện được',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _RedFlagRow(
                            number: 1,
                            title: 'Yêu cầu đặt cọc trước khi xem hợp đồng',
                            description:
                                'Bên bán ép chuyển tiền cọc mà không cho thời gian đọc kỹ điều khoản.',
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _RedFlagRow(
                            number: 2,
                            title: 'Không có điều khoản hoàn tiền',
                            description:
                                'Hợp đồng không ghi rõ quyền được hoàn tiền nếu hủy.',
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _RedFlagRow(
                            number: 3,
                            title: 'Áp lực thời gian bất thường',
                            description:
                                'Thông báo "chỉ còn 2 suất cuối" để tạo cảm giác cấp bách.',
                          ),
                          const SizedBox(height: 24),

                          // Manipulation tactics
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
                                  children: [
                                    _TacticPill(label: 'Áp lực thời gian'),
                                    _TacticPill(label: 'Khan hiếm giả tạo'),
                                    _TacticPill(label: 'Bằng chứng xã hội'),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
                label: '⏱️ Bật chế độ suy nghĩ 48h',
                onPressed: () {
                  Navigator.pushNamed(context, '/cooling-off');
                },
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
