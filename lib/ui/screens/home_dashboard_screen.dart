import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:justful/core/theme/app_colors.dart';
import 'package:justful/src/models/chat_history_item.dart';
import 'package:justful/src/models/sms_alert.dart';
import 'package:justful/src/services/sms_detection_service.dart';
import 'package:justful/ui/widgets/bottom_nav_shell.dart';
import 'package:justful/ui/widgets/stat_card.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  static const bool showSmsSimulator = false;

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  List<SmsAlert> _smsAlerts = [];
  List<ChatHistoryItem> _chatHistory = [];
  bool _isLoading = true;

  // SMS simulator fields (only used when showSmsSimulator = true)
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isSimulating = false;
  List<String> _debugLog = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    if (HomeDashboardScreen.showSmsSimulator) _loadDebugLog();
  }

  @override
  void dispose() {
    _senderController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load SMS alerts
      final smsList = prefs.getStringList('sms_alerts') ?? [];
      final parsedAlerts = smsList.map((item) {
        return SmsAlert.fromJson(json.decode(item) as Map<String, dynamic>);
      }).toList();

      // Load chat analysis history
      final history = await ChatHistoryItem.load();

      if (mounted) {
        setState(() {
          _smsAlerts = parsedAlerts;
          _chatHistory = history;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDebugLog() async {
    final log = await SmsDebugLog.read();
    if (mounted) setState(() => _debugLog = log);
  }

  // ── Derived stats from real data ──

  int get _totalChecks => _chatHistory.length + _smsAlerts.length;

  int get _scamsFound {
    final chatScams = _chatHistory
        .where((h) => h.riskLevel == 'critical' || h.riskLevel == 'high')
        .length;
    final smsScams = _smsAlerts
        .where((a) => a.riskLevel == 'critical' || a.riskLevel == 'high')
        .length;
    return chatScams + smsScams;
  }

  // Consecutive days ending today with no high/critical risk event
  int get _safeDays {
    final dangerDates = <DateTime>{
      ..._chatHistory
          .where((h) => h.riskLevel == 'critical' || h.riskLevel == 'high')
          .map((h) => DateTime(h.timestamp.year, h.timestamp.month, h.timestamp.day)),
      ..._smsAlerts
          .where((a) => a.riskLevel == 'critical' || a.riskLevel == 'high')
          .map((a) => DateTime(a.timestamp.year, a.timestamp.month, a.timestamp.day)),
    };

    int streak = 0;
    DateTime day = DateTime.now();
    while (true) {
      final d = DateTime(day.year, day.month, day.day);
      if (dangerDates.contains(d)) break;
      streak++;
      // Stop counting at 365 days to avoid infinite loop on fresh installs
      if (streak >= 365) break;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  // ── Recent items: mix latest chat history + SMS alerts, newest first ──
  List<_RecentItem> get _recentItems {
    final items = <_RecentItem>[
      ..._chatHistory.map((h) => _RecentItem.fromChat(h)),
      ..._smsAlerts.map((a) => _RecentItem.fromSms(a)),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items.take(5).toList();
  }

  void _showAlertDetails(SmsAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.alertRed),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Cảnh báo từ ${alert.sender}',
                style: GoogleFonts.plusJakartaSans(
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
              Text('Nội dung tin nhắn:',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(alert.body,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16, color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 16),
              Text('Giải thích từ Justful:',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Text(alert.explanation,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15, color: AppColors.textPrimary)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: AppColors.shieldTeal,
                    fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavShell(
      currentIndex: 0,
      child: RefreshIndicator(
        color: AppColors.shieldTeal,
        onRefresh: _loadData,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 16),
                _buildDailyTip(),
                const SizedBox(height: 20),
                if (HomeDashboardScreen.showSmsSimulator) ...[
                  _buildSmsSimulator(),
                  const SizedBox(height: 16),
                  _buildDebugLog(),
                  const SizedBox(height: 20),
                ],
                _buildCheckNowButton(),
                const SizedBox(height: 20),
                _buildStatCards(),
                const SizedBox(height: 24),
                _buildLiveMonitorCard(),
                const SizedBox(height: 24),
                _buildSmsAlertsSection(),
                const SizedBox(height: 24),
                _buildRecentHistorySection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.shieldTeal, Color(0xFF1A9DAA)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shieldTeal.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting, Bác! 👋',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Justful luôn bảo vệ bác mỗi ngày',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_rounded,
                color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  // ── Daily tip ──
  Widget _buildDailyTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.shieldTealBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.shieldTeal.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.shieldTeal.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb_rounded,
                size: 24, color: AppColors.shieldTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mẹo an toàn hôm nay',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.shieldTeal)),
                const SizedBox(height: 3),
                Text(
                  'Không bao giờ chuyển tiền cho người lạ qua điện thoại — hãy hỏi người thân trước!',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Check now CTA ──
  Widget _buildCheckNowButton() {
    return Semantics(
      label: 'Kiểm tra ngay',
      button: true,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/chat'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.shieldTeal,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.shieldTeal.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3), width: 2),
                ),
                child:
                    const Icon(Icons.shield_rounded, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kiểm tra ngay',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Gửi ảnh, tin nhắn hoặc nói chuyện với AI',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.88))),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stat cards ──
  Widget _buildStatCards() {
    if (_isLoading) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.shieldTeal),
        ),
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatCard(
            icon: Icons.history_rounded,
            value: _totalChecks.toString(),
            label: 'lần kiểm tra',
          ),
          const SizedBox(width: 12),
          StatCard(
            icon: Icons.gpp_bad_rounded,
            value: _scamsFound.toString(),
            label: 'lừa đảo phát hiện',
            accentColor: _scamsFound > 0
                ? AppColors.alertRed
                : AppColors.alertGreen,
          ),
          const SizedBox(width: 12),
          StatCard(
            icon: Icons.verified_user_rounded,
            value: _safeDays.toString(),
            label: 'ngày an toàn',
            accentColor: AppColors.alertGreen,
          ),
        ],
      ),
    );
  }

  // ── Live monitor card ──
  Widget _buildLiveMonitorCard() {
    return Semantics(
      label: 'Giám sát cuộc gọi trực tiếp',
      button: true,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/live-monitor'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.alertRed.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.alertRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic_external_on_rounded,
                    size: 26, color: AppColors.alertRed),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Giám sát cuộc gọi',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Text('Phát hiện lừa đảo real-time khi đang nghe điện thoại',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  // ── SMS alerts section ──
  Widget _buildSmsAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tin nhắn rác đã cảnh báo',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(
              child: CircularProgressIndicator(color: AppColors.shieldTeal))
        else if (_smsAlerts.isEmpty)
          _buildSafeStatusBadge('Thiết bị an toàn! Chưa phát hiện tin nhắn lừa đảo nào.')
        else
          ..._smsAlerts.map((alert) {
            final isCritical = alert.riskLevel == 'critical';
            final accentColor =
                isCritical ? AppColors.alertRed : AppColors.alertOrange;
            final timeStr =
                DateFormat('HH:mm, dd/MM').format(alert.timestamp);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _showAlertDetails(alert),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                        left: BorderSide(color: accentColor, width: 4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sms_failed_rounded,
                          size: 26, color: accentColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alert.sender,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 3),
                            Text(alert.body,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: AppColors.textSecondary)),
                            const SizedBox(height: 3),
                            Text('Phát hiện lúc $timeStr',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.info_outline_rounded,
                          size: 22, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  // ── Recent history section (real data from chat + SMS) ──
  Widget _buildRecentHistorySection() {
    final items = _recentItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lịch sử gần đây',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(
              child: CircularProgressIndicator(color: AppColors.shieldTeal))
        else if (items.isEmpty)
          _buildSafeStatusBadge(
              'Chưa có lịch sử kiểm tra. Hãy gửi tin nhắn nghi ngờ để bắt đầu!')
        else
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RecentItemCard(item: item),
              )),
      ],
    );
  }

  Widget _buildSafeStatusBadge(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.alertGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.alertGreen.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: AppColors.alertGreen, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.alertGreen)),
          ),
        ],
      ),
    );
  }

  // ── SMS Simulator (dev only) ──
  Widget _buildSmsSimulator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.shieldTeal.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.sms_rounded, color: AppColors.shieldTeal, size: 22),
            const SizedBox(width: 8),
            Text('Giả lập nhận SMS',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 14),
          TextField(
            controller: _senderController,
            decoration: InputDecoration(
              labelText: 'Người gửi',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _bodyController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Nội dung tin nhắn',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSimulating
                  ? null
                  : () async {
                      final sender = _senderController.text.trim();
                      final body = _bodyController.text.trim();
                      if (sender.isEmpty || body.isEmpty) return;
                      setState(() => _isSimulating = true);
                      await SmsDetectionService.processSms(sender, body);
                      await _loadData();
                      setState(() => _isSimulating = false);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.shieldTeal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSimulating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text('Giả lập nhận tin nhắn',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugLog() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.bug_report, color: Color(0xFF4FFFB0), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Nhật ký SMS',
                  style: GoogleFonts.robotoMono(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4FFFB0))),
            ),
            IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70, size: 18),
                onPressed: _loadDebugLog),
            IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.white70, size: 18),
                onPressed: () async {
                  await SmsDebugLog.clear();
                  await _loadDebugLog();
                }),
          ]),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _debugLog.isEmpty
                ? Text('(chưa có nhật ký)',
                    style: GoogleFonts.robotoMono(
                        fontSize: 11, color: Colors.white38))
                : ListView.builder(
                    itemCount: _debugLog.length,
                    itemBuilder: (_, i) => Text(
                      _debugLog[i],
                      style: GoogleFonts.robotoMono(
                        fontSize: 11,
                        color: _debugLog[i].contains('ERROR') ||
                                _debugLog[i].contains('DENIED')
                            ? const Color(0xFFFF6B6B)
                            : _debugLog[i].contains('INCOMING') ||
                                    _debugLog[i].contains('CẢNH BÁO')
                                ? const Color(0xFF4FFFB0)
                                : Colors.white70,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Data model merging chat history + SMS alerts ──
class _RecentItem {
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final Color accentColor;
  final IconData icon;
  final String source; // 'chat' | 'sms'

  const _RecentItem({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.accentColor,
    required this.icon,
    required this.source,
  });

  factory _RecentItem.fromChat(ChatHistoryItem item) {
    final color = _riskColor(item.riskLevel);
    final icon = _riskIcon(item.riskLevel);
    final label = _riskLabel(item.riskLevel);
    final timeAgo = _timeAgo(item.timestamp);
    return _RecentItem(
      title: item.caseType.isNotEmpty
          ? _translateCaseType(item.caseType)
          : 'Phân tích AI',
      subtitle: '$label · $timeAgo',
      timestamp: item.timestamp,
      accentColor: color,
      icon: icon,
      source: 'chat',
    );
  }

  factory _RecentItem.fromSms(SmsAlert item) {
    final color = _riskColor(item.riskLevel);
    const icon = Icons.sms_failed_rounded;
    final label = _riskLabel(item.riskLevel);
    final timeAgo = _timeAgo(item.timestamp);
    return _RecentItem(
      title: item.sender,
      subtitle: '$label · $timeAgo',
      timestamp: item.timestamp,
      accentColor: color,
      icon: icon,
      source: 'sms',
    );
  }

  static Color _riskColor(String level) {
    switch (level) {
      case 'critical':
        return AppColors.alertRed;
      case 'high':
        return AppColors.alertOrange;
      case 'medium':
        return AppColors.alertAmber;
      default:
        return AppColors.alertGreen;
    }
  }

  static IconData _riskIcon(String level) {
    switch (level) {
      case 'critical':
      case 'high':
        return Icons.warning_amber_rounded;
      case 'medium':
        return Icons.info_outline_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  static String _riskLabel(String level) {
    switch (level) {
      case 'critical':
        return 'Rủi ro rất cao';
      case 'high':
        return 'Rủi ro cao';
      case 'medium':
        return 'Cần chú ý';
      default:
        return 'An toàn';
    }
  }

  static String _translateCaseType(String raw) {
    const map = {
      'investment_scam': 'Lừa đảo đầu tư',
      'lottery_scam': 'Lừa đảo trúng thưởng',
      'romance_scam': 'Lừa đảo tình cảm',
      'phishing': 'Giả mạo tổ chức',
      'tech_support_scam': 'Giả mạo hỗ trợ kỹ thuật',
      'impersonation': 'Giả danh người thân',
      'loan_scam': 'Lừa đảo cho vay',
      'job_scam': 'Lừa đảo việc làm',
      'unknown': 'Nội dung nghi ngờ',
    };
    return map[raw.toLowerCase()] ?? raw;
  }

  static String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }
}

class _RecentItemCard extends StatelessWidget {
  final _RecentItem item;
  const _RecentItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border:
            Border(left: BorderSide(color: item.accentColor, width: 4)),
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 26, color: item.accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(item.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 26, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

