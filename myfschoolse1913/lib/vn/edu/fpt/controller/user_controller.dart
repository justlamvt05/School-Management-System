import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/api_response.dart';
import '../model/user_profile_response.dart';
import '../core/token_manager.dart';
import 'auth_controller.dart';

class UserController {
  static const String baseUrl = "http://localhost:8080/api/users";

  final String token;

  UserController({required this.token});

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${TokenManager.instance.token.isNotEmpty ? TokenManager.instance.token : token}",
      };

  Future<http.Response> _getWithRetry(String url) async {
    var response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 401) {
      final authController = AuthController();
      final refreshResult = await authController.refreshToken(TokenManager.instance.refreshToken);

      if (refreshResult.status && refreshResult.data != null) {
        TokenManager.instance.token = refreshResult.data!.accessToken;
        TokenManager.instance.refreshToken = refreshResult.data!.refreshToken;

        // Retry the request with the new token
        response = await http.get(Uri.parse(url), headers: _headers);
      }
    }
    return response;
  }

  Future<http.Response> _postWithRetry(String url, Map<String, dynamic> body) async {
    var response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final authController = AuthController();
      final refreshResult = await authController.refreshToken(TokenManager.instance.refreshToken);

      if (refreshResult.status && refreshResult.data != null) {
        TokenManager.instance.token = refreshResult.data!.accessToken;
        TokenManager.instance.refreshToken = refreshResult.data!.refreshToken;

        // Retry the request with the new token
        response = await http.post(
          Uri.parse(url),
          headers: _headers,
          body: jsonEncode(body),
        );
      }
    }
    return response;
  }

  Future<ApiResponse<UserProfile>> getProfile() async {
    final response = await _getWithRetry("$baseUrl/profile");

    final json = jsonDecode(utf8.decode(response.bodyBytes));

    return ApiResponse<UserProfile>.fromJson(
      json,
      (data) => UserProfile.fromJson(data),
    );
  }

  Future<ApiResponse<String>> changePassword({
    required String password,
    required String confirmPassword,
    required String phone,
  }) async {
    final uri = Uri.parse("$baseUrl/change-password").replace(
      queryParameters: {
        "password": password,
        "confirmPassword": confirmPassword,
        "phone": phone,
      },
    );

    var response = await http.put(uri, headers: _headers);

    if (response.statusCode == 401) {
      final authController = AuthController();
      final refreshResult = await authController.refreshToken(TokenManager.instance.refreshToken);

      if (refreshResult.status && refreshResult.data != null) {
        TokenManager.instance.token = refreshResult.data!.accessToken;
        TokenManager.instance.refreshToken = refreshResult.data!.refreshToken;
        response = await http.post(uri, headers: _headers);
      }
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes));

    return ApiResponse<String>.fromJson(
      json,
      (data) => data.toString(),
    );
  }
}
