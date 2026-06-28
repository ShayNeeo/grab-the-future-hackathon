import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:justful/core/theme/app_colors.dart';
import 'package:justful/ui/widgets/shield_button.dart';

class ContractAnalysisScreen extends StatelessWidget {
  const ContractAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        title: Text(
          'Phân tích Hợp đồng',
          style: GoogleFonts.plusJakartaSans(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Risk Summary Strip ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.alertOrange,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Hợp đồng: RỦI RO CAO',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '3/7 mục',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Checklist Section ──
              Text(
                'Danh sách kiểm tra hợp đồng',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _CheckItem(
                icon: Icons.check_circle_rounded,
                iconColor: AppColors.alertGreen,
                label: 'Có tên công ty đầy đủ?',
                result: 'Có',
                resultColor: AppColors.alertGreen,
                bgColor: AppColors.surfaceWhite,
              ),
              _CheckItem(
                icon: Icons.cancel_rounded,
                iconColor: AppColors.alertRed,
                label: 'Có điều khoản hoàn tiền không?',
                result: 'Không thấy',
                resultColor: AppColors.alertRed,
                bgColor: AppColors.surfaceLight,
              ),
              _CheckItem(
                icon: Icons.check_circle_rounded,
                iconColor: AppColors.alertGreen,
                label: 'Có ngày bắt đầu và kết thúc?',
                result: 'Có',
                resultColor: AppColors.alertGreen,
                bgColor: AppColors.surfaceWhite,
              ),
              _CheckItem(
                icon: Icons.help_outline_rounded,
                iconColor: AppColors.alertOrange,
                label: 'Có nêu rõ tổng chi phí?',
                result: 'Không rõ',
                resultColor: AppColors.alertOrange,
                bgColor: AppColors.surfaceLight,
              ),
              _CheckItem(
                icon: Icons.cancel_rounded,
                iconColor: AppColors.alertRed,
                label: 'Có quy định phạt khi hủy?',
                result: 'Không thấy',
                resultColor: AppColors.alertRed,
                bgColor: AppColors.surfaceWhite,
              ),
              _CheckItem(
                icon: Icons.check_circle_rounded,
                iconColor: AppColors.alertGreen,
                label: 'Có chữ ký hai bên?',
                result: 'Có',
                resultColor: AppColors.alertGreen,
                bgColor: AppColors.surfaceLight,
              ),
              _CheckItem(
                icon: Icons.cancel_rounded,
                iconColor: AppColors.alertRed,
                label: 'Có quy trình giải quyết tranh chấp?',
                result: 'Không thấy',
                resultColor: AppColors.alertRed,
                bgColor: AppColors.surfaceWhite,
              ),
              const SizedBox(height: 28),

              // ── High-Risk Clauses ──
              Row(
                children: [
                  Text(
                    'Điều khoản nguy hiểm',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.alertRed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '3',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ExpandableClause(
                title: 'Không có điều khoản hoàn tiền',
                explanation:
                    'Hợp đồng không ghi rõ quyền được hoàn tiền nếu khách hàng hủy. Điều này có nghĩa bạn có thể mất toàn bộ số tiền đã thanh toán.',
              ),
              const SizedBox(height: 12),
              _ExpandableClause(
                title: 'Phí phạt hủy hợp đồng lên đến 80%',
                explanation:
                    'Nếu bạn muốn hủy sau khi ký, bạn sẽ bị phạt 80% giá trị hợp đồng. Đây là mức phạt bất thường và quá cao so với quy định.',
              ),
              const SizedBox(height: 12),
              _ExpandableClause(
                title: 'Bên bán có quyền thay đổi điều kiện',
                explanation:
                    'Điều khoản cho phép bên bán thay đổi dịch vụ mà không cần thông báo trước. Bạn có thể nhận được dịch vụ khác hoàn toàn so với quảng cáo.',
              ),
              const SizedBox(height: 28),

              // ── Questions to ask ──
              Text(
                'Câu hỏi cần hỏi bên bán',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _NumberedQuestion(
                number: 1,
                text: 'Tôi có được hoàn tiền nếu hủy trong bao lâu?',
              ),
              _NumberedQuestion(
                number: 2,
                text: 'Tổng chi phí cuối cùng là bao nhiêu, có phát sinh thêm không?',
              ),
              _NumberedQuestion(
                number: 3,
                text: 'Tôi có thể xem lại hợp đồng trước khi ký không?',
              ),
              const SizedBox(height: 16),
              ShieldButton(
                label: '📋 Sao chép tất cả câu hỏi',
                onPressed: () {},
                isOutlined: true,
              ),
              const SizedBox(height: 24),

              // ── Bottom CTA ──
              ShieldButton(
                label: '🚫 Không ký bản này — Gửi cho chuyên gia',
                onPressed: () {},
                backgroundColor: AppColors.alertRed,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String result;
  final Color resultColor;
  final Color bgColor;

  const _CheckItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.result,
    required this.resultColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: bgColor,
      child: Row(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            result,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: resultColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableClause extends StatefulWidget {
  final String title;
  final String explanation;

  const _ExpandableClause({
    required this.title,
    required this.explanation,
  });

  @override
  State<_ExpandableClause> createState() => _ExpandableClauseState();
}

class _ExpandableClauseState extends State<_ExpandableClause> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: const BorderSide(color: AppColors.alertRed, width: 4)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.alertRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Nguy hiểm',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.alertRed,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.expand_more_rounded,
                      size: 26,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.explanation,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

class _NumberedQuestion extends StatelessWidget {
  final int number;
  final String text;

  const _NumberedQuestion({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.shieldTeal,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
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
