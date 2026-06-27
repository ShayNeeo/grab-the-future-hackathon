import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:justful/core/theme/app_colors.dart';
import 'package:justful/src/providers/cooling_off_provider.dart';
import 'package:justful/ui/widgets/shield_button.dart';

class CoolingOffTimerScreen extends ConsumerStatefulWidget {
  const CoolingOffTimerScreen({super.key});

  @override
  ConsumerState<CoolingOffTimerScreen> createState() =>
      _CoolingOffTimerScreenState();
}

class _CoolingOffTimerScreenState extends ConsumerState<CoolingOffTimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
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
    final notifier = ref.read(coolingOffProvider.notifier);
    // Watch so UI rebuilds when provider changes (start/cancel)
    ref.watch(coolingOffProvider);

    final isActive = notifier.isActive;
    final remaining = notifier.remaining;
    final totalSeconds = const Duration(hours: 48).inSeconds;
    final progress =
        isActive ? remaining.inSeconds / totalSeconds : 0.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.shieldTealBg, AppColors.surfaceWhite],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
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
                              borderRadius: BorderRadius.circular(14))),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.shieldTeal.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.hourglass_top_rounded,
                      size: 52, color: AppColors.shieldTeal),
                ),
                const SizedBox(height: 24),
                Text(
                  isActive
                      ? 'Đang trong giai đoạn suy nghĩ'
                      : 'Chưa bắt đầu giai đoạn suy nghĩ',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  isActive
                      ? 'Đừng ký hoặc chuyển tiền\ntrong thời gian này'
                      : 'Bấm bên dưới để bắt đầu đếm 48 giờ suy nghĩ',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.5),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _ringController,
                  builder: (context, child) => CustomPaint(
                    size: const Size(200, 200),
                    painter: _CountdownRingPainter(
                      progress: progress,
                      rotationAngle: _ringController.value * 2 * pi,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -130),
                  child: Column(
                    children: [
                      Text(
                        isActive ? _formatDuration(remaining) : '48:00:00',
                        style: GoogleFonts.beVietnamPro(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: AppColors.shieldTeal,
                            letterSpacing: 2),
                      ),
                      const SizedBox(height: 4),
                      Text('giờ : phút : giây',
                          style: GoogleFonts.beVietnamPro(
                              fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tại sao cần chờ?',
                          style: GoogleFonts.beVietnamPro(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      _ReasonBullet(
                          text:
                              'Kẻ lừa đảo thường tạo áp lực để bạn quyết định nhanh'),
                      _ReasonBullet(
                          text:
                              '48 giờ đủ để tham khảo ý kiến người thân'),
                      _ReasonBullet(
                          text:
                              'Giao dịch thật sẽ luôn cho bạn thời gian suy nghĩ'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                if (!isActive)
                  ShieldButton(
                    label: '⏱ Bắt đầu 48 giờ suy nghĩ',
                    onPressed: () =>
                        ref.read(coolingOffProvider.notifier).start(),
                  )
                else ...[
                  ShieldButton(
                    label: '📞 Gọi cho gia đình ngay',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  ShieldButton(
                    label: 'Chia sẻ cảnh báo này',
                    onPressed: () => Share.share(
                      'Justful cảnh báo: Tôi đang trong giai đoạn suy nghĩ 48 giờ và sẽ không ký hoặc chuyển tiền. Hãy liên hệ nếu bạn muốn biết thêm.',
                      subject: 'Justful — Cảnh báo lừa đảo',
                    ),
                    isOutlined: true,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        ref.read(coolingOffProvider.notifier).cancel(),
                    child: Text('Tôi đã an toàn, hủy timer',
                        style: GoogleFonts.beVietnamPro(
                            color: AppColors.textSecondary)),
                  ),
                ],
                const SizedBox(height: 16),
                if (isActive)
                  Text(
                    'Bộ đếm sẽ nhắc bạn khi hết giờ',
                    style: GoogleFonts.beVietnamPro(
                        fontSize: 14, color: AppColors.textSecondary),
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

  _CountdownRingPainter(
      {required this.progress, required this.rotationAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = AppColors.divider
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round);

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = AppColors.shieldTeal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round);

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 14),
        rotationAngle,
        pi / 4,
        false,
        Paint()
          ..color = AppColors.shieldTealLight
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _CountdownRingPainter old) =>
      old.progress != progress || old.rotationAngle != rotationAngle;
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
          const Icon(Icons.check_circle_rounded,
              size: 22, color: AppColors.shieldTeal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: GoogleFonts.beVietnamPro(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}
