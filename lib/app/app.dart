import 'package:flutter/material.dart';
import 'package:scamshield/core/theme/app_theme.dart';
import 'package:scamshield/app/routes.dart';

class ScamShieldApp extends StatelessWidget {
  const ScamShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScamShield - Lá Chắn Lừa Đảo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
