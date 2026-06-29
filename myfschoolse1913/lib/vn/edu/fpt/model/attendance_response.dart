/// Model cho tháng điểm danh từ API /api/student/attendances/class/{classId}/months
class AttendanceMonth {
  final int year;
  final int month;

  AttendanceMonth({
    required this.year,
    required this.month,
  });

  factory AttendanceMonth.fromJson(Map<String, dynamic> json) {
    return AttendanceMonth(
      year: json['year'] ?? 0,
      month: json['month'] ?? 0,
    );
  }
}

/// Model cho 1 dòng điểm danh từ API /api/student/attendances/class/{classId}/my
class AttendanceItem {
  final int id;
  final String attendanceDate;
  final int period;
  final String status;
  final String? note;
  final String studentCode;
  final int studentId;
  final String studentName;

  AttendanceItem({
    required this.id,
    required this.attendanceDate,
    required this.period,
    required this.status,
    this.note,
    required this.studentCode,
    required this.studentId,
    required this.studentName,
  });

  factory AttendanceItem.fromJson(Map<String, dynamic> json) {
    return AttendanceItem(
      id: json['id'] ?? 0,
      attendanceDate: json['attendanceDate'] ?? '',
      period: json['period'] ?? 0,
      status: json['status'] ?? '',
      note: json['note'],
      studentCode: json['studentCode'] ?? '',
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
    );
  }
}
