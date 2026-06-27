import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareSummaryButton extends StatelessWidget {
  const ShareSummaryButton({super.key, this.summary});

  final String? summary;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        final text = summary ??
            'ScamShield cảnh báo: Tôi đang xem xét một đề nghị có dấu hiệu lừa đảo. '
                'Tôi đã bật thời gian suy nghĩ 48h và sẽ không quyết định vội. '
                'Hãy liên hệ tôi nếu bạn muốn biết thêm.';
        Share.share(text, subject: 'ScamShield — Cảnh báo lừa đảo');
      },
      icon: const Icon(Icons.share),
      label: const Text('Chia sẻ với gia đình'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
    );
  }
}
