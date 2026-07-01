class ClassGradeResponse {
  final int studentId;
  final int? gradeId;
  final String studentName;
  final String studentCode;
  final int subjectId;
  final String subjectName;
  final double? oralScore;
  final double? score15Min;
  final double? score1Period;
  final double? finalExam;
  final double? averageScore;
  final String semesterName;
  final String schoolYear;

  ClassGradeResponse({
    required this.studentId,
    this.gradeId,
    required this.studentName,
    required this.studentCode,
    required this.subjectId,
    required this.subjectName,
    this.oralScore,
    this.score15Min,
    this.score1Period,
    this.finalExam,
    this.averageScore,
    required this.semesterName,
    required this.schoolYear,
  });

  factory ClassGradeResponse.fromJson(Map<String, dynamic> json) {
    return ClassGradeResponse(
      studentId: json['studentId'] ?? 0,
      gradeId: json['gradeId'],
      studentName: json['studentName'] ?? '',
      studentCode: json['studentCode'] ?? '',
      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'] ?? '',
      oralScore: json['oralScore']?.toDouble(),
      score15Min: json['score15Min']?.toDouble(),
      score1Period: json['score1Period']?.toDouble(),
      finalExam: json['finalExam']?.toDouble(),
      averageScore: json['averageScore']?.toDouble(),
      semesterName: json['semesterName'] ?? '',
      schoolYear: json['schoolYear'] ?? '',
    );
  }
}
