import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/cooling_off_provider.dart';
import 'share_summary.dart';

class CoolingOffScreen extends ConsumerStatefulWidget {
  const CoolingOffScreen({super.key});

  @override
  ConsumerState<CoolingOffScreen> createState() => _CoolingOffScreenState();
}

class _CoolingOffScreenState extends ConsumerState<CoolingOffScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(coolingOffProvider);
    final notifier = ref.read(coolingOffProvider.notifier);
    final remaining = notifier.remaining;

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    return Scaffold(
      appBar: AppBar(title: const Text('Thời gian suy nghĩ')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, size: 80, color: Color(0xFF1565C0)),
            const SizedBox(height: 24),
            Text(
              'ĐỪNG QUYẾT ĐỊNH VỘI',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy chờ hết thời gian này rồi mới quyết định',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (notifier.isActive) ...[
              Text(
                '${hours.toString().padLeft(2, '0')}:'
                '${minutes.toString().padLeft(2, '0')}:'
                '${seconds.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'còn lại',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ] else
              Text(
                'Thời gian suy nghĩ đã hết',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.green),
              ),
            const SizedBox(height: 40),
            const ShareSummaryButton(),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: notifier.cancel,
              child: const Text('Tôi đã an toàn, hủy timer'),
            ),
          ],
        ),
      ),
    );
  }
}
