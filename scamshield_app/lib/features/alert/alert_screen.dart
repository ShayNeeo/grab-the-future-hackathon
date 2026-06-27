import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/models/analysis_response.dart';
import '../../core/providers/cooling_off_provider.dart';
import 'risk_badge.dart';
import 'red_flag_list.dart';
import '../cooling_off/cooling_off_screen.dart';

class AlertScreen extends ConsumerWidget {
  const AlertScreen({super.key, required this.response});

  final AnalysisResponse response;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCritical = response.riskLevel == RiskLevel.critical;

    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả phân tích')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RiskBadge(level: response.riskLevel),
            const SizedBox(height: 12),
            Text(response.caseType,
                style: Theme.of(context).textTheme.titleLarge),
            Text('Giai đoạn: ${response.stage}',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            if (response.redFlags.isNotEmpty) ...[
              Text('Dấu hiệu lừa đảo',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.red)),
              const SizedBox(height: 8),
              RedFlagList(flags: response.redFlags),
              const SizedBox(height: 20),
            ],
            if (response.nextActions.isNotEmpty) ...[
              Text('Việc cần làm ngay',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...response.nextActions.map((action) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 18)),
                        Expanded(
                            child: Text(action,
                                style:
                                    Theme.of(context).textTheme.bodyLarge)),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
            ],
            if (response.suggestedReply.isNotEmpty) ...[
              Text('Câu từ chối gợi ý',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(response.suggestedReply,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: response.suggestedReply));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã sao chép!')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Sao chép'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (response.coolingOff || isCritical)
              ElevatedButton.icon(
                onPressed: () async {
                  await ref
                      .read(coolingOffProvider.notifier)
                      .start(hours: response.coolingOffHours);
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CoolingOffScreen()),
                    );
                  }
                },
                icon: const Icon(Icons.timer),
                label:
                    Text('Bật Cooling-off ${response.coolingOffHours}h'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
