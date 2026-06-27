class SmsAlert {
  final String id;
  final String sender;
  final String body;
  final String riskLevel;
  final String explanation;
  final DateTime timestamp;

  SmsAlert({
    required this.id,
    required this.sender,
    required this.body,
    required this.riskLevel,
    required this.explanation,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender': sender,
        'body': body,
        'riskLevel': riskLevel,
        'explanation': explanation,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SmsAlert.fromJson(Map<String, dynamic> json) => SmsAlert(
        id: json['id'] as String,
        sender: json['sender'] as String,
        body: json['body'] as String,
        riskLevel: json['riskLevel'] as String,
        explanation: json['explanation'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
