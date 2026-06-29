class ApplicationItem {
  final int id;

  final int? studentId;
  final String? studentName;

  final int? teacherId;
  final String? teacherName;

  final String type;
  final String? fromDate;
  final String? toDate;
  final String reason;
  final String? attachmentUrl;
  final String status;
  final String? responseMessage;
  final String? reviewedBy;
  final String? createdAt;
  final String? reviewedAt;

  ApplicationItem({
    required this.id,
    this.studentId,
    this.studentName,
    this.teacherId,
    this.teacherName,
    required this.type,
    this.fromDate,
    this.toDate,
    required this.reason,
    this.attachmentUrl,
    required this.status,
    this.responseMessage,
    this.reviewedBy,
    this.createdAt,
    this.reviewedAt,
  });

  factory ApplicationItem.fromJson(Map<String, dynamic> json) {
    return ApplicationItem(
      id: json['id'] ?? 0,

      studentId: json['studentId'],
      studentName: json['studentName'],

      teacherId: json['teacherId'],
      teacherName: json['teacherName'],

      type: json['type'] ?? '',
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      reason: json['reason'] ?? '',
      attachmentUrl: json['attachmentUrl'],
      status: json['status'] ?? 'PENDING',
      responseMessage: json['responseMessage'],
      reviewedBy: json['reviewedBy'],
      createdAt: json['createdAt'],
      reviewedAt: json['reviewedAt'],
    );
  }

  String get typeLabel {
    switch (type) {
// Student
      case 'LEAVE_SCHOOL':
        return 'Xin nghỉ học';

      case 'LATE_OR_EARLY_LEAVE':
        return 'Xin đi muộn / về sớm';

      case 'STUDENT_CONFIRMATION':
        return 'Xin xác nhận học sinh';

      case 'RESERVE_RESULT':
        return 'Xin bảo lưu kết quả';

      case 'REISSUE_CARD':
        return 'Xin cấp lại thẻ';

      case 'CHANGE_CLASS':
        return 'Xin chuyển lớp';

// Teacher
      case 'LEAVE_REQUEST':
        return 'Xin nghỉ phép';

      case 'SICK_LEAVE':
        return 'Xin nghỉ ốm';

      case 'BUSINESS_TRIP':
        return 'Xin công tác';

      case 'SCHEDULE_CHANGE':
        return 'Xin đổi lịch dạy';

      case 'SUBSTITUTE_REQUEST':
        return 'Xin giáo viên dạy thay';

      case 'OVERTIME_REQUEST':
        return 'Đăng ký làm thêm giờ';

      case 'EQUIPMENT_REQUEST':
        return 'Xin cấp thiết bị';

      case 'TRAINING_REQUEST':
        return 'Đăng ký tập huấn';

      case 'OTHER':
        return 'Đơn khác';

      default:
        return type;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'PENDING':
        return 'Chờ duyệt';

      case 'APPROVED':
        return 'Đã duyệt';

      case 'REJECTED':
        return 'Đã từ chối';

      default:
        return status;
    }
  }
}