import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:justful/app/app.dart';
import 'package:justful/src/services/sms_detection_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fire-and-forget: don't block app startup on SMS service init.
  // The SMS service can initialize in the background; the app UI
  // should always render regardless of permission/plugin status.
  SmsDetectionService.instance.init().catchError((e) {
    debugPrint('[Main] SmsDetectionService.init() failed: $e');
  });

  runApp(const ProviderScope(child: JustfulApp()));
}
