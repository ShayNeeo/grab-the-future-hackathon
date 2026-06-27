class AppConstants {
  AppConstants._();

  static const String appName = 'Justful';
  static const String appNameVi = 'Justful';
  static const String tagline = 'Bảo vệ bạn khỏi lừa đảo';

  // Elderly-safe minimums
  static const double minFontSize = 16.0;
  static const double bodyFontSize = 18.0;
  static const double minTouchTarget = 56.0;

  // Spacing scale (multiples of 8)
  static const double spacingXs = 8.0;
  static const double spacingSm = 16.0;
  static const double spacingMd = 24.0;
  static const double spacingLg = 32.0;
  static const double spacingXl = 48.0;

  // Border radius
  static const double radiusCard = 20.0;
  static const double radiusButton = 16.0;
  static const double radiusChatBubble = 18.0;
  static const double radiusInput = 14.0;

  // Cooling-off timer
  static const int coolingOffHours = 48;

  // API
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://grab.w9.nu:8085',
  );
}
