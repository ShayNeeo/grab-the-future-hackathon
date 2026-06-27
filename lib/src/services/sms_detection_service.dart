import 'dart:convert';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart' show Color;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart'
    if (dart.library.html) 'package:scamshield/src/services/telephony_mock.dart';
import 'package:scamshield/core/constants/app_constants.dart';
import 'package:scamshield/src/models/sms_alert.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Top-level background message handler
@pragma('vm:entry-point')
void backGroundMessageHandler(SmsMessage message) async {
  final String sender = message.address ?? 'Người lạ';
  final String body = message.body ?? '';
  if (body.isNotEmpty) {
    await SmsDetectionService.processSms(sender, body);
  }
}

class SmsDetectionService {
  static final SmsDetectionService instance = SmsDetectionService._();
  SmsDetectionService._();

  final Telephony telephony = Telephony.instance;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Initialize Telephony listener (Android only, not web/iOS)
    if (!kIsWeb && Platform.isAndroid) {
      final bool? permission = await telephony.requestPhoneAndSmsPermissions;
      if (permission == true) {
        telephony.listenIncomingSms(
          onNewMessage: (SmsMessage message) {
            processSms(message.address ?? 'Người lạ', message.body ?? '');
          },
          onBackgroundMessage: backGroundMessageHandler,
        );
      }
    }
  }

  static Future<void> processSms(String sender, String body) async {
    final Dio dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));

    try {
      // Call analyze stream endpoint
      final response = await dio.post<ResponseBody>(
        '/analyze',
        data: {
          'text': body,
          'history': [],
        },
        options: Options(responseType: ResponseType.stream),
      );

      // Accumulate stream chunks
      String accumulated = '';
      await for (final chunk in response.data!.stream) {
        accumulated += utf8.decode(chunk);
      }

      // Extract JSON from the accumulated text
      String jsonText = accumulated;
      if (accumulated.contains('</thought>')) {
        jsonText = accumulated.split('</thought>').last.trim();
      }
      final start = jsonText.indexOf('{');
      final end = jsonText.lastIndexOf('}');
      if (start != -1 && end != -1 && end >= start) {
        jsonText = jsonText.substring(start, end + 1);
      }

      final repairedJson = _repairJson(jsonText);
      final Map<String, dynamic> data = json.decode(repairedJson) as Map<String, dynamic>;

      final String riskLevel = data['risk_level'] as String? ?? 'low';
      final String explanation = data['explanation'] as String? ?? '';
      
      // If risk is Medium, High or Critical, alert the user!
      if (riskLevel == 'medium' || riskLevel == 'high' || riskLevel == 'critical') {
        // Trigger Local Notification
        await _showNotification(
          '⚠️ CẢNH BÁO LỪA ĐẢO!',
          'Phát hiện dấu hiệu lừa đảo từ: $sender. Nhấp để xem chi tiết.',
        );

        // Save SMS Alert to local storage
        await _saveAlert(SmsAlert(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: sender,
          body: body,
          riskLevel: riskLevel,
          explanation: explanation,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      print('SMS Detection Background Error: $e');
    }
  }

  static Future<void> _showNotification(String title, String body) async {
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
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  static Future<void> _saveAlert(SmsAlert alert) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList('sms_alerts') ?? [];
    existing.insert(0, json.encode(alert.toJson()));
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
    
    if (inQuote) {
      repaired.add('"');
    }
    
    String repairedStr = repaired.join('').trim();
    while (repairedStr.endsWith(',')) {
      repairedStr = repairedStr.substring(0, repairedStr.length - 1).trim();
    }
    
    while (stack.isNotEmpty) {
      String opener = stack.removeLast();
      if (opener == '{') {
        repairedStr += '}';
      } else if (opener == '[') {
        repairedStr += ']';
      }
    }
    
    return repairedStr;
  }
}
