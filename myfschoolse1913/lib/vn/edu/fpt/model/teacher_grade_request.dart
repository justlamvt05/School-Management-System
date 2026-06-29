class TeacherGradeRequest {
  final int studentId;
  final int subjectId;
  final int semesterId;
  final double? oralScore;
  final double? score15Min;
  final double? score1Period;
  final double? finalExam;

  TeacherGradeRequest({
    required this.studentId,
    required this.subjectId,
    required this.semesterId,
    this.oralScore,
    this.score15Min,
    this.score1Period,
    this.finalExam,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'subjectId': subjectId,
      'semesterId': semesterId,
      if (oralScore != null) 'oralScore': oralScore,
      if (score15Min != null) 'score15Min': score15Min,
      if (score1Period != null) 'score1Period': score1Period,
      if (finalExam != null) 'finalExam': finalExam,
    };
  }
}
