import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scamshield/core/theme/app_colors.dart';
import 'package:scamshield/ui/widgets/shield_button.dart';

class CoolingOffTimerScreen extends StatefulWidget {
  const CoolingOffTimerScreen({super.key});

  @override
  State<CoolingOffTimerScreen> createState() => _CoolingOffTimerScreenState();
}

class _CoolingOffTimerScreenState extends State<CoolingOffTimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringController;
  Duration _remaining = const Duration(hours: 47, minutes: 23, seconds: 15);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds > 0) {
        setState(() {
          _remaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _ringController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        _remaining.inSeconds / const Duration(hours: 48).inSeconds;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.shieldTealBg,
              AppColors.surfaceWhite,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
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
                const SizedBox(height: 16),

                // Shield with hourglass icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.shieldTeal.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    size: 52,
                    color: AppColors.shieldTeal,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Đang trong giai đoạn suy nghĩ',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Đừng ký hoặc chuyển tiền\ntrong thời gian này',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // ── Countdown Ring ──
                AnimatedBuilder(
                  animation: _ringController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(200, 200),
                      painter: _CountdownRingPainter(
                        progress: progress,
                        rotationAngle: _ringController.value * 2 * pi,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Timer text overlay - positioned on top of ring
                Transform.translate(
                  offset: const Offset(0, -130),
                  child: Column(
                    children: [
                      Text(
                        _formatDuration(_remaining),
                        style: GoogleFonts.nunito(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppColors.shieldTeal,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'giờ : phút : giây',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Reason Card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tại sao cần chờ?',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ReasonBullet(
                        text: 'Kẻ lừa đảo thường tạo áp lực để bạn quyết định nhanh',
                      ),
                      _ReasonBullet(
                        text: '48 giờ đủ để tham khảo ý kiến người thân',
                      ),
                      _ReasonBullet(
                        text: 'Giao dịch thật sẽ luôn cho bạn thời gian suy nghĩ',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Bottom CTAs ──
                ShieldButton(
                  label: '📞 Gọi cho gia đình ngay',
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                ShieldButton(
                  label: 'Chia sẻ cảnh báo này',
                  onPressed: () {},
                  isOutlined: true,
                ),
                const SizedBox(height: 16),
                Text(
                  'Bộ đếm sẽ nhắc bạn khi hết giờ',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownRingPainter extends CustomPainter {
  final double progress;
  final double rotationAngle;

  _CountdownRingPainter({
    required this.progress,
    required this.rotationAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Track (light gray)
    final trackPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc (teal)
    final progressPaint = Paint()
      ..color = AppColors.shieldTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Rotating accent arc
    final accentPaint = Paint()
      ..color = AppColors.shieldTealLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 14),
      rotationAngle,
      pi / 4,
      false,
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CountdownRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.rotationAngle != rotationAngle;
}

class _ReasonBullet extends StatelessWidget {
  final String text;

  const _ReasonBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 22,
            color: AppColors.shieldTeal,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
