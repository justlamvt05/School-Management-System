class JwtResponse {
  final String type;
  final String token;
  final String phone;
  final String? refreshToken;

  JwtResponse({
    required this.type,
    required this.token,
    required this.phone,
    this.refreshToken,
  });

  factory JwtResponse.fromJson(Map<String, dynamic> json) {
    return JwtResponse(
      type: json["type"] ?? '',
      token: json["token"] ?? '',
      phone: json["phone"] ?? '',
      refreshToken: json["refreshToken"],
    );
  }
}