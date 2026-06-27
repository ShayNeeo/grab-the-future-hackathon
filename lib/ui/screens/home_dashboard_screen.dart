import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scamshield/core/theme/app_colors.dart';
import 'package:scamshield/ui/widgets/bottom_nav_shell.dart';
import 'package:scamshield/ui/widgets/stat_card.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavShell(
      currentIndex: 0,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // ── Teal Header with time-aware greeting ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.shieldTeal,
                      Color(0xFF1A9DAA),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()}, Bà Lan',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hôm nay bạn có gì cần kiểm tra không?',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Notification bell with accessibility
                    Semantics(
                      label: 'Thông báo',
                      button: true,
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                          tooltip: 'Xem thông báo',
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Daily Safety Tip Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.shieldTealBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.shieldTeal.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.shieldTeal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.lightbulb_rounded,
                        size: 26,
                        color: AppColors.shieldTeal,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mẹo an toàn hôm nay',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.shieldTeal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Không bao giờ chuyển tiền cho người lạ qua điện thoại — hãy hỏi người thân trước!',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Quick Action Card ──
              Semantics(
                label: 'Kiểm tra ngay — Gửi ảnh, tin nhắn hoặc ghi âm để kiểm tra lừa đảo',
                button: true,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/chat'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.shieldTeal,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shieldTeal.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Shield icon with animated pulse ring
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 3,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                            child: const Icon(
                              Icons.shield_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Kiểm tra ngay',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Gửi ảnh, tin nhắn hoặc ghi âm',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Bigger action chips with labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ActionChip(
                              icon: Icons.camera_alt_rounded,
                              label: 'Ảnh',
                            ),
                            const SizedBox(width: 12),
                            _ActionChip(
                              icon: Icons.mic_rounded,
                              label: 'Ghi âm',
                            ),
                            const SizedBox(width: 12),
                            _ActionChip(
                              icon: Icons.text_fields_rounded,
                              label: 'Văn bản',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Risk Summary Row ──
              Row(
                children: [
                  StatCard(
                    icon: Icons.history_rounded,
                    value: '5',
                    label: 'lần kiểm tra',
                  ),
                  const SizedBox(width: 12),
                  StatCard(
                    icon: Icons.warning_amber_rounded,
                    value: '2',
                    label: 'rủi ro phát hiện',
                    accentColor: AppColors.alertAmber,
                  ),
                  const SizedBox(width: 12),
                  StatCard(
                    icon: Icons.family_restroom_rounded,
                    value: 'An toàn',
                    label: 'Gia đình',
                    accentColor: AppColors.alertGreen,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Recent Cases ──
              Text(
                'Lịch sử gần đây',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _CaseCard(
                title: 'Hợp đồng kỳ nghỉ',
                subtitle: 'Rủi ro cao · 2 giờ trước',
                riskColor: AppColors.alertOrange,
                icon: Icons.warning_amber_rounded,
              ),
              const SizedBox(height: 12),
              _CaseCard(
                title: 'Tin nhắn trúng thưởng',
                subtitle: 'An toàn · 1 ngày trước',
                riskColor: AppColors.alertGreen,
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(height: 12),
              _CaseCard(
                title: 'Cuộc gọi từ số lạ',
                subtitle: 'Rủi ro cao · 3 ngày trước',
                riskColor: AppColors.alertRed,
                icon: Icons.phone_disabled_rounded,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.beVietnamPro(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color riskColor;
  final IconData icon;

  const _CaseCard({
    required this.title,
    required this.subtitle,
    required this.riskColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: riskColor, width: 4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: riskColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 28,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
