import 'package:flutter/material.dart';
import '../../core/api/models/analysis_response.dart';

class RedFlagList extends StatelessWidget {
  const RedFlagList({super.key, required this.flags});

  final List<RedFlag> flags;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: flags
          .map((flag) => Card(
                color: const Color(0xFFFFEBEE),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading:
                      const Icon(Icons.flag, color: Colors.red, size: 28),
                  title: Text(
                    _labelForType(flag.type),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(flag.detail,
                      style: const TextStyle(fontSize: 15)),
                ),
              ))
          .toList(),
    );
  }

  String _labelForType(String type) => switch (type) {
        'time_pressure' => 'Áp lực thời gian',
        'gift_bait'     => 'Mồi quà tặng',
        'deposit'       => 'Yêu cầu đặt cọc',
        'impersonation' => 'Giả mạo tổ chức',
        'investment'    => 'Đầu tư lợi nhuận cao',
        _               => type,
      };
}
