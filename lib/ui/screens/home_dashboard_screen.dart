import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:justifty/core/theme/app_colors.dart';
import 'package:justifty/ui/widgets/bottom_nav_shell.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  void _navigateToChat(BuildContext context, {String? action}) {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: action,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavShell(
      currentIndex: 0,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // ── Teal Header with time-aware greeting ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(16),
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.shieldTeal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lightbulb_rounded,
                        size: 24,
                        color: AppColors.shieldTeal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mẹo an toàn hôm nay',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.shieldTeal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Không bao giờ chuyển tiền cho người lạ qua điện thoại — hãy hỏi người thân trước!',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Quick Action Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                      width: 80,
                      height: 80,
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
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Kiểm tra ngay',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gửi ảnh, tin nhắn hoặc ghi âm',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Action chips - equal width with Flexible
                    Row(
                      children: [
                        Expanded(
                          child: _ActionChip(
                            icon: Icons.camera_alt_rounded,
                            label: 'Ảnh',
                            onTap: () => _navigateToChat(context, action: 'camera'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionChip(
                            icon: Icons.mic_rounded,
                            label: 'Ghi âm',
                            onTap: () => _navigateToChat(context, action: 'voice'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionChip(
                            icon: Icons.text_fields_rounded,
                            label: 'Văn bản',
                            onTap: () => _navigateToChat(context, action: 'text'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Risk Summary Row - Equal width cards ──
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.history_rounded,
                      value: '5',
                      label: 'lần kiểm tra',
                      color: AppColors.shieldTeal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.warning_amber_rounded,
                      value: '2',
                      label: 'rủi ro',
                      color: AppColors.alertAmber,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.family_restroom_rounded,
                      value: 'An toàn',
                      label: 'gia đình',
                      color: AppColors.alertGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Recent Cases ──
              Text(
                'Lịch sử gần đây',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
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
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: Colors.white),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.beVietnamPro(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: riskColor, width: 4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 26, color: riskColor),
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
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 24,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
