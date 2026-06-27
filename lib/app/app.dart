import 'package:flutter/material.dart';
import 'package:scamshield/app/routes.dart';
import 'package:scamshield/core/theme/app_theme.dart';
import 'package:scamshield/src/models/analysis_response.dart';
import 'package:scamshield/ui/screens/scam_result_card_screen.dart';
import 'package:scamshield/ui/screens/family_alert_screen.dart';

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
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.scamResult) {
          final analysis = settings.arguments as AnalysisResponse;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => ScamResultCardScreen(analysis: analysis),
          );
        }
        if (settings.name == AppRoutes.familyAlert) {
          final analysis = settings.arguments as AnalysisResponse;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => FamilyAlertScreen(analysis: analysis),
          );
        }
        return null;
      },
    );
  }
}
