import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:justful/core/theme/app_colors.dart';
import 'package:justful/src/models/sms_alert.dart';
import 'package:justful/src/services/sms_detection_service.dart';
import 'package:justful/ui/widgets/bottom_nav_shell.dart';
import 'package:justful/ui/widgets/stat_card.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  // Change this to true to enable the SMS Web Simulator UI
  static const bool showSmsSimulator = false;

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  List<SmsAlert> _alerts = [];
  bool _isLoading = true;
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  @override
  void dispose() {
    _senderController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _loadAlerts() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList('sms_alerts') ?? [];
      final List<SmsAlert> parsed = list.map((item) {
        return SmsAlert.fromJson(json.decode(item) as Map<String, dynamic>);
      }).toList();
      setState(() {
        _alerts = parsed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  void _showAlertDetails(SmsAlert alert) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.alertRed),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cảnh báo từ ${alert.sender}',
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nội dung tin nhắn:',
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    alert.body,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Giải thích từ Justful:',
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alert.explanation,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Đóng',
                style: GoogleFonts.beVietnamPro(
                  fontWeight: FontWeight.bold,
                  color: AppColors.shieldTeal,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
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

              if (HomeDashboardScreen.showSmsSimulator) ...[
                // ── SMS Simulator Card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.shieldTeal.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.sms_rounded, color: AppColors.shieldTeal, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Giả lập nhận SMS (Kiểm thử Web)',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _senderController,
                        decoration: InputDecoration(
                          labelText: 'Tên người gửi / Số điện thoại',
                          hintText: 'Ví dụ: NHANHANG-SHB hoặc +84912345678',
                          labelStyle: GoogleFonts.beVietnamPro(fontSize: 14),
                          hintStyle: GoogleFonts.beVietnamPro(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        style: GoogleFonts.beVietnamPro(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bodyController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Nội dung tin nhắn',
                          hintText: 'Ví dụ: Tai khoan cua ban bi khoa. Vui long dang nhap...',
                          labelStyle: GoogleFonts.beVietnamPro(fontSize: 14),
                          hintStyle: GoogleFonts.beVietnamPro(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        style: GoogleFonts.beVietnamPro(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSimulating ? null : () async {
                            final sender = _senderController.text.trim();
                            final body = _bodyController.text.trim();
                            if (sender.isEmpty || body.isEmpty) return;
                            
                            setState(() { _isSimulating = true; });
                            
                            // Trigger processing SMS
                            await SmsDetectionService.processSms(sender, body);
                            
                            // Reload list
                            await _loadAlerts();
                            
                            setState(() { _isSimulating = false; });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.shieldTeal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSimulating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'Giả lập nhận tin nhắn',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

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
                            Expanded(
                              child: _ActionChip(
                                icon: Icons.camera_alt_rounded,
                                label: 'Ảnh',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ActionChip(
                                icon: Icons.mic_rounded,
                                label: 'Ghi âm',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ActionChip(
                                icon: Icons.text_fields_rounded,
                                label: 'Văn bản',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
              ),
              const SizedBox(height: 28),

              // ── Automatic SMS Spam Alerts ──
              Text(
                'Tin nhắn rác đã cảnh báo',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.shieldTeal),
                )
              else if (_alerts.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.alertGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.alertGreen.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          color: AppColors.alertGreen, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Thiết bị an toàn! Chưa phát hiện tin nhắn lừa đảo nào.',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.alertGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._alerts.map((alert) {
                  final isCritical = alert.riskLevel == 'critical';
                  final accentColor = isCritical ? AppColors.alertRed : AppColors.alertOrange;
                  final timeStr = DateFormat('HH:mm, dd/MM').format(alert.timestamp);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _showAlertDetails(alert),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border(left: BorderSide(color: accentColor, width: 4)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.sms_failed_rounded, size: 28, color: accentColor),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alert.sender,
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    alert.body,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Phát hiện lúc $timeStr',
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.info_outline_rounded,
                              size: 24,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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
