class UserInsight {
  final String id;
  final int type; // 0: DailyTip, 1: WeeklySummary, 2: Alert
  final String title;
  final String message;
  final String additionalDataJson;
  final DateTime createdAt;

  UserInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.additionalDataJson,
    required this.createdAt,
  });

  factory UserInsight.fromJson(Map<String, dynamic> json) {
    return UserInsight(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      additionalDataJson: json['additionalDataJson'] ?? '{}',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
