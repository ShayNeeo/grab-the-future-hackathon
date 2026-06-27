import 'package:flutter/material.dart';
import 'package:justful/ui/screens/splash_onboarding_screen.dart';
import 'package:justful/ui/screens/home_dashboard_screen.dart';
import 'package:justful/ui/screens/chat_screen.dart';
import 'package:justful/ui/screens/cooling_off_timer_screen.dart';
import 'package:justful/ui/screens/contract_analysis_screen.dart';
import 'package:justful/ui/screens/family_guardian_screen.dart';
import 'package:justful/ui/screens/settings_screen.dart';
import 'package:justful/ui/screens/live_monitor_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String scamResult = '/scam-result';
  static const String coolingOff = '/cooling-off';
  static const String contractAnalysis = '/contract-analysis';
  static const String family = '/family';
  static const String settings = '/settings';
  static const String liveMonitor = '/live-monitor';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        onboarding: (_) => const OnboardingScreen(),
        home: (_) => const HomeDashboardScreen(),
        chat: (_) => const ChatScreen(),
        coolingOff: (_) => const CoolingOffTimerScreen(),
        contractAnalysis: (_) => const ContractAnalysisScreen(),
        family: (_) => const FamilyGuardianScreen(),
        settings: (_) => const SettingsScreen(),
        liveMonitor: (_) => const LiveMonitorScreen(),
      };
}
