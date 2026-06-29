class ClubItem {
  final int id;
  final String code;
  final String name;
  final bool joined;

  ClubItem({
    required this.id,
    required this.code,
    required this.name,
    required this.joined,
  });

  factory ClubItem.fromJson(Map<String, dynamic> json) {
    return ClubItem(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      joined: json['joined'] ?? false,
    );
  }
}
