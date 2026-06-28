import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistoryItem {
  final String id;
  final String caseType;
  final String riskLevel;
  final String explanation;
  final DateTime timestamp;

  const ChatHistoryItem({
    required this.id,
    required this.caseType,
    required this.riskLevel,
    required this.explanation,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'caseType': caseType,
        'riskLevel': riskLevel,
        'explanation': explanation,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatHistoryItem.fromJson(Map<String, dynamic> json) => ChatHistoryItem(
        id: json['id'] as String,
        caseType: json['caseType'] as String? ?? '',
        riskLevel: json['riskLevel'] as String? ?? 'low',
        explanation: json['explanation'] as String? ?? '',
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  static const _key = 'chat_history';

  static Future<List<ChatHistoryItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((s) {
      try {
        return ChatHistoryItem.fromJson(json.decode(s) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<ChatHistoryItem>().toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static Future<void> save(ChatHistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(json.encode(item.toJson()));
    // Keep only the last 50 entries
    if (list.length > 50) list.removeRange(0, list.length - 50);
    await prefs.setStringList(_key, list);
  }
}
