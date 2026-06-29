class TeacherTakeAttendanceRequest {
  final int classRoomId;
  final String attendanceDate;
  final int period;
  final List<StudentAttendanceRequest> attendances;

  TeacherTakeAttendanceRequest({
    required this.classRoomId,
    required this.attendanceDate,
    required this.period,
    required this.attendances,
  });

  Map<String, dynamic> toJson() {
    return {
      'classRoomId': classRoomId,
      'attendanceDate': attendanceDate,
      'period': period,
      'attendances': attendances.map((e) => e.toJson()).toList(),
    };
  }
}

class StudentAttendanceRequest {
  final int studentId;
  final String status;
  final String? note;

  StudentAttendanceRequest({
    required this.studentId,
    required this.status,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'status': status,
      'note': note,
    };
  }
}
