import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:justful/app/routes.dart';
import 'package:justful/core/theme/app_colors.dart';
import 'package:justful/src/providers/chat_provider.dart' as p;
import 'package:justful/src/models/analysis_response.dart';
import 'package:justful/ui/widgets/bottom_nav_shell.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  String? _pendingImageBase64;
  
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  String _transcribedWords = '';
  bool _useVoiceMode = true;

  static const _greeting = _ChatMessage(
    isAi: true,
    text:
        'Xin chào bà! 🛡️ Bạn nhận được tin nhắn, hình ảnh hay cuộc gọi nào đáng ngờ không? Hãy gửi cho tôi kiểm tra nhé.',
    time: '',
  );

  Future<void> _pickImage(ImageSource source) async {
    final xFile = await _picker.pickImage(
        source: source, imageQuality: 70, maxWidth: 1024);
    if (xFile == null) return;
    final bytes = await File(xFile.path).readAsBytes();
    setState(() => _pendingImageBase64 = base64Encode(bytes));
  }

  Future<void> _initSpeech() async {
    if (_speechAvailable) return;
    try {
      final available = await _speech.initialize(
        onError: (val) {
          debugPrint('Speech error: $val');
          if (!mounted) return;
          setState(() => _isListening = false);
        },
        onStatus: (val) {
          debugPrint('Speech status: $val');
          if (val == 'done' || val == 'notListening') {
            if (!mounted) return;
            setState(() => _isListening = false);
          }
        },
      );
      if (!mounted) return;
      setState(() {
        _speechAvailable = available;
      });
    } catch (e) {
      debugPrint('Speech initialization failed: $e');
    }
  }

  void _startListening() async {
    await _initSpeech();
    if (!mounted) return;
    if (_speechAvailable) {
      setState(() {
        _isListening = true;
        _transcribedWords = '';
      });
      
      try {
        await _speech.listen(
          onResult: (val) {
            if (!mounted) return;
            setState(() {
              _transcribedWords = val.recognizedWords;
            });
          },
          localeId: 'vi_VN',
        );
      } catch (e) {
        debugPrint('Speech listen error: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể kích hoạt chức năng giọng nói. Vui lòng cấp quyền micro.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _stopListening() async {
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('Speech stop error: $e');
    }
    setState(() => _isListening = false);
  }



  void _sendMessage([String? overrideText]) {
    final text = overrideText ?? _messageController.text.trim();
    if (text.isEmpty && _pendingImageBase64 == null) return;
    ref.read(p.chatProvider.notifier).send(
          text: text.isEmpty ? '[Ảnh đính kèm]' : text,
          imageBase64: _pendingImageBase64,
        );
    _messageController.clear();
    setState(() => _pendingImageBase64 = null);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _speech.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<_ChatMessage> _buildDisplayMessages(
      AsyncValue<List<p.ChatMessage>> state) {
    final now = TimeOfDay.now();
    final timeStr =
        '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    final providerMsgs = state.valueOrNull ?? [];
    final display = <_ChatMessage>[
      _greeting,
      ...providerMsgs.map((m) => _ChatMessage(
            isAi: m.role == 'assistant',
            text: m.text,
            time: timeStr,
            isImage: m.imageBase64 != null && m.role == 'user',
            imageName: 'Ảnh đính kèm',
            followUpQuestions: m.followUpQuestions,
            isStreaming: m.isStreaming,
            thinkingText: m.thinkingText,
            response: m.response,
          )),
    ];

    if (state.isLoading) {
      display.add(const _ChatMessage(
        isAi: true,
        text: 'Đang kiểm tra dấu hiệu lừa đảo...',
        time: '',
        isAnalyzing: true,
      ));
    }

    if (state.hasError) {
      display.add(const _ChatMessage(
        isAi: true,
        text: '⚠️ Không thể kết nối. Vui lòng thử lại.',
        time: '',
      ));
    }

    return display;
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(p.chatProvider);

    ref.listen<AsyncValue<List<p.ChatMessage>>>(p.chatProvider, (prev, next) {
      if (prev?.isLoading == true && next.hasValue) {
        final msgs = next.value!;
        if (msgs.isNotEmpty && msgs.last.response != null) {
          // Only navigate to result card when there are NO follow-up questions
          // (i.e., the agentic loop is complete)
          if (msgs.last.followUpQuestions.isEmpty) {
            Navigator.pushNamed(
              context,
              AppRoutes.scamResult,
              arguments: msgs.last.response,
            );
          }
          _scrollToBottom();
        }
      }
    });

    final messages = _buildDisplayMessages(chatState);

    return BottomNavShell(
      currentIndex: 1,
      child: Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceWhite,
          elevation: 0,
          leading: SizedBox(
            width: 56,
            height: 56,
            child: IconButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              icon: const Icon(Icons.arrow_back_rounded, size: 26),
              tooltip: 'Quay lại Trang chủ',
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    color: AppColors.shieldTeal, shape: BoxShape.circle),
                child: const Icon(Icons.shield_rounded,
                    size: 22, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Justful AI',
                      style: GoogleFonts.beVietnamPro(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.alertGreen,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text('Đang hoạt động',
                          style: GoogleFonts.beVietnamPro(
                              fontSize: 13, color: AppColors.alertGreen)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            SizedBox(
              width: 56,
              height: 56,
              child: IconButton(
                onPressed: () => ref.read(p.chatProvider.notifier).reset(),
                icon: const Icon(Icons.refresh_rounded, size: 26),
                tooltip: 'Bắt đầu cuộc trò chuyện mới',

                style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.divider),
          ),
        ),
        body: Column(
          children: [
            _buildModeSwitcher(),
            Expanded(
              child: _useVoiceMode
                  ? _buildVoiceModeView()
                  : (messages.length <= 1
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) =>
                              _buildMessageBubble(messages[index]),
                        )),
            ),
            if (!_useVoiceMode) _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    if (msg.isImage) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.shieldTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.shieldTeal.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_rounded,
                          size: 48,
                          color: AppColors.shieldTeal.withValues(alpha: 0.6)),
                      const SizedBox(height: 8),
                      Text('📎 ${msg.imageName}',
                          style: GoogleFonts.beVietnamPro(
                              fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.shieldTeal.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(width: 8),
                    Text('Đang phân tích...',
                        style: GoogleFonts.beVietnamPro(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: AppColors.shieldTeal)),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (msg.isAnalyzing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _aiAvatar(),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      3,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.shieldTeal
                              .withValues(alpha: 0.4 + (i * 0.2)),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(msg.text,
                      style: GoogleFonts.beVietnamPro(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: AppColors.shieldTeal)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (msg.isAi) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _aiAvatar(),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(18)),
                      ),
                      child: Text(msg.text,
                          style: GoogleFonts.beVietnamPro(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPrimary)),
                    ),
                  if (msg.isStreaming) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.shieldTeal.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.shieldTeal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _getFriendlyThinkingStatus(msg.thinkingText),
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.shieldTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (msg.response != null && msg.response!.suggestedReply.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final isBlockAdvice = msg.response!.suggestedReply.contains('Chặn');
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isBlockAdvice ? AppColors.redTint : AppColors.shieldTealBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isBlockAdvice 
                                  ? AppColors.alertRed.withValues(alpha: 0.25)
                                  : AppColors.shieldTeal.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isBlockAdvice ? Icons.gpp_bad_rounded : Icons.lightbulb_outline_rounded,
                                    size: 20, 
                                    color: isBlockAdvice ? AppColors.alertRed : AppColors.shieldTeal
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isBlockAdvice ? 'Khuyên dùng an toàn:' : 'Gợi ý trả lời đối phương:',
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isBlockAdvice ? AppColors.alertRed : AppColors.shieldTeal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isBlockAdvice ? 'Bác nên: ${msg.response!.suggestedReply}' : '"${msg.response!.suggestedReply}"',
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: isBlockAdvice ? FontStyle.normal : FontStyle.italic,
                                  color: isBlockAdvice ? AppColors.alertRed : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    ),
                  ],
                  if (msg.followUpQuestions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildFollowUpChips(msg.followUpQuestions),
                  ],
                  if (msg.time.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(msg.time,
                        style: GoogleFonts.beVietnamPro(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    // User bubble (right)
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.shieldTeal,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(4),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18)),
                  ),
                  child: Text(msg.text,
                      style: GoogleFonts.beVietnamPro(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white)),
                ),
                if (msg.time.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(msg.time,
                      style: GoogleFonts.beVietnamPro(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiAvatar() => Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
            color: AppColors.shieldTeal, shape: BoxShape.circle),
        child: const Icon(Icons.shield_rounded, size: 16, color: Colors.white),
      );

  String _getFriendlyThinkingStatus(String thinkingText) {
    final text = thinkingText.toLowerCase();
    if (text.contains('intake') || text.contains('trích xuất')) {
      return 'Kính chào bác! AI đang tiếp nhận tin nhắn...';
    } else if (text.contains('red_flag') || text.contains('red flag') || text.contains('dấu hiệu')) {
      return 'AI đang đối chiếu các dấu hiệu lừa đảo phổ biến...';
    } else if (text.contains('pressure') || text.contains('manipulation') || text.contains('thao túng')) {
      return 'AI đang kiểm tra các chiến thuật tâm lý của đối phương...';
    } else if (text.contains('contract') || text.contains('hợp đồng') || text.contains('điều khoản')) {
      return 'AI đang quét chi tiết các điều khoản hợp đồng/tài liệu...';
    }
    return 'Lá chắn Justful đang kiểm tra độ an toàn cho bác...';
  }

  /// Renders follow-up questions as tappable suggestion chips.
  /// Tapping a chip sends it as the user's next message in the agentic loop.
  Widget _buildFollowUpChips(List<String> questions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.help_outline_rounded,
                  size: 16,
                  color: AppColors.shieldTeal.withValues(alpha: 0.7)),
              const SizedBox(width: 4),
              Text(
                'Cho tôi biết thêm:',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.shieldTeal.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: questions.map((q) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _sendMessage(q),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.shieldTealBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.shieldTeal.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    q,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.shieldTeal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModeSwitcher() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: 'Chế độ Nói chuyện bằng giọng nói',
              button: true,
              selected: _useVoiceMode,
              child: InkWell(
                onTap: () {
                  if (!_useVoiceMode) {
                    setState(() {
                      _useVoiceMode = true;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _useVoiceMode ? AppColors.shieldTeal : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mic_rounded,
                        color: _useVoiceMode ? Colors.white : AppColors.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nói chuyện',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _useVoiceMode ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Semantics(
              label: 'Chế độ Nhắn tin văn bản',
              button: true,
              selected: !_useVoiceMode,
              child: InkWell(
                onTap: () {
                  if (_useVoiceMode) {
                    setState(() {
                      _useVoiceMode = false;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: !_useVoiceMode ? AppColors.shieldTeal : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.keyboard_rounded,
                        color: !_useVoiceMode ? Colors.white : AppColors.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nhắn tin',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: !_useVoiceMode ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceModeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Friendly large prompt box for the elderly
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.shieldTealBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.shieldTeal.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chào bà,',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.shieldTeal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bà hãy nhấn nút tròn to ở giữa màn hình rồi đọc tin nhắn hoặc kể lại sự việc nghi ngờ lừa đảo. Con sẽ kiểm tra ngay giúp bà!',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Large Centered Voice Button
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_isListening) {
                      _stopListening();
                    } else {
                      _startListening();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shieldTeal.withValues(
                            alpha: _isListening ? 0.4 : 0.2,
                          ),
                          blurRadius: _isListening ? 24 : 12,
                          spreadRadius: _isListening ? 6 : 2,
                        )
                      ],
                    ),
                    child: _isListening
                        ? const _SpeechPulseAnimation()
                        : Container(
                            decoration: const BoxDecoration(
                              color: AppColors.shieldTeal,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.mic_rounded,
                              color: Colors.white,
                              size: 72,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isListening ? 'Đang lắng nghe... Chạm để Dừng' : 'Chạm vào để Nói',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isListening ? Colors.redAccent : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          // Preview transcribed text area
          Text(
            'Nội dung nhận diện giọng nói:',
            style: GoogleFonts.beVietnamPro(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isListening
                    ? AppColors.shieldTeal.withValues(alpha: 0.4)
                    : AppColors.divider,
                width: 1.5,
              ),
            ),
            child: Text(
              _transcribedWords.isEmpty
                  ? (_isListening ? 'Bà hãy nói đi, con đang nghe...' : 'Giọng nói của bà sẽ xuất hiện ở đây...')
                  : _transcribedWords,
              style: GoogleFonts.beVietnamPro(
                fontSize: 20,
                color: _transcribedWords.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Large clear and send buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: OutlinedButton(
                    onPressed: _transcribedWords.isEmpty
                        ? null
                        : () {
                            setState(() {
                              _transcribedWords = '';
                            });
                          },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _transcribedWords.isEmpty
                            ? AppColors.divider
                            : AppColors.textSecondary,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Xóa nói lại',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _transcribedWords.isEmpty
                            ? AppColors.textSecondary.withValues(alpha: 0.5)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _transcribedWords.trim().isEmpty
                        ? null
                        : () {
                            final speechText = _transcribedWords;
                            setState(() {
                              _transcribedWords = '';
                              _useVoiceMode = false;
                            });
                            _sendMessage(speechText);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.shieldTeal,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: AppColors.shieldTeal.withValues(alpha: 0.3),
                    ),
                    child: Text(
                      'Gửi kiểm tra',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Friendly shield illustration
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.shieldTealBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.shieldTeal.withValues(alpha: 0.2),
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.shield_rounded,
                size: 52,
                color: AppColors.shieldTeal,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chào bạn! Tôi ở đây để giúp',
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Gửi tin nhắn, ảnh chụp hoặc ghi âm\ntôi sẽ kiểm tra giúp bạn ngay',
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Quick suggestion chips
            _SuggestionChip(
              icon: Icons.message_rounded,
              label: 'Kiểm tra tin nhắn',
              onTap: () {
                _messageController.text = 'Tôi nhận được tin nhắn lạ, hãy kiểm tra giúp tôi';
              },
            ),
            const SizedBox(height: 12),
            _SuggestionChip(
              icon: Icons.description_rounded,
              label: 'Phân tích hợp đồng',
              onTap: () {
                _messageController.text = 'Tôi cần phân tích một hợp đồng';
              },
            ),
            const SizedBox(height: 12),
            _SuggestionChip(
              icon: Icons.phone_in_talk_rounded,
              label: 'Cuộc gọi đáng ngờ',
              onTap: () {
                _messageController.text = 'Tôi nhận cuộc gọi từ số lạ';
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    final chatState = ref.watch(p.chatProvider);
    final isStreaming = (chatState.valueOrNull ?? []).any((m) => m.isStreaming);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_pendingImageBase64 != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.shieldTealBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image_rounded,
                        color: AppColors.shieldTeal, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                        child: Text('Ảnh đã chọn',
                            style: TextStyle(color: AppColors.shieldTeal))),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _pendingImageBase64 = null),
                      child: const Icon(Icons.close,
                          size: 18, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: IconButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded,
                        color: AppColors.shieldTeal, size: 26),
                    tooltip: 'Chụp ảnh',

                    style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                  ),
                ),
                SizedBox(
                  width: 56,
                  height: 56,
                  child: IconButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded,
                        color: AppColors.shieldTeal, size: 26),
                    tooltip: 'Chọn ảnh',

                    style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                  ),
                ),
                SizedBox(
                  width: 56,
                  height: 56,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _useVoiceMode = true;
                      });
                    },
                    icon: const Icon(Icons.mic_rounded,
                        color: AppColors.shieldTeal, size: 26),
                    tooltip: 'Chuyển sang Nói chuyện',

                    style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: GoogleFonts.beVietnamPro(
                          fontSize: 16, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Nhập hoặc dán nội dung...',
                        hintStyle: GoogleFonts.beVietnamPro(
                            fontSize: 16, color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    onPressed: isStreaming ? null : _sendMessage,
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 22),
                    style: IconButton.styleFrom(
                        backgroundColor: isStreaming
                            ? AppColors.shieldTeal.withValues(alpha: 0.4)
                            : AppColors.shieldTeal,
                        shape: const CircleBorder()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final bool isAi;
  final String text;
  final String time;
  final bool isImage;
  final bool isAnalyzing;
  final String? imageName;
  final List<String> followUpQuestions;
  final bool isStreaming;
  final String thinkingText;
  final AnalysisResponse? response;

  const _ChatMessage({
    required this.isAi,
    required this.text,
    required this.time,
    this.isImage = false,
    this.isAnalyzing = false,
    this.imageName,
    this.followUpQuestions = const [],
    this.isStreaming = false,
    this.thinkingText = '',
    this.response,
  });
}

class _SuggestionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.shieldTeal.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.shieldTealBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: AppColors.shieldTeal),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeechPulseAnimation extends StatefulWidget {
  const _SpeechPulseAnimation();

  @override
  State<_SpeechPulseAnimation> createState() => _SpeechPulseAnimationState();
}

class _SpeechPulseAnimationState extends State<_SpeechPulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(3, (index) {
              final scale = 1.0 + (index + 1) * 0.3 * _controller.value;
              final opacity = 0.6 - (index + 1) * 0.15 - (0.3 * _controller.value);
              return Container(
                width: 80 * scale,
                height: 80 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.shieldTeal.withValues(alpha: opacity.clamp(0.0, 1.0)),
                ),
              );
            }),
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.shieldTeal,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ],
        );
      },
    );
  }
}
