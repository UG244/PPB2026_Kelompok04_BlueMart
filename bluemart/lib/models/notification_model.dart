class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'order', 'promo', 'system'
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
