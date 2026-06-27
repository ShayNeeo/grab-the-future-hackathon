import 'package:flutter/material.dart';
import 'package:justful/app/routes.dart';
import 'package:justful/core/theme/app_theme.dart';
import 'package:justful/src/models/analysis_response.dart';
import 'package:justful/ui/screens/scam_result_card_screen.dart';

class JustfulApp extends StatelessWidget {
  const JustfulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Justful',
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
        return null;
      },
    );
  }
}
