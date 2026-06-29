/// Model cho 1 tiết học từ API /api/student/schedules/class/{classId}
class ScheduleItem {
  final int id;
  final String subjectName;
  final String dayOfWeek;
  final int periodStart;
  final int periodEnd;
  final String room;

  ScheduleItem({
    required this.id,
    required this.subjectName,
    required this.dayOfWeek,
    required this.periodStart,
    required this.periodEnd,
    required this.room,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'] ?? 0,
      subjectName: json['subjectName'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
      periodStart: json['periodStart'] ?? 0,
      periodEnd: json['periodEnd'] ?? 0,
      room: json['room'] ?? '',
    );
  }

  /// Chuyển dayOfWeek enum sang tên tiếng Việt ngắn
  String get dayOfWeekShort {
    switch (dayOfWeek) {
      case 'MONDAY':
        return 'T2';
      case 'TUESDAY':
        return 'T3';
      case 'WEDNESDAY':
        return 'T4';
      case 'THURSDAY':
        return 'T5';
      case 'FRIDAY':
        return 'T6';
      case 'SATURDAY':
        return 'T7';
      case 'SUNDAY':
        return 'CN';
      default:
        return dayOfWeek;
    }
  }

  String get dayOfWeekFull {
    switch (dayOfWeek) {
      case 'MONDAY':
        return 'Thứ 2';
      case 'TUESDAY':
        return 'Thứ 3';
      case 'WEDNESDAY':
        return 'Thứ 4';
      case 'THURSDAY':
        return 'Thứ 5';
      case 'FRIDAY':
        return 'Thứ 6';
      case 'SATURDAY':
        return 'Thứ 7';
      case 'SUNDAY':
        return 'Chủ nhật';
      default:
        return dayOfWeek;
    }
  }

  /// Trả về chuỗi tiết học, VD: "Tiết 1-2" hoặc "Tiết 5"
  String get periodLabel {
    if (periodStart == periodEnd) {
      return 'Tiết $periodStart';
    }
    return 'Tiết $periodStart-$periodEnd';
  }
}
