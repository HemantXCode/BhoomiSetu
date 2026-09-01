class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // TASK_ASSIGNED, VERIFICATION_UPDATE, SYNC_ALERT, GENERAL
  final DateTime timestamp;
  final bool isRead;
  final String? relatedId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.relatedId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawId = (json['id'] ?? json['notification_id'])?.toString() ?? '';
    final title = json['title'] as String? ?? json['notification_type'] as String? ?? 'Gazette Notification';
    final gazetteNum = json['gazette_number'] as String?;
    final message = json['message'] as String? ?? (gazetteNum != null ? 'Gazette Publication: $gazetteNum' : 'Official statutory land notification');

    DateTime ts = DateTime.now();
    if (json['timestamp'] != null) {
      ts = DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now();
    } else if (json['issue_date'] != null) {
      ts = DateTime.tryParse(json['issue_date'].toString()) ?? DateTime.now();
    }

    return NotificationModel(
      id: rawId,
      title: title,
      message: message,
      type: json['type'] as String? ?? json['notification_type'] as String? ?? 'GENERAL',
      timestamp: ts,
      isRead: json['isRead'] == 1 || json['isRead'] == true || json['is_read'] == 1,
      relatedId: (json['relatedId'] ?? json['related_id'] ?? json['project_id'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead ? 1 : 0,
      'relatedId': relatedId,
    };
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId,
    );
  }
}
