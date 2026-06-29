class RefreshTokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      accessToken: json["accessToken"] ?? '',
      refreshToken: json["refreshToken"] ?? '',
      tokenType: json["tokenType"] ?? '',
    );
  }
}
