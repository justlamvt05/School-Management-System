class TeacherStudentAttendanceResponse {
  final int studentId;
  final String studentName;
  final String mssv;
  final String? avatar;
  final String? status;
  final String? note;

  TeacherStudentAttendanceResponse({
    required this.studentId,
    required this.studentName,
    required this.mssv,
    this.avatar,
    this.status,
    this.note,
  });

  factory TeacherStudentAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return TeacherStudentAttendanceResponse(
      studentId: json['studentId'],
      studentName: json['studentName'] ?? '',
      mssv: json['mssv'] ?? '',
      avatar: json['avatar'],
      status: json['status'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'mssv': mssv,
      'avatar': avatar,
      'status': status,
      'note': note,
    };
  }
}
