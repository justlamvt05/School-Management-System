class ClassRoomResponse {
  final int id;
  final String name;
  final String grade;
  final String schoolYear;

  ClassRoomResponse({
    required this.id,
    required this.name,
    required this.grade,
    required this.schoolYear,
  });

  factory ClassRoomResponse.fromJson(Map<String, dynamic> json) {
    return ClassRoomResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      grade: json['grade'] ?? '',
      schoolYear: json['schoolYear'] ?? '',
    );
  }
}
