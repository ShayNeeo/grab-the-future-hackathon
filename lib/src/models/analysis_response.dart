enum RiskLevel { critical, high, medium, low }

class RedFlag {
  final String type;
  final String detail;

  const RedFlag({required this.type, required this.detail});

  factory RedFlag.fromJson(Map<String, dynamic> json) =>
      RedFlag(type: json['type'] as String, detail: json['detail'] as String);
}

class AnalysisResponse {
  final RiskLevel riskLevel;
  final String caseType;
  final String stage;
  final List<RedFlag> redFlags;
  final List<String> manipulationTactics;
  final List<String> nextActions;
  final bool coolingOff;
  final int coolingOffHours;
  final String suggestedReply;
  final List<String> followUpQuestions;

  const AnalysisResponse({
    required this.riskLevel,
    required this.caseType,
    required this.stage,
    required this.redFlags,
    required this.manipulationTactics,
    required this.nextActions,
    required this.coolingOff,
    required this.coolingOffHours,
    required this.suggestedReply,
    required this.followUpQuestions,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    final levelMap = {
      'critical': RiskLevel.critical,
      'high': RiskLevel.high,
      'medium': RiskLevel.medium,
      'low': RiskLevel.low,
    };
    return AnalysisResponse(
      riskLevel: levelMap[json['risk_level']] ?? RiskLevel.low,
      caseType: json['case_type'] as String? ?? '',
      stage: json['stage'] as String? ?? '',
      redFlags: (json['red_flags'] as List<dynamic>? ?? [])
          .map((e) => RedFlag.fromJson(e as Map<String, dynamic>))
          .toList(),
      manipulationTactics: List<String>.from(json['manipulation_tactics'] ?? []),
      nextActions: List<String>.from(json['next_actions'] ?? []),
      coolingOff: json['cooling_off'] as bool? ?? false,
      coolingOffHours: json['cooling_off_hours'] as int? ?? 48,
      suggestedReply: json['suggested_reply'] as String? ?? '',
      followUpQuestions: List<String>.from(json['follow_up_questions'] ?? []),
    );
  }
}
