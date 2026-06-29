class ForgotPasswordRequest {
  final String phone;
  final String email;

  ForgotPasswordRequest({
    required this.phone,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
    };
  }
}