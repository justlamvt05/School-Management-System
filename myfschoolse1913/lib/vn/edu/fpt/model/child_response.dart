class ChildResponse {
  final int classId;
  final String className;
  final String fullName;
  final String schoolYear;
  final String studentCode;
  final int studentId;

  ChildResponse({
    required this.classId,
    required this.className,
    required this.fullName,
    required this.schoolYear,
    required this.studentCode,
    required this.studentId,
  });

  factory ChildResponse.fromJson(Map<String, dynamic> json) {
    return ChildResponse(
      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',
      fullName: json['fullName'] ?? '',
      schoolYear: json['schoolYear'] ?? '',
      studentCode: json['studentCode'] ?? '',
      studentId: json['studentId'] ?? 0,
    );
  }
}
