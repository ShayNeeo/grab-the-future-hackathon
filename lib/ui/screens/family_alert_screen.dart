import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart' show Share;
import 'package:scamshield/core/theme/app_colors.dart';
import 'package:scamshield/src/models/analysis_response.dart';
import 'package:scamshield/src/models/family_alert_response.dart';
import 'package:scamshield/src/providers/family_alert_provider.dart';
import 'package:scamshield/ui/widgets/shield_button.dart';

class FamilyAlertScreen extends ConsumerStatefulWidget {
  const FamilyAlertScreen({super.key, required this.analysis});

  final AnalysisResponse analysis;

  @override
  ConsumerState<FamilyAlertScreen> createState() => _FamilyAlertScreenState();
}

class _FamilyAlertScreenState extends ConsumerState<FamilyAlertScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(familyAlertProvider.notifier).generate(widget.analysis);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyAlertProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        title: Text(
          'Cảnh báo gia đình',
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
        child: state.when(
          loading: () => const _LoadingView(),
          error: (e, _) => _ErrorView(
            onRetry: () => ref
                .read(familyAlertProvider.notifier)
                .generate(widget.analysis),
          ),
          data: (alert) {
            if (alert == null) return const _LoadingView();
            return _AlertBody(alert: alert);
          },
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.shieldTeal),
          const SizedBox(height: 20),
          Text(
            'AI đang soạn cảnh báo\ncho người thân...',
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Không thể kết nối.\nVui lòng thử lại.',
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                fontSize: 18,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ShieldButton(label: 'Thử lại', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _AlertBody extends StatelessWidget {
  const _AlertBody({required this.alert});

  final FamilyAlertResponse alert;

  Color get _headerColor {
    switch (alert.riskLevel) {
      case RiskLevel.critical:
        return AppColors.alertRed;
      case RiskLevel.high:
        return AppColors.alertOrange;
      case RiskLevel.medium:
        return AppColors.alertAmber;
      case RiskLevel.low:
        return AppColors.alertGreen;
    }
  }

  String get _riskLabel {
    switch (alert.riskLevel) {
      case RiskLevel.critical:
        return 'RỦI RO RẤT CAO';
      case RiskLevel.high:
        return 'RỦI RO CAO';
      case RiskLevel.medium:
        return 'RỦI RO TRUNG BÌNH';
      case RiskLevel.low:
        return 'THẤP';
    }
  }

  void _share(BuildContext context) {
    final risksText =
        alert.mainRisks.map((r) => '  • $r').join('\n');
    final actionsText =
        alert.immediateActions.map((a) => '  • $a').join('\n');

    final text = '''
[ScamShield] CẢNH BÁO GIA ĐÌNH — $_riskLabel

${alert.situationSummary}

Dấu hiệu chính:
$risksText

Cách can thiệp:
❌ Không nói: "${alert.doNotSay}"
✅ Nên nói: "${alert.doSay}"

Việc cần làm ngay:
$actionsText

— ScamShield · Lá Chắn Lừa Đảo
''';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Header Banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _headerColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.family_restroom_rounded,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'Cảnh báo gia đình',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _riskLabel,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  alert.situationSummary,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Main Risks ──
          _SectionCard(
            title: 'Dấu hiệu chính',
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.alertOrange,
            child: Column(
              children: alert.mainRisks
                  .map((r) => _BulletRow(text: r, color: AppColors.alertOrange))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),

          // ── Intervention Script ──
          _SectionCard(
            title: 'Cách can thiệp',
            icon: Icons.record_voice_over_rounded,
            iconColor: AppColors.shieldTeal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Do NOT say
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.alertRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.alertRed.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cancel_outlined,
                              color: AppColors.alertRed, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Không nên nói:',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.alertRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"${alert.doNotSay}"',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // DO say
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.alertGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.alertGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              color: AppColors.alertGreen, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Nên nói:',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.alertGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"${alert.doSay}"',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.shieldTealBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded,
                          color: AppColors.shieldTeal, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI giúp can thiệp không đối đầu — người thân dễ lắng nghe hơn khi cảm thấy được tôn trọng.',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 13,
                            color: AppColors.shieldTeal,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Immediate Actions ──
          _SectionCard(
            title: 'Việc cần làm ngay',
            icon: Icons.bolt_rounded,
            iconColor: AppColors.shieldTeal,
            child: Column(
              children: alert.immediateActions
                  .map((a) =>
                      _BulletRow(text: a, color: AppColors.shieldTeal, icon: Icons.check_circle_outline_rounded))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          // ── Share Button ──
          ShieldButton(
            label: '📤 Chia sẻ cảnh báo này',
            onPressed: () => _share(context),
            backgroundColor: AppColors.shieldTeal,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({
    required this.text,
    required this.color,
    this.icon,
  });

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              icon ?? Icons.fiber_manual_record_rounded,
              size: icon != null ? 20 : 12,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
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
    );
  }
}
