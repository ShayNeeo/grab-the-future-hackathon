import 'dart:convert';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart' show Color;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart'
    if (dart.library.html) 'package:justful/src/services/telephony_mock.dart';
import 'package:justful/core/constants/app_constants.dart';
import 'package:justful/src/models/sms_alert.dart';

const _tag = '[SmsDetection]';
// Set to true to show a notification for EVERY SMS (not just scams) — useful for debugging.
const _debugEveryMessage = true;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void backGroundMessageHandler(SmsMessage message) async {
  debugPrint('$_tag backGroundMessageHandler triggered — from: ${message.address}');
  // Each Dart isolate has its own heap — re-initialize the plugin here.
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  debugPrint('$_tag notification plugin initialized in background isolate');
  final String sender = message.address ?? 'Người lạ';
  final String body = message.body ?? '';
  if (body.isNotEmpty) {
    await SmsDetectionService.processSms(sender, body);
  } else {
    debugPrint('$_tag skipped — empty body');
  }
}

class SmsDetectionService {
  static final SmsDetectionService instance = SmsDetectionService._();
  SmsDetectionService._();

  final Telephony telephony = Telephony.instance;
  bool _initialized = false;

  Future<void> init() async {
    debugPrint('$_tag init() called — already initialized: $_initialized');
    if (_initialized) return;
    _initialized = true;

    try {
      debugPrint('$_tag initializing notification plugin...');
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      debugPrint('$_tag notification plugin initialized');

      // Android 13+ requires POST_NOTIFICATIONS permission at runtime.
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      debugPrint('$_tag notification permission granted: $granted');
    } catch (e) {
      debugPrint('$_tag notification plugin init failed: $e');
    }

    if (kIsWeb) {
      debugPrint('$_tag running on web — SMS listener skipped');
      return;
    }
    if (!Platform.isAndroid) {
      debugPrint('$_tag not Android (${Platform.operatingSystem}) — SMS listener skipped');
      return;
    }

    try {
      debugPrint('$_tag requesting SMS + Phone permissions...');
      final bool? permission = await telephony.requestPhoneAndSmsPermissions
          .timeout(const Duration(seconds: 10), onTimeout: () => false);
      debugPrint('$_tag permission result: $permission');

      if (permission == true) {
        debugPrint('$_tag permission granted — starting listenIncomingSms');
        telephony.listenIncomingSms(
          onNewMessage: (SmsMessage message) {
            debugPrint('$_tag onNewMessage — from: ${message.address}, body: ${message.body}');
            processSms(message.address ?? 'Người lạ', message.body ?? '');
          },
          onBackgroundMessage: backGroundMessageHandler,
        );
        debugPrint('$_tag SMS listener registered successfully');
      } else {
        debugPrint('$_tag permission DENIED — SMS interception will not work');
      }
    } catch (e) {
      debugPrint('$_tag SMS permission request failed: $e');
    }
  }

  static Future<void> processSms(String sender, String body) async {
    debugPrint('$_tag processSms() — sender: $sender');
    debugPrint('$_tag body preview: ${body.length > 80 ? body.substring(0, 80) : body}');
    debugPrint('$_tag API baseUrl: ${AppConstants.apiBaseUrl}');

    if (_debugEveryMessage) {
      await _showNotification('[DEBUG] Đang phân tích SMS...', 'Từ: $sender');
    }

    final Dio dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));

    try {
      debugPrint('$_tag POST /analyze...');
      final response = await dio.post<ResponseBody>(
        '/analyze',
        data: {'text': body, 'history': []},
        options: Options(responseType: ResponseType.stream),
      );
      debugPrint('$_tag POST /analyze status: ${response.statusCode}');

      final responseData = response.data;
      if (responseData == null) {
        debugPrint('$_tag response.data is null — aborting');
        return;
      }

      String accumulated = '';
      await for (final chunk in responseData.stream) {
        accumulated += utf8.decode(chunk);
      }
      debugPrint('$_tag stream complete — accumulated ${accumulated.length} chars');

      String jsonText = accumulated;
      if (accumulated.contains('</thought>')) {
        jsonText = accumulated.split('</thought>').last.trim();
        debugPrint('$_tag stripped <thought> block');
      }
      final start = jsonText.indexOf('{');
      final end = jsonText.lastIndexOf('}');
      if (start != -1 && end != -1 && end >= start) {
        jsonText = jsonText.substring(start, end + 1);
      }
      debugPrint('$_tag JSON to parse: ${jsonText.length > 200 ? jsonText.substring(0, 200) : jsonText}');

      final repairedJson = _repairJson(jsonText);
      final Map<String, dynamic> data = json.decode(repairedJson) as Map<String, dynamic>;

      final String riskLevel = data['risk_level'] as String? ?? 'low';
      final String explanation = data['explanation'] as String? ?? '';
      debugPrint('$_tag risk_level: $riskLevel');

      if (_debugEveryMessage) {
        await _showNotification(
          '[DEBUG] SMS từ $sender',
          'Rủi ro: $riskLevel | ${body.length > 60 ? body.substring(0, 60) : body}',
        );
      }

      if (riskLevel == 'medium' || riskLevel == 'high' || riskLevel == 'critical') {
        debugPrint('$_tag risk=$riskLevel — showing notification and saving alert');
        await _showNotification(
          '⚠️ CẢNH BÁO LỪA ĐẢO!',
          'Phát hiện dấu hiệu lừa đảo từ: $sender. Nhấp để xem chi tiết.',
        );
        await _saveAlert(SmsAlert(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: sender,
          body: body,
          riskLevel: riskLevel,
          explanation: explanation,
          timestamp: DateTime.now(),
        ));
        debugPrint('$_tag alert saved');
      } else {
        debugPrint('$_tag risk=$riskLevel — no alert needed');
      }
    } catch (e, st) {
      debugPrint('$_tag processSms ERROR: $e');
      debugPrint('$_tag stack: $st');
    }
  }

  static Future<void> _showNotification(String title, String body) async {
    final int notifId = DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF;
    debugPrint('$_tag showNotification id=$notifId title=$title');
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'scam_warnings',
      'Cảnh báo Lừa đảo',
      channelDescription: 'Thông báo cảnh báo từ Lá Chắn Lừa Đảo',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      color: Color(0xFFC0392B),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      notifId,
      title,
      body,
      platformChannelSpecifics,
    );
    debugPrint('$_tag notification shown');
  }

  static Future<void> _saveAlert(SmsAlert alert) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList('sms_alerts') ?? [];
    final isDuplicate = existing.any((item) {
      try {
        final parsed = json.decode(item) as Map<String, dynamic>;
        return parsed['sender'] == alert.sender && parsed['body'] == alert.body;
      } catch (_) {
        return false;
      }
    });
    if (isDuplicate) {
      debugPrint('$_tag duplicate alert — skipped');
      return;
    }
    existing.insert(0, json.encode(alert.toJson()));
    if (existing.length > 100) existing.removeRange(100, existing.length);
    await prefs.setStringList('sms_alerts', existing);
  }

  static String _repairJson(String jsonStr) {
    jsonStr = jsonStr.trim();
    if (jsonStr.isEmpty) return '{}';

    List<String> stack = [];
    bool inQuote = false;
    bool escaped = false;
    List<String> repaired = [];

    for (int i = 0; i < jsonStr.length; i++) {
      String char = jsonStr[i];
      if (inQuote) {
        if (escaped) {
          escaped = false;
        } else if (char == '\\') {
          escaped = true;
        } else if (char == '"') {
          inQuote = false;
        }
        repaired.add(char);
      } else {
        if (char == '"') {
          inQuote = true;
        } else if (char == '{' || char == '[') {
          stack.add(char);
        } else if (char == '}' || char == ']') {
          if (stack.isNotEmpty) {
            stack.removeLast();
          }
        }
        repaired.add(char);
      }
    }

    if (inQuote) repaired.add('"');

    String repairedStr = repaired.join('').trim();
    while (repairedStr.endsWith(',')) {
      repairedStr = repairedStr.substring(0, repairedStr.length - 1).trim();
    }
    while (stack.isNotEmpty) {
      String opener = stack.removeLast();
      repairedStr += opener == '{' ? '}' : ']';
    }

    return repairedStr;
  }
}
