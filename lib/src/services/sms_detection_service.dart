import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart' show Color;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_sms_reader/android_sms_reader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:justful/core/constants/app_constants.dart';
import 'package:justful/src/models/sms_alert.dart';

const _tag = '[SmsDetection]';
// Set to true to show a notification for EVERY SMS (not just scams) — useful for debugging.
const _debugEveryMessage = false;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// On-screen debug log persisted to SharedPreferences so we can diagnose
/// SMS interception on a phone we can't connect to logcat.
class SmsDebugLog {
  static const _key = 'sms_debug_log';

  static Future<void> add(String line) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      final ts = DateTime.now().toIso8601String().substring(11, 19);
      list.insert(0, '$ts  $line');
      if (list.length > 80) list.removeRange(80, list.length);
      await prefs.setStringList(_key, list);
    } catch (_) {}
  }

  static Future<List<String>> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

/// Logs to both the debug console and the on-screen persistent log.
void _log(String msg) {
  debugPrint('$_tag $msg');
  SmsDebugLog.add(msg);
}

class SmsDetectionService {
  static final SmsDetectionService instance = SmsDetectionService._();
  SmsDetectionService._();

  StreamSubscription<AndroidSMSMessage>? _smsSubscription;
  bool _initialized = false;

  // Coalesce multipart SMS: a long message arrives as several PDU segments,
  // each emitted as a separate stream event with a partial body. We buffer
  // segments per sender and process the joined text once after a short pause.
  final Map<String, String> _pendingBodies = {};
  final Map<String, Timer> _pendingTimers = {};

  void _onIncomingSegment(String sender, String body) {
    _pendingBodies[sender] = (_pendingBodies[sender] ?? '') + body;
    _pendingTimers[sender]?.cancel();
    _pendingTimers[sender] = Timer(const Duration(milliseconds: 1500), () {
      final full = _pendingBodies.remove(sender) ?? '';
      _pendingTimers.remove(sender);
      _log('coalesced SMS from $sender → ${full.length} chars, processing once');
      processSms(sender, full);
    });
  }

  Future<void> init() async {
    _log('init() called — already initialized: $_initialized');
    if (_initialized) return;
    _initialized = true;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Android 13+ requires POST_NOTIFICATIONS permission at runtime.
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      _log('notification permission granted: $granted');
    } catch (e) {
      _log('notification plugin init failed: $e');
    }

    if (kIsWeb) {
      _log('running on web — SMS listener skipped');
      return;
    }
    if (!Platform.isAndroid) {
      _log('not Android (${Platform.operatingSystem}) — SMS listener skipped');
      return;
    }

    try {
      _log('requesting SMS permission...');
      // Receiving SMS only strictly needs RECEIVE_SMS / READ_SMS.
      final smsStatus = await Permission.sms.request();
      _log('SMS permission status: $smsStatus');

      if (smsStatus.isPermanentlyDenied) {
        _log('SMS permanently denied — opening app settings');
        await openAppSettings();
        return;
      }

      if (!smsStatus.isGranted) {
        _log('SMS permission DENIED ($smsStatus) — interception will not work');
        return;
      }

      _log('SMS granted — starting incoming message stream');
      await _smsSubscription?.cancel();
      _smsSubscription = AndroidSMSReader.observeIncomingMessages().listen(
        (AndroidSMSMessage message) {
          final sender = message.address.isEmpty ? 'Người lạ' : message.address;
          _log('>>> INCOMING SMS segment from $sender: ${message.body.length > 40 ? message.body.substring(0, 40) : message.body}');
          _onIncomingSegment(sender, message.body);
        },
        onError: (Object e) {
          _log('SMS stream ERROR: $e');
        },
        onDone: () {
          _log('SMS stream closed (onDone)');
        },
      );
      _log('SMS listener registered successfully — waiting for messages');
    } catch (e) {
      _log('SMS permission/listener setup failed: $e');
    }
  }

  /// Manually re-run init (used by the diagnostic UI's "retry" button).
  Future<void> retryInit() async {
    _initialized = false;
    await init();
  }

  /// Read the most recent N inbox messages — proves READ_SMS works.
  static Future<List<String>> testReadInbox() async {
    try {
      final msgs = await AndroidSMSReader.fetchMessages(
        type: AndroidSMSType.inbox,
        start: 0,
        count: 5,
      );
      _log('testReadInbox: fetched ${msgs.length} messages');
      return msgs
          .map((m) => '${m.address}: ${m.body.length > 50 ? m.body.substring(0, 50) : m.body}')
          .toList();
    } catch (e) {
      _log('testReadInbox ERROR: $e');
      return ['ERROR: $e'];
    }
  }

  static Future<void> processSms(String sender, String body) async {
    _log('processSms() — sender: $sender, API: ${AppConstants.apiBaseUrl}');

    if (_debugEveryMessage) {
      await _showNotification('[DEBUG] Đang phân tích SMS...', 'Từ: $sender');
    }

    final Dio dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));

    try {
      _log('POST /detect-scam...');
      final response = await dio.post<Map<String, dynamic>>(
        '/detect-scam',
        data: {'sender': sender, 'body': body},
      );
      _log('POST /detect-scam status: ${response.statusCode}');

      final data = response.data;
      if (data == null) {
        _log('response.data is null — aborting');
        return;
      }

      final String riskLevel = data['risk_level'] as String? ?? 'low';
      final String explanation = data['explanation'] as String? ?? '';
      _log('risk_level: $riskLevel');

      if (_debugEveryMessage) {
        await _showNotification(
          '[DEBUG] SMS từ $sender',
          'Rủi ro: $riskLevel | ${body.length > 60 ? body.substring(0, 60) : body}',
        );
      }

      if (riskLevel == 'medium' || riskLevel == 'high' || riskLevel == 'critical') {
        _log('risk=$riskLevel — showing scam alert + saving');
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
        _log('alert saved');
      } else {
        _log('risk=$riskLevel — no alert needed');
      }
    } catch (e) {
      _log('processSms ERROR: $e');
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
