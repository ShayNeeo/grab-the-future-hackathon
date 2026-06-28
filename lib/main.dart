import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:justful/app/app.dart';
import 'package:justful/src/services/sms_detection_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // IMPORTANT: defer SMS service init until AFTER the first frame.
  // Permission dialogs (SMS / Phone / Notifications) need a resumed
  // Activity to attach to. If we request before runApp(), the Activity
  // isn't attached yet and the system dialog silently never appears.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    SmsDetectionService.instance.init().catchError((e) {
      debugPrint('[Main] SmsDetectionService.init() failed: $e');
    });
  });

  runApp(const ProviderScope(child: JustfulApp()));
}
