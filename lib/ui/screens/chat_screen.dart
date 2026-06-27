import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:justifty/app/routes.dart';
import 'package:justifty/core/theme/app_colors.dart';
import 'package:justifty/src/providers/chat_provider.dart' as p;
import 'package:justifty/ui/widgets/bottom_nav_shell.dart';

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
  String? _initialAction;

  static const _greeting = _ChatMessage(
    isAi: true,
    text:
        'Xin chào Bà Lan! 🛡️ Bạn nhận được tin nhắn, hình ảnh hay cuộc gọi nào đáng ngờ không? Hãy gửi cho tôi kiểm tra nhé.',
    time: '',
  );

  @override
  void initState() {
    super.initState();
    // Handle action from home screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final action = ModalRoute.of(context)?.settings.arguments as String?;
      if (action != null) {
        setState(() => _initialAction = action);
        _handleInitialAction(action);
      }
    });
  }

  void _handleInitialAction(String action) {
    switch (action) {
      case 'camera':
        _pickImage(ImageSource.camera);
        break;
      case 'voice':
        // Focus on text input for now (voice not implemented)
        _messageController.text = '';
        break;
      case 'text':
        // Focus on text input
        FocusScope.of(context).requestFocus(FocusNode());
        break;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final xFile = await _picker.pickImage(
        source: source, imageQuality: 70, maxWidth: 1024);
    if (xFile == null) return;
    final bytes = await File(xFile.path).readAsBytes();
    setState(() => _pendingImageBase64 = base64Encode(bytes));
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
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
          Navigator.pushNamed(
            context,
            AppRoutes.scamResult,
            arguments: msgs.last.response,
          );
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
            Expanded(
              child: messages.length <= 1
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) =>
                          _buildMessageBubble(messages[index]),
                    ),
            ),
            _buildInputBar(),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
                    onPressed: () {},
                    icon: const Icon(Icons.mic_rounded,
                        color: AppColors.shieldTeal, size: 26),
                    tooltip: 'Ghi âm',

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
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 22),
                    style: IconButton.styleFrom(
                        backgroundColor: AppColors.shieldTeal,
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

  const _ChatMessage({
    required this.isAi,
    required this.text,
    required this.time,
    this.isImage = false,
    this.isAnalyzing = false,
    this.imageName,
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
