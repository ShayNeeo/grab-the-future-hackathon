import 'package:flutter/material.dart';
import 'package:justifty/app/routes.dart';
import 'package:justifty/core/theme/app_theme.dart';
import 'package:justifty/src/models/analysis_response.dart';
import 'package:justifty/ui/screens/scam_result_card_screen.dart';

class JustiftyApp extends StatelessWidget {
  const JustiftyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Justifty',
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
