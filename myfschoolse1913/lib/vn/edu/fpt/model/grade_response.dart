/// Model cho 1 dòng điểm từ API /api/student/grades/{studentId}
class GradeItem {
  final String subjectName;
  final double oralScore;
  final double score15Min;
  final double score1Period;
  final double finalExam;
  final double averageScore;
  final String semesterName;

  GradeItem({
    required this.subjectName,
    required this.oralScore,
    required this.score15Min,
    required this.score1Period,
    required this.finalExam,
    required this.averageScore,
    required this.semesterName,
  });

  factory GradeItem.fromJson(Map<String, dynamic> json) {
    return GradeItem(
      subjectName: json['subjectName'] ?? '',
      oralScore: (json['oralScore'] ?? 0).toDouble(),
      score15Min: (json['score15Min'] ?? 0).toDouble(),
      score1Period: (json['score1Period'] ?? 0).toDouble(),
      finalExam: (json['finalExam'] ?? 0).toDouble(),
      averageScore: (json['averageScore'] ?? 0).toDouble(),
      semesterName: json['semesterName'] ?? '',
    );
  }
}
