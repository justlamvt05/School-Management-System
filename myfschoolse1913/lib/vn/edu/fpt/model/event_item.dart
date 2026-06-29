class EventItem {
  final int id;
  final String title;
  final String? description;
  final String? location;
  final String? startTime;
  final String? endTime;
  final String? targetRole;
  final String? createdByName;

  EventItem({
    required this.id,
    required this.title,
    this.description,
    this.location,
    this.startTime,
    this.endTime,
    this.targetRole,
    this.createdByName,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      location: json['location'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      targetRole: json['targetRole'],
      createdByName: json['createdByName'],
    );
  }

  /// Trả về ngày dạng "dd/MM/yyyy"
  String get formattedDate {
    if (startTime == null) return '';
    try {
      final dt = DateTime.parse(startTime!);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return startTime ?? '';
    }
  }

  /// Trả về giờ dạng "HH:mm"
  String get formattedTime {
    if (startTime == null) return '';
    try {
      final dt = DateTime.parse(startTime!);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  /// Trả về mã viết tắt từ title (3 ký tự đầu viết hoa)
  String get code {
    if (title.isEmpty) return '';
    // Lấy từ đầu tiên, tối đa 4 ký tự
    final words = title.split(' ');
    if (words.length >= 2) {
      return words.take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();
    }
    return title.substring(0, title.length >= 3 ? 3 : title.length).toUpperCase();
  }

  /// Kiểm tra sự kiện sắp diễn ra
  bool get isUpcoming {
    if (startTime == null) return false;
    try {
      return DateTime.parse(startTime!).isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  /// Kiểm tra sự kiện đã diễn ra
  bool get isPast {
    if (endTime == null) return false;
    try {
      return DateTime.parse(endTime!).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }
}
