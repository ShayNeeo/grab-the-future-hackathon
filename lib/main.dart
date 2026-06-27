import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:justful/app/app.dart';
import 'package:justful/src/services/sms_detection_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SmsDetectionService.instance.init();
  runApp(const ProviderScope(child: JustfulApp()));
}
