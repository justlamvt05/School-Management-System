/// Model cho 1 Notification trả về từ API
class NotificationItem {
  final int id;
  final int? userId;
  final String title;
  final String content;
  final bool isRead;
  final String? createdAt;

  NotificationItem({
    required this.id,
    this.userId,
    required this.title,
    required this.content,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      userId: json['userId'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'],
    );
  }
}
