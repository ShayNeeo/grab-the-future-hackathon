import 'package:scamshield/src/models/analysis_response.dart';

class FamilyAlertResponse {
  final String situationSummary;
  final RiskLevel riskLevel;
  final List<String> mainRisks;
  final String doNotSay;
  final String doSay;
  final List<String> immediateActions;

  const FamilyAlertResponse({
    required this.situationSummary,
    required this.riskLevel,
    required this.mainRisks,
    required this.doNotSay,
    required this.doSay,
    required this.immediateActions,
  });

  factory FamilyAlertResponse.fromJson(Map<String, dynamic> json) {
    const levelMap = {
      'critical': RiskLevel.critical,
      'high': RiskLevel.high,
      'medium': RiskLevel.medium,
      'low': RiskLevel.low,
    };
    return FamilyAlertResponse(
      situationSummary: json['situation_summary'] as String? ?? '',
      riskLevel: levelMap[json['risk_level']] ?? RiskLevel.high,
      mainRisks: List<String>.from(json['main_risks'] ?? []),
      doNotSay: json['do_not_say'] as String? ?? '',
      doSay: json['do_say'] as String? ?? '',
      immediateActions: List<String>.from(json['immediate_actions'] ?? []),
    );
  }
}
