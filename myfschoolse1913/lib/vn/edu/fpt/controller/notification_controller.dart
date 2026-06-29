import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/api_response.dart';
import '../model/notification_item.dart';
import '../core/token_manager.dart';
import 'auth_controller.dart';

class NotificationController {
  static const String baseUrl = "http://localhost:8080/api/notifications";
  
  final String token;

  NotificationController({required this.token});

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${TokenManager.instance.token.isNotEmpty ? TokenManager.instance.token : token}",
      };

  Future<http.Response> _requestWithRetry(
    String method,
    String url, {
    Map<String, dynamic>? body,
  }) async {
    http.Response response;
    final uri = Uri.parse(url);

    if (method == 'POST') {
      response = await http.post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null);
    } else if (method == 'PUT') {
      response = await http.put(uri, headers: _headers, body: body != null ? jsonEncode(body) : null);
    } else {
      response = await http.get(uri, headers: _headers);
    }

    if (response.statusCode == 401) {
      final authController = AuthController();
      final refreshResult = await authController.refreshToken(TokenManager.instance.refreshToken);

      if (refreshResult.status && refreshResult.data != null) {
        TokenManager.instance.token = refreshResult.data!.accessToken;
        TokenManager.instance.refreshToken = refreshResult.data!.refreshToken;

        // Retry the request with the new token
        if (method == 'POST') {
          response = await http.post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null);
        } else if (method == 'PUT') {
          response = await http.put(uri, headers: _headers, body: body != null ? jsonEncode(body) : null);
        } else {
          response = await http.get(uri, headers: _headers);
        }
      }
    }
    return response;
  }

  /// Lấy tất cả notification của user hiện tại
  Future<ApiResponse<List<NotificationItem>>> getMyNotifications() async {
    final response = await _requestWithRetry('GET', "$baseUrl/my");
    final json = jsonDecode(utf8.decode(response.bodyBytes));

    return ApiResponse<List<NotificationItem>>.fromJson(
      json,
      (data) => (data as List).map((item) => NotificationItem.fromJson(item)).toList(),
    );
  }

  /// Trả về số lượng notification chưa đọc
  Future<ApiResponse<Map<String, dynamic>>> getUnreadCount() async {
    final response = await _requestWithRetry('GET', "$baseUrl/unread-count");
    final json = jsonDecode(utf8.decode(response.bodyBytes));

    return ApiResponse<Map<String, dynamic>>.fromJson(
      json,
      (data) => data as Map<String, dynamic>,
    );
  }

  /// Đánh dấu notification đã đọc
  Future<ApiResponse<NotificationItem>> markAsRead(int id) async {
    final response = await _requestWithRetry('PUT', "$baseUrl/$id/read");
    final json = jsonDecode(utf8.decode(response.bodyBytes));

    return ApiResponse<NotificationItem>.fromJson(
      json,
      (data) => NotificationItem.fromJson(data),
    );
  }

  /// Đánh dấu tất cả notification đã đọc
  Future<ApiResponse<dynamic>> markAllAsRead() async {
    final response = await _requestWithRetry('PUT', "$baseUrl/read-all");
    final json = jsonDecode(utf8.decode(response.bodyBytes));

    return ApiResponse<dynamic>.fromJson(
      json,
      (data) => data,
    );
  }
}
