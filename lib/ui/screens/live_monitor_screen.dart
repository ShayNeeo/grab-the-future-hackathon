import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:justful/core/constants/app_constants.dart';
import 'package:justful/core/theme/app_colors.dart';
import 'package:justful/ui/widgets/bottom_nav_shell.dart';

class LiveMonitorScreen extends StatefulWidget {
  const LiveMonitorScreen({super.key});

  @override
  State<LiveMonitorScreen> createState() => _LiveMonitorScreenState();
}

class _LiveMonitorScreenState extends State<LiveMonitorScreen>
    with TickerProviderStateMixin {
  bool _isMonitoring = false;
  bool _isConnecting = false;
  WebSocketChannel? _channel;
  final List<_MonitorEvent> _events = [];
  String _currentTranscript = '';
  String _riskLevel = '';
  final ScrollController _scrollController = ScrollController();
  AnimationController? _pulseController;
  StreamSubscription? _wsSubscription;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _stopMonitoring();
    _pulseController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startMonitoring() async {
    setState(() {
      _isConnecting = true;
      _events.clear();
      _currentTranscript = '';
      _riskLevel = '';
    });

    try {
      final wsUrl = AppConstants.apiBaseUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://');
      _channel = WebSocketChannel.connect(
        Uri.parse('$wsUrl/live-monitor'),
      );

      await _channel!.ready;

      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _isMonitoring = true;
      });
      _pulseController?.repeat();

      _wsSubscription = _channel!.stream.listen(
        (message) {
          if (!mounted) return;
          try {
            final data = jsonDecode(message as String);
            _handleServerMessage(data);
          } catch (e) {
            debugPrint('Live monitor message parse error: $e');
          }
        },
        onError: (error) {
          debugPrint('Live monitor WebSocket error: $error');
          if (mounted) {
            _addEvent('error', 'Kết nối bị gián đoạn');
            _stopMonitoring();
          }
        },
        onDone: () {
          if (mounted && _isMonitoring) {
            _addEvent('info', 'Kết nối đã đóng');
            _stopMonitoring();
          }
        },
      );

      _addEvent('info', 'Đã kết nối — bắt đầu giám sát cuộc gọi');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _isMonitoring = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể kết nối: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _handleServerMessage(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';

    switch (type) {
      case 'transcript':
        setState(() {
          _currentTranscript = data['text'] as String? ?? '';
        });
      case 'analysis':
        final risk = data['risk_level'] as String? ?? '';
        final explanation = data['explanation'] as String? ?? '';
        final redFlags = data['red_flags'] as List<dynamic>? ?? [];
        setState(() {
          _riskLevel = risk;
        });
        if (risk.isNotEmpty && risk != 'low') {
          _addEvent(
            risk == 'critical' || risk == 'high' ? 'danger' : 'warning',
            explanation.isNotEmpty ? explanation : 'Phát hiện dấu hiệu rủi ro',
          );
        }
        if (redFlags.isNotEmpty) {
          for (final flag in redFlags) {
            _addEvent('flag', flag['detail'] as String? ?? '');
          }
        }
      case 'error':
        _addEvent('error', data['message'] as String? ?? 'Lỗi không xác định');
      case 'status':
        _addEvent('info', data['message'] as String? ?? '');
    }

    _scrollToBottom();
  }

  void _addEvent(String type, String message) {
    if (message.isEmpty) return;
    setState(() {
      _events.add(_MonitorEvent(
        type: type,
        message: message,
        time: DateTime.now(),
      ));
    });
  }

  void _stopMonitoring() {
    _pulseController?.stop();
    _wsSubscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    if (mounted) {
      setState(() {
        _isMonitoring = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _riskColor(String risk) {
    switch (risk) {
      case 'critical':
        return AppColors.alertRed;
      case 'high':
        return AppColors.alertRed;
      case 'medium':
        return AppColors.alertAmber;
      case 'low':
        return AppColors.alertGreen;
      default:
        return AppColors.shieldTeal;
    }
  }

  IconData _eventIcon(String type) {
    switch (type) {
      case 'danger':
        return Icons.dangerous_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'flag':
        return Icons.flag_rounded;
      case 'error':
        return Icons.error_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _eventColor(String type) {
    switch (type) {
      case 'danger':
        return AppColors.alertRed;
      case 'warning':
        return AppColors.alertAmber;
      case 'flag':
        return AppColors.alertAmber;
      case 'error':
        return AppColors.alertRed;
      default:
        return AppColors.shieldTeal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavShell(
      currentIndex: 3,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giám sát trực tiếp',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đặt điện thoại loa ngoài — AI sẽ phân tích cuộc gọi real-time',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Status bar
            if (_riskLevel.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: _riskColor(_riskLevel).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _riskColor(_riskLevel).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _riskLevel == 'low'
                          ? Icons.shield_rounded
                          : Icons.warning_amber_rounded,
                      color: _riskColor(_riskLevel),
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _riskLevel == 'low'
                                ? 'An toàn'
                                : _riskLevel == 'medium'
                                    ? 'Cảnh giác'
                                    : _riskLevel == 'high'
                                        ? 'Nguy hiểm'
                                        : 'Cực kỳ nguy hiểm',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _riskColor(_riskLevel),
                            ),
                          ),
                          if (_currentTranscript.isNotEmpty)
                            Text(
                              _currentTranscript.length > 80
                                  ? '${_currentTranscript.substring(0, 80)}...'
                                  : _currentTranscript,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: AppColors.textSecondary,
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

            const SizedBox(height: 16),

            // Events list
            Expanded(
              child: _events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic_external_on_rounded,
                            size: 64,
                            color: AppColors.shieldTeal.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isMonitoring
                                ? 'Đang nghe...'
                                : 'Nhấn nút bên dưới để bắt đầu',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _eventColor(event.type)
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _eventIcon(event.type),
                                color: _eventColor(event.type),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.message,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${event.time.hour}:${event.time.minute.toString().padLeft(2, '0')}:${event.time.second.toString().padLeft(2, '0')}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Control button
            Padding(
              padding: const EdgeInsets.all(24),
              child: GestureDetector(
                onTap: _isConnecting
                    ? null
                    : _isMonitoring
                        ? _stopMonitoring
                        : _startMonitoring,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isMonitoring
                        ? AppColors.alertRed
                        : _isConnecting
                            ? AppColors.alertAmber
                            : AppColors.shieldTeal,
                    boxShadow: [
                      BoxShadow(
                        color: (_isMonitoring
                                ? AppColors.alertRed
                                : AppColors.shieldTeal)
                            .withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: _isMonitoring ? 8 : 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isMonitoring
                        ? Icons.stop_rounded
                        : _isConnecting
                            ? Icons.hourglass_top_rounded
                            : Icons.mic_external_on_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonitorEvent {
  final String type;
  final String message;
  final DateTime time;

  _MonitorEvent({
    required this.type,
    required this.message,
    required this.time,
  });
}
