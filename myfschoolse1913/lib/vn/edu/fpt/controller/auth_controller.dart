import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/api_response.dart';
import '../model/forgot_password_request.dart';
import '../model/jwt_response.dart';
import '../model/login_request.dart';
import '../model/refresh_token_response.dart';

class AuthController {

  static const String baseUrl =
      "http://localhost:8080/api/auth";
      // "http://10.0.2.2:8080/api/auth";

  Future<ApiResponse<JwtResponse>> login(
      LoginRequest request) async {

    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );

    final json = jsonDecode(response.body);

    return ApiResponse<JwtResponse>.fromJson(
      json,
          (data) => JwtResponse.fromJson(data),
    );
  }

  Future<ApiResponse<RefreshTokenResponse>> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse("$baseUrl/refresh-token"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    final json = jsonDecode(response.body);

    return ApiResponse<RefreshTokenResponse>.fromJson(
      json,
          (data) => RefreshTokenResponse.fromJson(data),
    );
  }


  Future<ApiResponse<JwtResponse>> forgotPassword(ForgotPasswordRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    final json = jsonDecode(response.body);

    return ApiResponse<JwtResponse>.fromJson(
      json,
          (data) => JwtResponse.fromJson(data),
    );

  }

  Future<ApiResponse<String>> logout(String refreshToken) async {
    final response = await http.post(
      Uri.parse("$baseUrl/logout"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    final json = jsonDecode(response.body);

    return ApiResponse<String>.fromJson(
      json,
      (data) => data.toString(),
    );
  }
}