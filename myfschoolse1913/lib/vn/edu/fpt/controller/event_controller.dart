import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/api_response.dart';
import '../model/event_item.dart';
import '../core/token_manager.dart';
import 'auth_controller.dart';

class EventController {
  static const String baseUrl = "http://localhost:8080/api/events";

  final String token;

  EventController({required this.token});

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "Authorization":
            "Bearer ${TokenManager.instance.token.isNotEmpty ? TokenManager.instance.token : token}",
      };

  Future<http.Response> _getWithRetry(String url) async {
    var response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 401) {
      final authController = AuthController();
      final refreshResult =
          await authController.refreshToken(TokenManager.instance.refreshToken);

      if (refreshResult.status && refreshResult.data != null) {
        TokenManager.instance.token = refreshResult.data!.accessToken;
        TokenManager.instance.refreshToken = refreshResult.data!.refreshToken;

        // Retry the request with the new token
        response = await http.get(Uri.parse(url), headers: _headers);
      }
    }
    return response;
  }

  /// Lấy danh sách sự kiện (ALL + STUDENT)
  Future<ApiResponse<List<EventItem>>> getEvents() async {
    final response = await _getWithRetry(baseUrl);
    final json = jsonDecode(utf8.decode(response.bodyBytes));

    return ApiResponse<List<EventItem>>.fromJson(
      json,
      (data) =>
          (data as List).map((item) => EventItem.fromJson(item)).toList(),
    );
  }

  /// Lấy tất cả sự kiện (bao gồm TEACHER-only)
  Future<ApiResponse<List<EventItem>>> getAllEvents() async {
    final response = await _getWithRetry("$baseUrl/all");
    final json = jsonDecode(utf8.decode(response.bodyBytes));

    return ApiResponse<List<EventItem>>.fromJson(
      json,
      (data) =>
          (data as List).map((item) => EventItem.fromJson(item)).toList(),
    );
  }
}
